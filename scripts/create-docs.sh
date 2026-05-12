#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

TEMP_DIR=$(mktemp -d)
FILE_NAME="$TEMP_DIR/all-keywords.robot"
HTML_FILE="$TEMP_DIR/all-keywords.html"

python3 scripts/create-docs.py "$FILE_NAME" "$HTML_FILE"

if [ $? -ne 0 ]; then
  echo "documentation generation failed"
  exit 1
fi

cp "$HTML_FILE" ./docs/index.html

rm "$TEMP_DIR/all-keywords.robot"
rm "$HTML_FILE"
rmdir "$TEMP_DIR"

echo "Documentation generated and saved as ./docs/index.html"
