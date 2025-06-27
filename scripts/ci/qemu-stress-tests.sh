#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

export RTE_IP=127.0.0.1
export CONFIG=qemu-selftests
export SNIPEIT_NO=1


suites=(
  "self-tests/setup-and-boot-menus.robot"
)

./scripts/run.sh "${suites[@]}" -- --include stress-test
