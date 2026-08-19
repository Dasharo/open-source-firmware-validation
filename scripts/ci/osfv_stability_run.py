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

import tqdm

REGRESSION_SCRIPT = (
    pathlib.Path(__file__).resolve().parent / "develop_pr_auto_regression.py"
)
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


def read_devices(list_path):
    """
    Returns the device names to run on, one per line, ignoring comments
    and blank lines.
    """
    lines = pathlib.Path(list_path).read_text().splitlines()
    return [line.strip() for line in lines if line.strip() and not line.startswith("#")]


def start_regression(device, idx):
    """
    Start the regression of one device in the background. Its output goes to
    run_<idx>.log in the logs directory of the current repeat.
    Returns the process and its log file.
    """
    log = open(f"{env['LOGS_DIR']}/run_{idx}.log", "w")
    proc = subprocess.Popen(
        [sys.executable, REGRESSION_SCRIPT],
        env={**env, "DEVICE": device},
        stdout=log,
        stderr=log,
    )
    return proc, log


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
    logs_base = f"/srv/nfs/logs/osfv_stability/ci_logs"
else:
    logs_base = env["LOGS_DIR"]

env["ALLOW_DIRTY"] = "1"

os.makedirs(logs_base, exist_ok=True)

# develop_pr_auto_regression.py tests one device per run, so a repeat starts one
# run per device and waits for all of them.
devices = read_devices(env["DEVICES"])

repeats = tqdm.tqdm(range(N_REPEATS), colour="green")
rcs = []
for i in repeats:
    logs_dir = f"{logs_base}/{BRANCH}_{COMMIT}/{RUN_DATE}/run{i}"
    os.makedirs(logs_dir)
    env["LOGS_DIR"] = logs_dir

    runs = [start_regression(device, idx) for idx, device in enumerate(devices, 1)]
    for proc, log in runs:
        rcs.append(proc.wait())
        log.close()

if sum(rcs) != 0:
    print("return codes: ", rcs)
    sys.exit(1)
