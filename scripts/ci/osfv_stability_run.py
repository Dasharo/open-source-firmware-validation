#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import pathlib
import shutil
import subprocess
import sys
import time

import develop_pr_auto_regression
import tqdm

N_REPEATS = 2
RUN_DATE = time.strftime("%Y_%m_%d_%H_%M_%S")
COMMIT = (
    subprocess.run(["git", "rev-parse", "HEAD"], stdout=subprocess.PIPE)
    .stdout.decode()
    .strip()
)
BRANCH = (
    subprocess.run(["git", "branch", "--show-current"], stdout=subprocess.PIPE)
    .stdout.decode()
    .strip()
)
env = os.environ
if "MANUAL_TESTS_LIST" not in env:
    env["MANUAL_TESTS_LIST"] = (
        "scripts/ci/regression-scope/configs/release_tests_suite_list_minimal.txt"
    )
if "DEVICES" not in env:
    env["DEVICES"] = "scripts/ci/regression-scope/configs/release_tests_devices.txt"
if "RULES_FILE" not in env:
    env["RULES_FILE"] = "scripts/ci/regression-scope/configs/release_tests_rules.json"
if "LOGS_DIR" not in env:
    env["LOGS_DIR"] = f"/srv/nfs/logs/osfv_stability/ci_logs"

env["ALLOW_DIRTY"] = "1"

os.makedirs(env["LOGS_DIR"], exist_ok=True)

repeats = tqdm.tqdm(range(N_REPEATS), colour="green")
for i in repeats:
    logs_dir = f"{env["LOGS_DIR"]}/{BRANCH}_{COMMIT}/{RUN_DATE}/run{i}"
    os.makedirs(logs_dir)
    env["LOGS_DIR"] = logs_dir

    rc = develop_pr_auto_regression.main(silent=True)
    if rc != 0:
        sys.exit(rc)
