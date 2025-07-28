#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
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

if [ -z "$NO_SETUP" ]; then
    execute_robot "util/basic-platform-setup.robot" "${@}"
fi

TESTS=""

if [ -n "$REL_ID" ] && [ -n "$DB_URL" ]; then
    TESTS+=" --"
    JSON=`curl -s -k "$DB_URL/releases/$REL_ID"`
    for t in `echo "$JSON" | jq '.test_cases | map_values(select(endswith("automated"))) | keys | map(.+"*") | .[]'`; do
        TESTS+=" -t $t"
    done
fi

execute_robot "dasharo-compatibility" "${@}" $TESTS
execute_robot "dasharo-security" "${@}" $TESTS
execute_robot "dasharo-performance" "${@}" $TESTS
