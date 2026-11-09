#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

"""Writes the DRTM criteria report of TrenchBoot runs, or checks the
expectation files with ``check``. docs/drtm-report.md describes both.

    scripts/drtm-report.py logs/pcengines-apu2/merged_<date> ...
    scripts/drtm-report.py check [FILE...]
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from drtm_report import expectations, report, trenchboot  # noqa: E402


def main(argv):
    if argv[:1] == ["check"]:
        errors = expectations.check(trenchboot.SOURCE, argv[1:])
        for error in errors:
            print(error, file=sys.stderr)
        return 1 if errors else 0
    return report.main(argv, [trenchboot.SOURCE], Path("logs/drtm-report"))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
