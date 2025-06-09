#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# Get lines that start with ID, store each line as array element
mapfile -t active < <(grep -Rh "^[A-Z]\{1,6\}[0-9]\{3\}\.[0-9]\{3\}" dasharo-*)

# Get all IDs listed after 'Previous IDs', each as separate array element
mapfile -t deprecated < <(grep -Rh "^    ...    Previous IDs: " dasharo-* | cut -d' ' -f 11- --output-delimiter=$'\n')

# Merge the arrays, adding `DEPRECATED` after each of `Previous IDs`
all=( "${active[@]}" "${deprecated[@]/%/ DEPRECATED}" )

# Sort the result - WARNING: doesn't support names with `*` or `?`
IFS=$'\n'
all=($(sort <<<"${all[*]}"))
unset IFS

# Print each element in separate line
printf '%s\n' "${all[@]}"
