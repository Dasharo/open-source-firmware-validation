#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

RUN_DATE="$(date +%Y_%m_%d_%H_%M_%S)"

# Trap SIGINT (Ctrl+C)
trap 'handle_ctrl_c' SIGINT

check_env_variable() {
  if [ -z "${!1}" ]; then
    echo "Error: Environment variable $1 is not set."
    exit 1
  fi
}

check_test_station_variables() {
  if [[ $CONFIG != *"-ts"? ]]; then
    return
  fi

  if [ -z "$INSTALLED_DUT" ]; then
    echo "Error: This is a test station, you must specify variable INSTALLED_DUT"
    exit 1
  fi
}

handle_ctrl_c() {
  echo "Ctrl+C pressed. Exiting."
  # You can add cleanup tasks here if needed
  exit 1
}

execute_robot() {
  # _test_path can be either
  #   - path to directory containing a set of .robot files
  #   - path to a single .robot file
  local _args=("$@")
  local _test_path=()
  local _separator_idx=-1
  local _args_len=${#_args[@]}

  # Move all arguments from _args list before "--" to _test_path list
  # using a loop and an iterator to save at which position the "--" separator
  # appeared.
  #
  # Only things like path to directory containing .robot files
  # or paths to a single .robot file should be given in the command
  # before the first "--" sequence
  #
  # It is solved in this way to easily differentiante between the test
  # scope and additional arguments to robot which need to be separated
  # when calling robot
  for ((i=0;i<_args_len;i++)); do
    if [[ ${_args[$i]} == *"--"* ]]; then
      _separator_idx=$i
      break
    fi
    _test_path+=("${_args[$i]}")
  done;

  # Move all arguments after "--" to _robot_args list using the position of "--"
  # saved in _separator_idx
  local _robot_args=()
  if [[ $_separator_idx -gt 0 ]]; then
    _separator_idx=$_separator_idx+1
    for ((i=_separator_idx;i<_args_len;i++)); do
      # Some arguments may contain spaces. Bash removes quotation marks
      # from command arguments. Because we need to pass them again to
      # another command the quotation marks need to be restored or the arguments
      # containing spacebars will be split into multiple arguments when
      # concatenating the list into a string to use in eval
      #
      # If an arguments from _args list contains a spacebar, quotation marks are
      # added around it.
      if [[ ${_args[$i]} =~ \  ]]; then
        _args[i]=\"${_args[i]}\"
      fi
      _robot_args+=("${_args[$i]}")
    done
  fi


  # Check if the required environment variables are set
  check_env_variable "CONFIG"

  # DIR_PREFIX (optional) additional description of test result dir
  if [ -n "${DIR_PREFIX}" ]; then
    dir_prefix="${DIR_PREFIX}_"
  else
    dir_prefix=""
  fi

  # RTE_IP environment variable is not required for some platforms
  if [ -n "${RTE_IP}" ]; then
    rte_ip_option="-v rte_ip:${RTE_IP}"
  else
    rte_ip_option=""
  fi

  # FW_FILE environment variable is optional for some tests
  if [ -n "${FW_FILE}" ]; then
    fw_file_option="-v fw_file:${FW_FILE}"
  else
    fw_file_option=""
  fi

  # DEVICE_IP environment variable is optional for some tests/platforms
  if [ -n "${DEVICE_IP}" ]; then
    device_ip_option="-v device_ip:${DEVICE_IP}"
  else
    device_ip_option=""
  fi

  # CAPSULE_FW_FILE environment variable is required for the capsule update test
  if [ -n "${CAPSULE_FW_FILE}" ]; then
    capsule_fw_file_option="-v capsule_fw_file:${CAPSULE_FW_FILE}"
  else
    capsule_fw_file_option=""
  fi

  extra_options=""
  # By default use snipeit, if SNIPEIT_NO is not set
  if [ -n "${SNIPEIT_NO}" ]; then
    extra_options="-v snipeit:no"
    if [ -n "${SONOFF_IP}" ]; then
      extra_options="${extra_options} -v sonoff_ip:${SONOFF_IP}"
    fi
    if [ -n "${PIKVM_IP}" ]; then
      extra_options="${extra_options} -v pikvm_ip:${PIKVM_IP}"
    fi
  fi
  # Needed only for test stations with different possible installed DUTs
  if [ -n "${INSTALLED_DUT}" ]; then
    installed_dut_option="-v installed_dut=${INSTALLED_DUT}"
  else
    installed_dut_option=""
  fi

  # Prevent executing tests on a dirty git tree

  if [[ -z "${ALLOW_DIRTY}" ]]; then
    echo "Checking if running the test from a reproducible revision."
    echo "If NECESSARY, set ALLOW_DIRTY to skip the check."

    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "Git tree is dirty!"
        echo "Commit your changes before running tests!"
        exit 1
    fi

    branch=$(git rev-parse --abbrev-ref HEAD)
    git fetch -q
    commits_ahead=$(git rev-list --left-right --count origin/$branch...$branch | awk '{print $2}')
    if [[ "$commits_ahead" -gt 0 ]]; then
        echo "Local branch $branch is ahead of origin/$branch by $commits_ahead commits!"
        echo "Push your changes before running any tests!"
        exit 1
    fi
  fi


  # To save the logs from test modules into separate files robot is called
  # multiple times.
  #
  # Thanks to detecting spacebars in arguments before _robot_args can now
  # safely be concatenated into a string and these arguments will still be
  # passed correctly.
  #
  # Firstly, the provided argument will be parsed to get the proper name
  # for the results directory.
  overall_rc=0
  for _test_name in "${_test_path[@]}"; do
    if [[ "$_test_name" == *"/"* && "$_test_name" != */ ]]; then
      _test_scope_name="${_test_name##*/}"
      if [[ "$_test_scope_name" == *".robot"* ]]; then
        _test_scope_name="${_test_scope_name%%.*}"
      fi
    else
      _test_scope_name="${_test_name%%/*}"
    fi

    if [ -n "${_REGRESSION_RUN}" ]; then
      local _logs_dir="logs/${CONFIG}/${dir_prefix}regresion_${RUN_DATE}"
    else
      local _logs_dir="logs/${CONFIG}/${dir_prefix}${_test_scope_name}_${RUN_DATE}"
    fi
    local _log_file="${_logs_dir}/${_test_scope_name}_log.html"
    local _report_file="${_logs_dir}/${_test_scope_name}_report.html"
    local _output_file="${_logs_dir}/${_test_scope_name}_out.xml"
    local _debug_file="${_logs_dir}/${_test_scope_name}_debug.log"

    echo "Logs will be saved at ${_logs_dir}"
    echo "Watch \"${_debug_file}\" to monitor the progress of the test"

    command="
          robot -L TRACE \
                -l ${_log_file} \
                -r ${_report_file} \
                -o ${_output_file} \
                -b ${_debug_file} \
                ${rte_ip_option} \
                -v config:${CONFIG} \
                -v logs_dir:${_logs_dir} \
                ${device_ip_option} \
                ${fw_file_option} \
                ${capsule_fw_file_option} \
                ${installed_dut_option} \
                ${extra_options} \
                ${_robot_args[*]} \
                ${_test_name}
                "
    #echo "$command"
    eval "$command"
    if [[ $? -ne 0 ]]; then
      overall_rc=1
    fi
  done
  return $overall_rc
}
