#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

from __future__ import annotations

import re
import subprocess
import sys
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

    if not top_suites:
        raise SystemExit("ERROR: No top-level suites found in output.xml")

    for suite in top_suites:
        suite_name = suite.name
        suite_dir = out_root / safe_dir_name(suite_name)
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
            "output.xml",
            "--log",
            "log.html",
            "--report",
            "report.html",
            str(input_xml),
        ]

        print(f"{GREEN}{suite_name}{RESET} -> {suite_dir}")
        subprocess.run(cmd, check=True)

    print(f"{GREEN}Created per-suite results under:{RESET} {out_root}")


if __name__ == "__main__":
    main()
