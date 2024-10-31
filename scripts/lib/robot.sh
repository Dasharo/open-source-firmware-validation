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
  check_env_variable "RTE_IP"
  check_env_variable "CONFIG"

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

  # To save the logs from test modules into separate files robot is called
  # multiple times.
  #
  # Thanks to detecting spacebars in arguments before _robot_args can now
  # safely be concatenated into a string and these arguments will still be
  # passed correctly.
  for _test_name in "${_test_path[@]}"; do
    local _logs_dir="logs/${CONFIG}/${RUN_DATE}"
    local _log_file="${_logs_dir}/${_test_name}_log.html"
    local _report_file="${_logs_dir}/${_test_name}_report.html"
    local _output_file="${_logs_dir}/${_test_name}_out.xml"
    local _debug_file="${_logs_dir}/${_test_name}_debug.log"

    command="
          robot -L TRACE \
                -l ${_log_file} \
                -r ${_report_file} \
                -o ${_output_file} \
                -b ${_debug_file} \
                -v rte_ip:${RTE_IP} \
                -v config:${CONFIG} \
                ${device_ip_option} \
                ${fw_file_option} \
                ${installed_dut_option} \
                ${extra_options} \
                ${_robot_args[*]} \
                ${_test_name}
                "
    #echo "$command"
    eval "$command"
  done
}
