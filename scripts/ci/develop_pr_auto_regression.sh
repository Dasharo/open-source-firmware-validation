#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/regression-scope/lib/snipeit_checkout.sh"
# shellcheck disable=SC2317
cleanup() {
    for id in "${pids[@]}"; do
        echo "killing $id"
        kill -9 $id &> /dev/null
    done
}
trap cleanup EXIT INT TERM HUP

echo "Comparing $(git rev-parse HEAD) with develop branch. Changed files:"
git diff --name-only origin/develop

if [[ -n $MANUAL_TESTS_LIST ]]; then
    TESTS_LIST="--override_tests_list $MANUAL_TESTS_LIST"
    echo $TESTS_LIST
else
    TESTS_LIST=""
fi

RULES_FILE="${RULES_FILE:-scripts/ci/regression-scope/configs/pr-regression-rules.json}"
DEVICES="${DEVICES:-scripts/ci/regression-scope/configs/pr-regression-devices.csv}"
DEVICES=$(cat $DEVICES | tr '\n' ' ')

mapfile -t commands < <("${SCRIPT_DIR}"/regression-scope/osfv_regression_scope.py commands $DEVICES --compare_to origin/develop $TESTS_LIST --rules_file "$RULES_FILE" )

if [[ ${#commands[@]} -eq 0 ]]; then
    echo "No tests required to run for these changes."
    exit 0
fi

echo "Commands to run:"
for c in "${commands[@]}"; do
    echo "$c"
    printf "\n"
done

pids=()
statuses=()
LOGS_DIR=${LOGS_DIR:-"./logs"}
mkdir -p $LOGS_DIR/ || true
i=1
for command in "${commands[@]}"; do
    (
        # Extract all environment variable exports from the command
        # Assuming every env var has its own `export` before
        # `export A=a B=b` not allowed
        # `export A=a; export B=b` is only handled
        IFS=';' read -ra parts <<< "$command"
        exports=()
        actual_command=""

        for part in "${parts[@]}"; do
            trimmed=$(echo "$part" | xargs)  # trim whitespace
            if [[ "$trimmed" == export* ]]; then
                exports+=("$trimmed")
            else
                actual_command="$trimmed"
            fi
        done

        export_string=$(IFS='; '; echo "${exports[*]}")
        echo Run $i setting environment variables: \"${export_string}\"
        eval ${export_string}

        if [[ -z $ASSET_ID ]]; then
            echo "ASSET_ID is undefined, fail to checkout the device"
        fi
        trap snipeit_cleanup EXIT INT TERM HUP
        snipeit_checkout "$ASSET_ID" || exit 2

        echo Run $i running basic-platform-setup
        eval ./scripts/run.sh util/basic-platform-setup.robot > "$LOGS_DIR/run_${i}.log" 2>&1
        echo Run $i executing: \"${actual_command}\"
        eval ${actual_command} >> "$LOGS_DIR/run_${i}.log" 2>&1
    ) &
    pids[i]=$!
    (( i++ ))
done

sleep 1

for idx in "${!pids[@]}"; do
    echo "Waiting for run $idx to finish..."
    if wait "${pids[$idx]}"; then
        statuses[idx]=0
        echo "run $idx is done."
    else
        statuses[idx]=$?
        echo "run $idx failed."
    fi
done


exit_code=0
for i in "${!statuses[@]}"; do
    code=${statuses[$i]}
    if [[ "$code" -ne 0 ]]; then
        echo "Run ${i} failed with exit code ${code}."
        cat "$LOGS_DIR/run_${i}.log"
        exit_code=1
    fi
done

exit $exit_code
