#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Comparing $(git rev-parse HEAD) with develop branch. Changed files:"
git diff --name-only origin/develop

mapfile -t commands < <(${SCRIPT_DIR}/regression-scope/osfv_regression_scope.py commands --compare_to origin/develop)
echo "Commands to run:"
echo "${commands[@]}"
printf "\n"

if [[ ${#commands[@]} -eq 0 ]]; then
    echo "No tests required to run for these changes."
fi

pids=()
statuses=()
LOGS_DIR="./logs"
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
        echo Run $i running basic-platform-setup
        eval ./scripts/run.sh util/basic-platform-setup.robot > "$LOGS_DIR/run_${i}.log" 2>&1
        echo Run $i executing: \"${actual_command}\"
        eval ${actual_command} >> "$LOGS_DIR/run_${i}.log" 2>&1
    ) &
    pids[${i}]=$!
    (( i++ ))
done

sleep 1

for idx in "${!pids[@]}"; do
    echo "Waiting for run $idx to finish..."
    if wait ${pids[$idx]}; then
        statuses[idx]=0
        echo "run $idx is done."
    else
        statuses[idx]=$?
        echo "run $idx failed."
    fi
done


exit_code=0
i=0
for code in "${statuses[@]}"; do
    if [[ "$code" -ne 0 ]]; then
        echo "Run ${i} failed with exit code ${code}. Check $LOGS_DIR/run_${i}.log for details."
        exit_code=1
    fi
    (( i++))
done

exit $exit_code
