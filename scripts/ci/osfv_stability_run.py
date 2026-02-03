#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import shutil
import sys

import develop_pr_auto_regression
import tqdm

N_REPEATS = 5
LOGS_DIR = "ci_logs"
MANUAL_TESTS_LIST = "scripts/ci/regression-scope/configs/release_tests_suite_list.txt"
DEVICES_LIST = "scripts/ci/regression-scope/configs/release_tests_devices.csv"


env = os.environ
env["ALLOW_DIRTY"] = "1"
env["MANUAL_TESTS_LIST"] = MANUAL_TESTS_LIST
env["DEVICES"] = DEVICES_LIST

shutil.rmtree(LOGS_DIR, ignore_errors=True)
os.makedirs(LOGS_DIR)

repeats = tqdm.tqdm(range(N_REPEATS), colour="green")
for i in repeats:
    logs_dir = f"{LOGS_DIR}/run{i}"
    os.makedirs(logs_dir)
    env["LOGS_DIR"] = logs_dir

    rc = develop_pr_auto_regression.main(silent=True)
    if rc != 0:
        sys.exit(rc)
