#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from robot.api import ExecutionResult

GREEN = "\033[92m"
RESET = "\033[0m"


def safe_dir_name(name: str) -> str:
    # Windows + Linux safe-ish folder name
    name = name.strip()
    name = re.sub(r"[<>:\"/\\|?*\x00-\x1F]", "_", name)
    name = re.sub(r"\s+", " ", name)
    return name[:150] if len(name) > 150 else name


def main() -> None:
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <out.xml> <output_dir>")
        exit(1)

    input_xml = Path(sys.argv[1]).resolve()
    if not input_xml.exists():
        raise SystemExit(f"ERROR: {input_xml} not found")

    out_root = Path(sys.argv[2]).resolve()
    out_root.mkdir(parents=True, exist_ok=True)

    result = ExecutionResult(str(input_xml))
    top = result.suite
    top_suites = list(top.suites)

    run_date = sys.argv[3]
    if not top_suites:
        print("No top-level suites found. Treating the available suite as top-level.")
        suite_dir = input_xml.parent
        new_suite_dir_name = safe_dir_name(top.name) + f"_{run_date}"
        new_suite_dir = suite_dir.parent / new_suite_dir_name
        shutil.move(str(suite_dir), str(new_suite_dir))
        # Rename the log, report, and output files
        for file in new_suite_dir.glob("*"):
            new_file_name = file.name
            # Modify the file names if they match the output files
            if "_out.xml" in file.name:
                new_file_name = f"{top.name}_{run_date}_out.xml"
            elif "_log.html" in file.name:
                new_file_name = f"{top.name}_{run_date}_log.html"
            elif "_report.html" in file.name:
                new_file_name = f"{top.name}_{run_date}_report.html"
            elif "_debug.log" in file.name:
                new_file_name = f"{top.name}_{run_date}_debug.log"

            new_file = new_suite_dir / new_file_name
            file.rename(new_file)
            print(f"{GREEN}Results under:{RESET} {new_suite_dir}")
            return 0

    run_date = sys.argv[3]

    for suite in top_suites:
        suite_name = suite.name
        suite_dir = out_root / (safe_dir_name(suite_name) + f"_{run_date}")
        suite_dir.mkdir(parents=True, exist_ok=True)

        # One rebot run per suite:
        # - filter with --suite
        # - write output.xml/log.html/report.html into the suite folder
        cmd = [
            "rebot",
            "--nostatusrc",
            "--suite",
            suite_name,
            "--outputdir",
            str(suite_dir),
            "--output",
            f"{suite_name}_{run_date}_output.xml",
            "--log",
            f"{suite_name}_{run_date}_log.html",
            "--report",
            f"{suite_name}_{run_date}_report.html",
            str(input_xml),
        ]

        print(f"{GREEN}{suite_name}{RESET} -> {suite_dir}")
        subprocess.run(cmd, check=True)

    print(f"{GREEN}Merged results under:{RESET} {input_xml.parent}")


if __name__ == "__main__":
    main()
