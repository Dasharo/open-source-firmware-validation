#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# -r - produce raw output, don't escape special characters and don't quote
# For each doc, produce line containing:
# - "_id DEPRECATED" if doc has `changed_to` field
# - "_id name" otherwise
jq -r '
  .[].doc |
    ._id + " " +
      if has("changed_to") then
        "DEPRECATED"
      else
        .name
      end
  ' test_cases.json
