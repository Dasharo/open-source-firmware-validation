#!/bin/bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

cat <<EOF
Release $(git describe --tags --abbrev=0)

## Major changes

### TODO

### TODO

## Self-Test Results

Tests are run using \`./scripts/osfv_stability_run.py\`.
The summary is generated from the test logs using \`./scripts/osfv_stability_reports.py\`.
For details check the \`OSFV Stability Checks\` section in the README.

__Disclaimer__

The stability test results show how many tests pass without any kind of human
intervention and can be run via an automated CI job.
The pass rates shown below are not an indicator of release test result
credibility.

---

$(uv run scripts/ci/osfv_stability_reports.py --latest 2>/dev/null)
EOF
