#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

usage() {
  echo "This scripts renames keywords across the project from \"old_name\" to\"new_name\""
  echo "Usage: $0 old_name new_name"
}

if [ "$#" -ne 2 ]; then
  echo "Error: Both old and new keyword names are required."
  usage
  exit 1
fi

old_name="$1"
new_name="$2"

# See: https://robotidy.readthedocs.io/en/stable/transformers/RenameKeywords.html#replace-pattern
robotidy --transform RenameKeywords \
  --verbose \
  -c "RenameKeywords:replace_pattern=(?i)^${old_name}\$:replace_to=${new_name}" .
