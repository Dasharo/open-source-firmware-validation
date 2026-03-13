#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/robot.sh"

# DEVICE_IP is required; firmware can be provided via FW_FILE or FW_URI
check_env_variable "DEVICE_IP"
resolve_fw_file

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
            --rerunfailed $REGRESSION_LOG_DIR/${_suite}_out.xml "${@}"
        rebot --output $_logs_dir/${_suite}_out_merged.xml \
            --log $_logs_dir/${_suite}_log_merged.html \
            --report $_logs_dir/${_suite}_report_merged.html \
            --merge $REGRESSION_LOG_DIR/${_suite}_out.xml $_logs_dir/${_suite}_out.xml
        mv $_logs_dir/${_suite}_out_merged.xml $_logs_dir/${_suite}_out.xml
        mv $_logs_dir/${_suite}_log_merged.html $_logs_dir/${_suite}_log.html
        mv $_logs_dir/${_suite}_report_merged.html $_logs_dir/${_suite}_report.html
    fi
}

rerun_suite dasharo-compatibility "${@}"
rerun_suite dasharo-security "${@}"
rerun_suite dasharo-stability "${@}"
if [ -z "$NO_PERFORMANCE" ]; then
    rerun_suite dasharo-performance "${@}"
fi
