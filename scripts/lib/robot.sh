#!/usr/bin/env bash

RUN_DATE="$(date +%Y_%m_%d_%H_%M_%S)"

# Trap SIGINT (Ctrl+C)
trap 'handle_ctrl_c' SIGINT

check_env_variable() {
    if [ -z "${!1}" ]; then
        echo "Error: Environment variable $1 is not set."
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
  local _test_path=$1
  local _test_name=""
  _test_name="$(basename ${_test_path%.robot})"

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

  # By default use snipeit, if SNIPEIT_NO is not set
  if [ -n "${SNIPEIT_NO}" ]; then
      snipeit_no_option="-v snipeit:no"
  else
      snipeit_no_option=""
  fi

  local _logs_dir="logs/${CONFIG}/${RUN_DATE}"
  local _log_file="${_logs_dir}/${_test_name}_log.html"
  local _report_file="${_logs_dir}/${_test_name}_report.html"
  local _output_file="${_logs_dir}/${_test_name}_out.xml"

  robot -L TRACE \
        -l ${_log_file} \
        -r ${_report_file} \
        -o ${_output_file} \
        -v rte_ip:${RTE_IP} \
        -v config:${CONFIG} \
        ${device_ip_option} \
        ${fw_file_option} \
        ${snipeit_no_option} \
        ${_test_path}
}
