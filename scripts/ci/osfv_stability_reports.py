#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import json
import os
import pickle
import subprocess
import sys
from pathlib import Path

from robot.api import ExecutionResult

LOGS_DIR = (
    Path(os.getenv("LOGS_DIR"))
    if os.getenv("LOGS_DIR") is not None
    else Path("/srv/nfs/logs/osfv_stability/ci_logs")
)

GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
CLEAR = "\033[0m"

REBOT_SPLITTER = "./scripts/lib/rebot_splitter.py"
SUITES_TO_SKIP_GLOB = ["merged"]  # Might make sense to add: "basic-platform-setup"


def get_recovered_path(out_xml: Path) -> Path:
    return out_xml.with_name(out_xml.name + "_recovered")


def get_date_suite_dir(suite_dir: Path) -> str:
    return "_".join(suite_dir.name.split("_")[-6:])


def suite_pass_percentage(out_xml: Path) -> float:
    try:
        result = ExecutionResult(out_xml)
    except:
        print(f"{YELLOW}WARNING{CLEAR}: invalid xml: {out_xml}")
        try:
            recovered_path = get_recovered_path(out_xml)
            out = subprocess.run(
                ["xmllint", f"{out_xml}", "--recover", "--output", f"{recovered_path}"],
                capture_output=True,
            )
            print(out.stderr.decode("utf-8"))
            result = ExecutionResult(recovered_path)
        except Exception as e:
            print(
                f"{RED}WARNING{CLEAR}: could not recover xml, skipping suite: {out_xml}"
            )
            print(e)
            return 0
    stats = result.statistics.total
    total = stats.passed + stats.failed
    if total == 0:
        return 0.0
    return stats.passed / total * 100


def suite_runtime_seconds(out_xml: Path) -> float:
    try:
        result = ExecutionResult(out_xml)
    except:
        print(f"{YELLOW}WARNING{CLEAR}: invalid xml: {out_xml}")
        try:
            recovered_path = get_recovered_path(out_xml)
            out = subprocess.run(
                ["xmllint", f"{out_xml}", "--recover", "--output", f"{recovered_path}"],
                capture_output=True,
            )
            print(out.stderr.decode("utf-8"))
            result = ExecutionResult(recovered_path)
        except Exception as e:
            print(
                f"{RED}WARNING{CLEAR}: could not recover xml, skipping suite: {out_xml}"
            )
            print(e)
            return 0
    return result.suite.elapsedtime / 1000.0


def is_suite_skipped(out_xml: Path) -> bool:
    try:
        result = ExecutionResult(out_xml)
    except:
        print(f"{YELLOW}WARNING{CLEAR}: invalid xml: {out_xml}")
        try:
            recovered_path = get_recovered_path(out_xml)
            out = subprocess.run(
                ["xmllint", f"{out_xml}", "--recover", "--output", f"{recovered_path}"],
                capture_output=True,
            )
            print(out.stderr.decode("utf-8"))
            result = ExecutionResult(recovered_path)
        except Exception as e:
            print(
                f"{RED}WARNING{CLEAR}: could not recover xml, skipping suite: {out_xml}"
            )
            print(e)
            return True
    stats = result.statistics.total
    return stats.passed == 0 and stats.failed == 0


def parse():
    TEST_DATA = {}
    for revision_run in LOGS_DIR.iterdir():
        if not revision_run.is_dir():
            continue
        for run_date_dir in revision_run.iterdir():
            if not run_date_dir.is_dir():
                continue
            revision = str(revision_run.name).split("_")
            branch, commit = ("_".join(revision[:-1]), revision[-1])
            RUN_DATA = {
                "branch": branch,
                "commit": commit,
                "run_date": run_date_dir.name,
                "total_runs": 0,
                "total_suites": 0,
                "total_pass_pct_sum": 0,
                "passes_per_device": {},
                "passes_per_suite": {},
                "run_runtimes": {},
                "runtime_per_device": {},
                "runtime_per_suite": {},
                "runtime_per_suite_per_device": {},
            }
            pkl_filename = revision_run.name + ".pkl"
            pkl_file_path = revision_run.absolute() / Path(pkl_filename)
            if pkl_file_path.exists():
                with open(pkl_file_path, "rb") as cache_file:
                    RUN_DATA = pickle.load(cache_file)
                    TEST_DATA[revision_run.name] = RUN_DATA
                    continue

            for run_dir in run_date_dir.glob("run*"):
                if not run_dir.is_dir():
                    continue

                run_name = run_dir.name
                run_total_time = 0.0

                for device_dir in run_dir.iterdir():
                    if not device_dir.is_dir():
                        continue

                    device = device_dir.name
                    device_total_time = 0.0

                    for suite_dir in device_dir.iterdir():
                        if not suite_dir.is_dir():
                            continue

                        out_files = list(suite_dir.glob("*_out.xml")) + list(
                            suite_dir.glob("*_output.xml")
                        )
                        if (
                            "merged" in suite_dir.name
                        ):  # merged need to be unpacked and left alone
                            date = get_date_suite_dir(suite_dir)
                            for out_f in out_files:
                                subprocess.run(
                                    [
                                        REBOT_SPLITTER,
                                        out_f.absolute(),
                                        device_dir.absolute(),
                                        date,
                                    ],
                                    stdout=subprocess.DEVNULL,
                                )

                        if any(
                            ex.lower() in suite_dir.name for ex in SUITES_TO_SKIP_GLOB
                        ):
                            continue

                        if not out_files:
                            continue
                        if is_suite_skipped(out_files[0]):
                            continue
                        out_xml = out_files[0]

                        pct = suite_pass_percentage(out_xml)
                        RUN_DATA["total_suites"] += 1
                        RUN_DATA["total_pass_pct_sum"] += pct
                        RUN_DATA["passes_per_device"].setdefault(device, []).append(pct)

                        suite_name = suite_dir.name.split("_")[0]
                        RUN_DATA["passes_per_suite"].setdefault(suite_name, []).append(
                            pct
                        )

                        runtime = suite_runtime_seconds(out_xml)
                        device_total_time += runtime
                        RUN_DATA["runtime_per_device"].setdefault(device, []).append(
                            runtime
                        )
                        RUN_DATA["runtime_per_suite"].setdefault(suite_name, []).append(
                            runtime
                        )
                        RUN_DATA["runtime_per_suite_per_device"].setdefault(
                            device, {}
                        ).setdefault(suite_name, []).append(runtime)

                if device_total_time > run_total_time:
                    run_total_time = device_total_time

                if run_total_time > 0:
                    RUN_DATA["run_runtimes"][run_name] = run_total_time

                RUN_DATA["total_runs"] += 1

        TEST_DATA[revision_run.name] = RUN_DATA
        with open(pkl_file_path, "wb") as cache_file:
            pickle.dump(RUN_DATA, cache_file)
    return TEST_DATA


def print_results(test_data):
    for revision in test_data:
        run_data = test_data[revision]
        branch = run_data["branch"]
        commit = run_data["commit"]
        total_pass_percentage = (
            run_data["total_pass_pct_sum"] / run_data["total_suites"]
            if run_data["total_suites"]
            else 0.0
        )

        passes_per_device_pct = {
            dev: sum(v) / len(v) for dev, v in run_data["passes_per_device"].items()
        }

        passes_per_suite_pct = {
            suite: sum(v) / len(v) for suite, v in run_data["passes_per_suite"].items()
        }

        average_run_time = (
            sum(run_data["run_runtimes"].values()) / len(run_data["run_runtimes"])
            if run_data["run_runtimes"]
            else 0.0
        )

        average_runtime_per_device = {
            dev: sum(v) / len(v) for dev, v in run_data["runtime_per_device"].items()
        }

        average_runtime_per_suite = {
            suite: sum(v) / len(v) for suite, v in run_data["runtime_per_suite"].items()
        }

        average_runtime_per_suite_per_device = {
            device: {suite: sum(times) / len(times) for suite, times in suites.items()}
            for device, suites in run_data["runtime_per_suite_per_device"].items()
        }
        print(f"{GREEN}Report from {run_data["total_runs"]} runs:{CLEAR}")
        print(f'Branch "{GREEN}{branch}{CLEAR}"')
        print(f'Commit "{GREEN}{commit}{CLEAR}"')
        print(f"\n{GREEN}Total PASS percentage: {total_pass_percentage:.2f}{CLEAR} %")

        print(f"\nPer device PASS percentages:")
        for device in passes_per_device_pct:
            print(f"\t{device}: {GREEN}{passes_per_device_pct[device]:.2f}{CLEAR} %")

        print(f"\nPer suite PASS percentages:")
        for suite in passes_per_suite_pct:
            print(f"\t{suite}: {GREEN}{passes_per_suite_pct[suite]:.2f}{CLEAR} %")

        print(
            f"\n{YELLOW}Total run time: {YELLOW}{sum(run_data["run_runtimes"].values())}{CLEAR} s"
        )
        print(f"\nAverage run time: {YELLOW}{average_run_time:.2f}{CLEAR} s")

        print(f"\nAverage run time per device:")
        for device in average_runtime_per_device:
            print(
                f"\t{device}: {YELLOW}{average_runtime_per_device[device]:.2f}{CLEAR} s"
            )

        print(f"\nAverage run time per suite:")
        for suite in average_runtime_per_suite:
            print(f"\t{suite}: {YELLOW}{average_runtime_per_suite[suite]:.2f}{CLEAR} s")

        # print(f"\nAverage run time per suite per device:")
        # for device, suites in average_runtime_per_suite_per_device.items():
        #     print(f"\t{device}:")
        #     for suite, avg in suites.items():
        #         print(f"\t\t{suite}: {YELLOW}{avg:.2f}{CLEAR} s")


def json_results(test_data):
    print(json.dumps(test_data))


def main():
    if not LOGS_DIR.exists():
        print(f"No logs available at {LOGS_DIR}. First run osfv_stability_run.py")
    parsed_results = parse()
    if any(h in sys.argv for h in ["--help", "-h"]):
        print(f"Usage: {sys.argv[0]} [--json]")
    elif "--json" in sys.argv:
        json_results(parsed_results)
        return 0
    else:
        print_results(parsed_results)


if __name__ == "__main__":
    main()
