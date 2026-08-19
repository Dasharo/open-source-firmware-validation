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
import time
from pathlib import Path

BASE_SLEEP_SECONDS = 8
MAX_SLEEP_SECONDS = 1024
try:
    MAX_SNIPEIT_WAIT_SECONDS = int(os.getenv("MAX_SNIPEIT_WAIT_SECONDS", 86400))  # 24 h
except ValueError:
    print(
        "env variable MAX_SNIPEIT_WAIT_SECONDS is not an integer: "
        f"`{os.getenv('MAX_SNIPEIT_WAIT_SECONDS')}`"
    )
    sys.exit(1)
CHECKED_OUT_ASSET = None
PROC = None
SIGKILL_GRACE_S = 30
debug = True


def dprint(*args):
    if debug:
        print(*args)


def run(cmd, env=None, stdout=None, stderr=None):
    return subprocess.run(
        cmd, env=env, stdout=stdout, stderr=stderr, universal_newlines=True
    )


def snipeit_checkout(asset_id):
    global CHECKED_OUT_ASSET
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
            CHECKED_OUT_ASSET = asset_id
            return 0

        dprint(f"Device not available. Sleeping {sleep_s}s before retry...")
        time.sleep(sleep_s)
        total_time = time.time() - t0
        sleep_s = min(sleep_s * 2, MAX_SLEEP_SECONDS)


def snipeit_cleanup():
    global CHECKED_OUT_ASSET
    # taking the asset away makes the second caller a no-op, both the signal
    # handler and atexit want to check in
    asset_id, CHECKED_OUT_ASSET = CHECKED_OUT_ASSET, None
    if asset_id is None:
        return
    dprint(f"To check_in: {asset_id}")
    for _ in range(10):
        r = subprocess.run(
            ["osfv_cli", "snipeit", "check_in", "--asset_id", asset_id],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        if r.returncode == 0:
            dprint(f"{asset_id} checked in successfully")
            return
        dprint(f"failed to check_in {r.returncode}: {r.stdout}")
        time.sleep(5)


def _iter_descendants(pid):
    """Yield all descendant PIDs of pid by walking /proc (Linux)."""
    try:
        children = Path(f"/proc/{pid}/task/{pid}/children").read_text().split()
    except (FileNotFoundError, OSError):
        return
    for child_str in children:
        try:
            child_pid = int(child_str)
        except ValueError:
            continue
        yield child_pid
        yield from _iter_descendants(child_pid)


def _cleanup_handler(*_):
    p = PROC
    if p is not None and p.poll() is None:
        # Step 1: SIGINT so bash's on_int trap fires and signals robot's process
        # group.
        dprint(f"Sending SIGINT to {p.pid}")
        try:
            p.send_signal(signal.SIGINT)
        except OSError:
            pass

        # Step 2: Wait for graceful exit.
        try:
            p.wait(timeout=SIGKILL_GRACE_S)
        except subprocess.TimeoutExpired:
            pass

        # Step 3: Force-kill a survivor and all its descendants (e.g. robot
        # started in its own process group by run.sh via "set -m").
        if p.poll() is None:
            dprint(f"Force-killing {p.pid} and its descendants")
            for desc_pid in list(_iter_descendants(p.pid)):
                try:
                    os.kill(desc_pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            try:
                p.kill()
            except OSError:
                pass

        # Step 4: Reap the zombie so nothing is left.
        try:
            p.wait(timeout=5)
        except (subprocess.TimeoutExpired, OSError):
            pass

    snipeit_cleanup()
    sys.exit(1)


def collect_commands(script_dir, device, tests, rules):
    res = run(
        [
            str(script_dir / "regression-scope/osfv_regression_scope.py"),
            "commands",
            device,
            *tests,
            "--rules_file",
            rules,
        ],
        stdout=subprocess.PIPE,
    )
    return [l for l in res.stdout.splitlines() if l.strip()]


def split_env(command):
    """
    Split `export A=a; export B=b; scripts/run.sh suite.robot` into the
    environment it exports and the command that is left to execute.
    """
    env = os.environ.copy()
    # will always be reported as dirty in CI
    # does not prevent running the CI
    env["ALLOW_DIRTY"] = "1"
    actual = ""
    for part in [p.strip() for p in command.split(";") if p.strip()]:
        if part.startswith("export"):
            k, v = part.split()[1].split("=", 1)
            env[k] = v
        else:
            actual = part
    return env, actual


def execute_commands(commands):
    """
    Execute the commands for the device one after another, letting the tests
    print straight to stdout. Returns 0 only if all of them succeeded.
    """
    global PROC
    exit_code = 0

    for idx, cmd in enumerate(commands, 1):
        env, actual = split_env(cmd)
        dprint(f"Run {idx} setting environment variables")
        if "ASSET_ID" not in env:
            dprint("ASSET_ID is undefined, skipping snipeit checkout")
        elif snipeit_checkout(env["ASSET_ID"]) != 0:
            return 1

        dprint(f'Run {idx} executing: "{actual}"')
        PROC = subprocess.Popen(shlex.split(actual), env=env)
        rc = PROC.wait()
        if rc != 0:
            dprint(f"Run {idx} failed with exit code {rc}.")
            exit_code = 1
        else:
            dprint(f"run {idx} is done")

    return exit_code


def main():
    script_dir = Path(__file__).resolve().parent

    device = os.environ.get("DEVICE")
    if not device:
        print(
            "DEVICE is not set, it has to name a device from "
            "scripts/ci/regression-scope/configs/devices"
        )
        return 1
    dprint("Device:", device)

    rules = os.environ.get(
        "RULES_FILE", "scripts/ci/regression-scope/configs/pr-regression-rules.json"
    )
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

    commands = collect_commands(script_dir, device, tests, rules)
    if not commands:
        dprint("No tests required to run for these changes.")
        return 0

    dprint("Commands to run:")
    for c in commands:
        dprint(c, "\n")

    return execute_commands(commands)


atexit.register(snipeit_cleanup)
for s in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
    signal.signal(s, _cleanup_handler)

if __name__ == "__main__":
    sys.exit(main())
