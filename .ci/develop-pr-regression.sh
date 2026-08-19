#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# One run tests one device, so that every device is scheduled, reported and
# retried on its own. DEVICE names one of the
# scripts/ci/regression-scope/configs/devices/*.json entries.
export DEVICE="${DEVICE:?DEVICE is not set, it has to name the device to test}"
BASE_BRANCH="${BASE_BRANCH:-develop}"

# The tests run straight from the pull request checkout, there is nothing to
# keep reproducible by a clean tree.
export ALLOW_DIRTY=1

# osfv_cli reserves the device in SnipeIT and the tests query it for the asset
# data. Both read a config file, while CI hands the credentials over as an
# environment variable.
setup_snipeit_config() {
  local _config

  if [ -n "${SNIPEIT_CONFIG:-}" ]; then
    echo "The snipeit config file: ${SNIPEIT_CONFIG} does not exist!"
    exit 1
  fi

  _config="${SNIPEIT_CONFIG_FILE_PATH:-${HOME}/.osfv/snipeit.yml}"
  mkdir -p "$(dirname "$_config")"
  printf '%s\n' "$SNIPEIT_CONFIG" > "$_config"
  chmod 600 "$_config"
  export SNIPEIT_CONFIG_FILE_PATH="$_config"
}

git submodule update --init --checkout --recursive
# The scope of the regression is what the pull request changed against the base
# branch, so the comparison base has to be there.
git fetch origin "$BASE_BRANCH"

setup_snipeit_config

scripts/ci/develop_pr_auto_regression.py
