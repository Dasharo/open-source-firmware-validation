#!/bin/bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

MAX_ATTEMPTS=8
BASE_SLEEP_SECONDS=8
CHECKED_OUT_DEVICES=()

snipeit_checkout() {
    # Total of =~ 4088 s =~ 1.1 h
    device=$1
    attempt=1
    sleep_s=$BASE_SLEEP_SECONDS
    while (( attempt <= MAX_ATTEMPTS )); do
        echo "Attempt ${attempt}/${MAX_ATTEMPTS}: trying to check out the device ${device}..."
        osfv_cli snipeit check_out --asset_id $device
        result=$?
        if [[ $result == 0 ]]; then
            echo "Check out ${device} succeeded!"
            CHECKED_OUT_DEVICES+=("$device")
            break
        fi

        if (( attempt == MAX_ATTEMPTS )); then
            echo "Device checkout failed after ${MAX_ATTEMPTS} attempts."
            return 1
        fi

        echo "Device not available. Sleeping ${sleep_s}s before retry..."
        sleep "${sleep_s}"

        sleep_s=$(( sleep_s * 2 ))
        attempt=$(( attempt + 1 ))
    done
    return 0
}

snipeit_cleanup() {
    MAX_TRIES=10
    echo "To check_in: ${CHECKED_OUT_DEVICES[*]}"
    for id in "${CHECKED_OUT_DEVICES[@]}"; do
        trial=0
        out=$(osfv_cli snipeit check_in --asset_id $id)
        rc=$?
        while [[ $rc != 0 ]]; do
            if [ "$trial" -ge "$MAX_TRIES" ]; then
                echo "Failed ${MAX_TRIES} times, skipping check_in"
            fi
            echo "failed to check_in $rc: $out"
            sleep 5
            trial=$((trial+1))
        done
    done
    return 0
}
