#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

TEMP_DIR=$(mktemp -d)

cat keywords.robot > "$TEMP_DIR/all-keywords.robot"
find lib -name "*.robot" -exec cat {} + >> "$TEMP_DIR/all-keywords.robot"

libdoc "$TEMP_DIR/all-keywords.robot" "$TEMP_DIR/all-keywords.html" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "libdoc command failed"
  exit 1
fi

cp "$TEMP_DIR/all-keywords.html" ./docs/index.html

rm "$TEMP_DIR/all-keywords.robot"
rm "$TEMP_DIR/all-keywords.html"
rmdir "$TEMP_DIR"

echo "Documentation generated and saved as ./docs/index.html"
