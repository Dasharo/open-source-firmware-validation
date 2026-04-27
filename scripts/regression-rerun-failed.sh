#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

# FW_FILE and DEVICE_IP are required for full regression
check_env_variable "FW_FILE"
check_env_variable "DEVICE_IP"

if [ ! -f "$FW_FILE" ]; then
    echo "Error: Environment variable FW_FILE doesn't point to a file."
    exit 1
fi

_REGRESSION_RUN="True"
export _REGRESSION_RUN

check_test_station_variables

if [ $# -lt 1 ]; then
    echo "Error: Argument with directory with logs from last regression missing"
    exit 1
fi

REGRESSION_LOG_DIR=$1
shift

if [ ! -d $REGRESSION_LOG_DIR ]; then
    echo "Error: Directory with logs from last regression does not exist"
    exit 1
fi

RUN_DATE="${RUN_DATE:-$(date '+%Y_%m_%d_%H_%M_%S')}"
export RUN_DATE

if [ -n "${DIR_PREFIX}" ]; then
    dir_prefix="${DIR_PREFIX}_"
else
    dir_prefix=""
fi

if [[ -z $LOGS_DIR ]]; then
    _logs_dir="logs/${CONFIG}/${dir_prefix}regression_${RUN_DATE}"
else
    _logs_dir="$LOGS_DIR/${CONFIG}/${dir_prefix}regression_${RUN_DATE}"
fi

rerun_suite () {
    local _suite=$1

    shift

    if [ ! -f $REGRESSION_LOG_DIR/${_suite}_out.xml ]; then
        echo "Error: Output XML from last $_suite regression does not exist"
    else
        execute_robot "$_suite" -- \
            --rerunfailed $REGRESSION_LOG_DIR/${_suite}/merged_out.xml "${@}"
        rebot --output $_logs_dir/${_suite}_out_merged.xml \
            --log $_logs_dir/${_suite}_log_merged.html \
            --report $_logs_dir/${_suite}_report_merged.html \
            --merge $REGRESSION_LOG_DIR/${_suite}_out.xml $_logs_dir/${_suite}/merged_out.xml
        mv $_logs_dir/${_suite}_out_merged.xml $_logs_dir/${_suite}/merged_out.xml
        mv $_logs_dir/${_suite}_log_merged.html $_logs_dir/${_suite}/merged_log.html
        mv $_logs_dir/${_suite}_report_merged.html $_logs_dir/${_suite}/merged_report.html
    fi
}

rerun_suite dasharo-compatibility "${@}"
rerun_suite dasharo-security "${@}"
rerun_suite dasharo-stability "${@}"
if [ -z "$NO_PERFORMANCE" ]; then
    rerun_suite dasharo-performance "${@}"
fi
