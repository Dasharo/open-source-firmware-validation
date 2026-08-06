#!/usr/env/bash
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

docker build -t "ghcr.io/dasharo/osfv-ci:$(date +%d-%m-%Y)" -f .ci/Dockerfile .
