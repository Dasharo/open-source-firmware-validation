#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

RUN_DATE="${RUN_DATE:-$(date '+%Y_%m_%d_%H_%M_%S')}"

if [[ -z $LOGS_DIR ]]; then
  LOGS_DIR="logs"
fi
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

check_dirty_tree() {
  function dirty_message {
        echo "Please commit and push your changes before running tests to ensure reproducibility."
        echo "(Set ALLOW_DIRTY=1 to override and allow quick debugging)"
  }

  if [[ -z "${ALLOW_DIRTY}" ]]; then
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "Git tree is dirty!"
        dirty_message
        exit 1
    fi

    branch=$(git rev-parse --abbrev-ref HEAD)
    if ! git fetch -q; then
        echo "Failed to fetch remote"
        exit 1
    fi

    commits_ahead=$(git rev-list --left-right --count origin/$branch...$branch 2>&1)
    if [[ $? != 0 || "$commits_ahead" =~ "fatal" ]]; then
        echo "Failed to check if the local branch is up to date."
        if [[ "$commits_ahead" =~ "not in the working tree" ]]; then
            echo "The local branch might not exist on the remote."
            echo "Make sure to push your branch."
        fi
        dirty_message
        exit 1
    fi

    commits_ahead=$(echo "$commits_ahead" | awk '{print $2; }')
    if [[ "$commits_ahead" -gt 0 ]]; then
        echo "Local branch $branch is ahead of origin/$branch by $commits_ahead commits!"
        dirty_message
        exit 1
    fi
  fi
}

bash_list_to_python_list_string() {
  list=("${@:1}")
  if ((${#list[@]})) || [[ -z ${list[0]} ]]; then
    printf -v python_list '%s,' "${list[@]}"
    python_list=${python_list%,}
    echo "[\"${python_list//,/\",\"}\"]"
  else
    echo "[]"
  fi
}

test_matches_pattern() {
  # Robot Framework 7.3
  # Select tests by name or by long name containing also parent suite name like
  # Parent. Test. Name is case and space insensitive and it can also be a simple
  # pattern where * matches anything, ? matches any single character, and
  # [chars] matches one character in brackets.
  test_name="$1"
  pattern="$2"
  # remove uppercase, spacebars to be case and space insensitive
  # remove quotes if they got here, not needed when spaces are removed
  norm_name=$(echo "$test_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | tr -d '"')
  # normalize pattern the same way
  norm_pat=$(echo "$pattern" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | tr -d '"')
  # treat robot pattern as shell glob - [], *, ? work identically in POSIX
  if [[ "$norm_name" == "$norm_pat" ]]; then
    return 0
  fi
  return 1
}

get_matched_test_cases() {
  test_name=$1 # file or directory
  IFS='-' read -ra robot_args <<< "$2" # like '-v 123 -t "*test1*" -i basic'
  t_args=()
  all_test_cases=()
  test_cases_to_execute=()

  # Scan for all -i and -t parameters and save them
  for arg in "${robot_args[@]}"; do
    arg=$(echo "$arg" | xargs) # trim
    case "$arg" in
      t\ *)  t_args+=("$(echo "$arg" | cut -d' ' -f2-)") ;;
      *)  ;;
    esac
  done

  # Find all test cases to run according to given module/suite file
  if [ -d "$test_name" ]; then
    while IFS= read -r file; do
      while IFS= read -r line; do
        all_test_cases+=("$line")
      done < <(grep -hE '^[A-Z]{3,8}[0-9]{3}\.[0-9]{3}' "$file")
    done < <(find "$test_name" -type f -name "*.robot")
  elif [ -f "$test_name" ]; then
    while IFS= read -r line; do
      all_test_cases+=("$line")
    done < <(grep -hE '^[A-Z]{3,8}[0-9]{3}\.[0-9]{3}' "$test_name")
  else
    echo "Error invalid file or directory $test_name" >&2
    return 1
  fi

  # filter test cases using -t parameter
  if [ ${#t_args[@]} -gt 0 ]; then
    while IFS= read -r case; do
      for filter in "${t_args[@]}"; do
        if test_matches_pattern "$case" "$filter"; then
          test_cases_to_execute+=("$case")
          break
        fi
      done
    done < <(printf "%s\n" "${all_test_cases[@]}")
  else
    test_cases_to_execute=("${all_test_cases[@]}")
  fi

  # leave only test IDs of matched test cases
  mapfile -t test_cases_to_execute < <(
    printf "%s\n" "${test_cases_to_execute[@]}" | awk '{print $1}'
  )

  echo "$(bash_list_to_python_list_string "${test_cases_to_execute[@]}")"
}

get_test_tags() {
  IFS='-' read -ra robot_args <<< "$1" # like '-v 123 -t "*test1*" -i basic'
  tags=()
  # Scan for all -i parameters and save them
  for arg in "${robot_args[@]}"; do
    arg=$(echo "$arg" | xargs) # trim
    case "$arg" in
      i\ *)  tags+=("$(echo "$arg" | cut -d' ' -f2-)") ;;
      *)  ;;
    esac
  done
  echo "$(bash_list_to_python_list_string "${tags[@]}")"
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
    dir_prefix="${DIR_PREFIX}/"
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

  check_dirty_tree

  overall_rc=0
  if [ -n "${_REGRESSION_RUN}" ]; then
    _root_logs_dir="$LOGS_DIR/${CONFIG}/${dir_prefix}regression_${RUN_DATE}"
    _merged_logs_dir="$_root_logs_dir"
  else
    _root_logs_dir="$LOGS_DIR/${CONFIG}/${dir_prefix}"
    _merged_logs_dir="${_root_logs_dir}/${dir_prefix}merged_${RUN_DATE}"
  fi
  mkdir -p "$_root_logs_dir"
  mkdir -p "$_merged_logs_dir"
  _output="${_merged_logs_dir}/merged_out.xml"
  _debug="${_merged_logs_dir}/merged_debug.log"
  _log="${_merged_logs_dir}/merged_log.html"
  _report="${_merged_logs_dir}/merged_report.html"

  echo "Logs will be saved at ${_merged_logs_dir}"
  echo "Watch \"${_debug}\" to monitor the progress of the test"

  _test_cases=$(get_matched_test_cases "${_test_path[*]}" "${_robot_args[*]}")
  [[ -n $_test_cases ]] && _test_cases="-v TEST_CASES:'$_test_cases'"
  _test_tags=$(get_test_tags "${_robot_args[*]}")
  [[ -n $_test_tags ]] && _test_tags="-v INCLUDE_TAGS:'$_test_tags'"

  command="
        robot -L TRACE \
              -l ${_log} \
              -r ${_report} \
              -o ${_output} \
              -b ${_debug} \
              ${rte_ip_option} \
              -v config:${CONFIG} \
              -v logs_dir:${_merged_logs_dir} \
              ${device_ip_option} \
              ${fw_file_option} \
              ${capsule_fw_file_option} \
              ${installed_dut_option} \
              ${extra_options} \
              ${_robot_args[*]} \
              ${_test_cases} \
              ${_test_tags} \
              ${_test_path[*]} \
              "

  robot_pid=""
  interrupted=0

  cleanup_and_split() {
    python "scripts/lib/rebot_splitter.py" "$_output" "$_root_logs_dir" "$RUN_DATE"
  }

  on_int() {
    interrupted=1
    if [[ -n "$robot_pid" ]]; then
      # Send SIGINT to the whole process group (closest to real Ctrl+C)
      kill -INT -"${robot_pid}" 2>/dev/null || true
    fi
  }

  trap on_int INT
  trap cleanup_and_split EXIT

  # Start robot in its own process group so kill -INT -$pid works
  set -m
  eval "${command}" &
  robot_pid=$!

  fg %1
  robot_rc=$?

  if [[ $interrupted -eq 1 && $robot_rc -eq 130 ]]; then
    overall_rc=130
  else
    overall_rc=$robot_rc
  fi

  return $overall_rc
}
