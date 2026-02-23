#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import atexit
import os
import shlex
import signal
import subprocess
import sys
import threading
import time
from pathlib import Path

BASE_SLEEP_SECONDS = 8
MAX_SLEEP_SECONDS = 1024
try:
    MAX_SNIPEIT_WAIT_SECONDS = int(os.getenv("MAX_SNIPEIT_WAIT_SECONDS", 86400))  # 24 h
except:
    print(
        "env variable MAX_SNIPEIT_WAIT_SECONDS is not an integer: `{MAX_SNIPEIT_WAIT_SECONDS}`"
    )
    sys.exit(1)
CHECKED_OUT = []
PROCS = {}
debug = True


def dprint(*args):
    if debug:
        print(*args)


def run(cmd, env=None, stdout=None, stderr=None):
    return subprocess.run(
        cmd, env=env, stdout=stdout, stderr=stderr, universal_newlines=True
    )


def snipeit_checkout(asset_id):
    sleep_s = BASE_SLEEP_SECONDS
    attempt = 0
    t0 = time.time()
    total_time = 0
    while True:
        if total_time >= MAX_SNIPEIT_WAIT_SECONDS:
            dprint(f"Device checkout failed after {attempt} attempts.")
            return 1

        attempt += 1
        dprint(
            f"Attempt {attempt} ({total_time}/{MAX_SNIPEIT_WAIT_SECONDS} s): trying to check out the device {asset_id}..."
        )
        r = run(["osfv_cli", "snipeit", "check_out", "--asset_id", asset_id])
        if r.returncode == 0:
            dprint(f"Check out {asset_id} succeeded!")
            CHECKED_OUT.append(asset_id)
            return 0

        dprint(f"Device not available. Sleeping {sleep_s}s before retry...")
        time.sleep(sleep_s)
        total_time = time.time() - t0
        sleep_s = min(sleep_s * 2, MAX_SLEEP_SECONDS)
    return 1


def snipeit_cleanup():
    dprint(f"To check_in: {' '.join(CHECKED_OUT)}")
    for asset_id in CHECKED_OUT:
        for _ in range(10):
            r = subprocess.run(
                ["osfv_cli", "snipeit", "check_in", "--asset_id", asset_id],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
            )
            if r.returncode == 0:
                dprint(f"{asset_id} checked in successfully")
                break
            dprint(f"failed to check_in {r.returncode}: {r.stdout}")
            time.sleep(5)


def _cleanup_handler(*_):
    for p in PROCS.values():
        if p.poll() is None:
            dprint(f"killing {p.pid}")
            p.kill()
    snipeit_cleanup()
    sys.exit(1)


def collect_commands(script_dir, devices, tests, rules):
    res = run(
        [
            str(script_dir / "regression-scope/osfv_regression_scope.py"),
            "commands",
            *shlex.split(devices),
            *tests,
            "--rules_file",
            rules,
        ],
        stdout=subprocess.PIPE,
    )
    return [l for l in res.stdout.splitlines() if l.strip()]


def execute_commands(commands, logs_dir):
    statuses = {}

    def worker(idx, cmd):
        env = os.environ.copy()
        parts = [p.strip() for p in cmd.split(";") if p.strip()]
        actual = ""
        for p in parts:
            if p.startswith("export"):
                k, v = p.split()[1].split("=", 1)
                env[k] = v
            else:
                actual = p
        dprint(f"Run {idx} setting environment variables")
        if "ASSET_ID" not in env:
            dprint("ASSET_ID is undefined, fail to checkout the device")
        if snipeit_checkout(env.get("ASSET_ID", "")) != 0:
            statuses[idx] = 2
            return
        log = open(logs_dir / f"run_{idx}.log", "w")
        dprint(f'Run {idx} executing: "{actual}"')
        p = subprocess.Popen(shlex.split(actual), env=env, stdout=log, stderr=log)
        PROCS[idx] = p
        rc = p.wait()
        statuses[idx] = rc
        dprint(f"run {idx} {'is done' if rc == 0 else 'failed'}")

    threads = []
    for i, c in enumerate(commands, 1):
        t = threading.Thread(target=worker, args=(i, c))
        t.start()
        threads.append(t)

    for i, t in enumerate(threads, 1):
        dprint(f"Waiting for run {i} to finish...")
        t.join()

    return statuses


def main(silent=False):
    global debug
    if silent:
        debug = False

    script_dir = Path(__file__).resolve().parent
    logs_dir = Path(os.environ.get("LOGS_DIR", "./ci-logs"))
    logs_dir.mkdir(parents=True, exist_ok=True)

    rules = os.environ.get(
        "RULES_FILE", "scripts/ci/regression-scope/configs/pr-regression-rules.json"
    )
    devices = (
        Path(
            os.environ.get(
                "DEVICES",
                "scripts/ci/regression-scope/configs/pr-regression-devices.txt",
            )
        )
        .read_text()
        .splitlines()
    )
    devices = [
        d for d in devices if not d.startswith("#")
    ]  # filter out commented lines
    devices = " ".join(devices)
    if os.environ.get("MANUAL_TESTS_LIST"):
        tests = ["--override_tests_list", os.environ["MANUAL_TESTS_LIST"]]
        dprint(" ".join(tests))
    else:
        tests = ["--compare_to", "origin/develop"]

        dprint(
            f"Comparing {run(['git','rev-parse','HEAD'],stdout=subprocess.PIPE).stdout.strip()} "
            "with develop branch. Changed files:"
        )
        dprint(
            run(
                ["git", "diff", "--name-only", "origin/develop"], stdout=subprocess.PIPE
            ).stdout
        )

    commands = collect_commands(script_dir, devices, tests, rules)
    if not commands:
        dprint("No tests required to run for these changes.")
        return 0

    dprint("Commands to run:")
    for c in commands:
        dprint(c, "\n")

    statuses = execute_commands(commands, logs_dir)

    exit_code = 0
    if len(statuses.items()) == 1:
        i, rc = list(statuses.items())[0]
        return rc
    for i, rc in statuses.items():
        if rc != 0:
            dprint(f"Run {i} failed with exit code {rc}.")
            dprint((logs_dir / f"run_{i}.log").read_text())
            exit_code = 1

    return exit_code


atexit.register(snipeit_cleanup)
for s in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
    signal.signal(s, _cleanup_handler)

if __name__ == "__main__":
    sys.exit(main())
