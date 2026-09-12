#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

TEMP_DIR=$(mktemp -d)
FILE_NAME="$TEMP_DIR/all-keywords.robot"
ROBOT_JSON="$TEMP_DIR/all-keywords.robot.json"
COMBINED_JSON="$TEMP_DIR/all-keywords.combined.json"
QEMU_MONITOR_PLACEHOLDER="$TEMP_DIR/qemu-monitor-placeholder"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

python3 scripts/create-docs.py "$FILE_NAME"

libdoc --format JSON "$FILE_NAME" "$ROBOT_JSON" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "libdoc command failed"
  exit 1
fi

touch "$QEMU_MONITOR_PLACEHOLDER"

python_libdoc_json=()
while IFS= read -r -d '' python_library; do
  libdoc_input="$python_library"
  if [ "$python_library" = "lib/QemuMonitor.py" ]; then
    libdoc_input="${python_library}::${QEMU_MONITOR_PLACEHOLDER}"
  fi

  python_json="$TEMP_DIR/$(echo "$python_library" | tr '/.' '__').json"
  libdoc --format JSON "$libdoc_input" "$python_json" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "libdoc command failed for $python_library"
    exit 1
  fi
  python_libdoc_json+=("$python_json")
done < <(find lib -type f -name '*.py' -print0 | sort -z)

if [ "${#python_libdoc_json[@]}" -gt 0 ]; then
  python3 scripts/merge-libdoc-json.py \
    "$ROBOT_JSON" \
    "$COMBINED_JSON" \
    "${python_libdoc_json[@]}"
else
  cp "$ROBOT_JSON" "$COMBINED_JSON"
fi

libdoc --format HTML "$COMBINED_JSON" "$TEMP_DIR/all-keywords.html" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "libdoc command failed"
  exit 1
fi

cp "$TEMP_DIR/all-keywords.html" ./docs/index.html

echo "Documentation generated and saved as ./docs/index.html"
