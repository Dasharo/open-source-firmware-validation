#!/usr/bin/env bash

TEMP_DIR=$(mktemp -d)

cat keywords.robot > "$TEMP_DIR/all-keywords.robot"
find lib -name "*.robot" -exec cat {} + >> "$TEMP_DIR/all-keywords.robot"

libdoc "$TEMP_DIR/all-keywords.robot" "$TEMP_DIR/all-keywords.html" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "libdoc command failed"
  exit 1
fi

cp "$TEMP_DIR/all-keywords.html" ./docs

rm "$TEMP_DIR/all-keywords.robot"
rm "$TEMP_DIR/all-keywords.html"
rmdir "$TEMP_DIR"

echo "Documentation generated and saved as all-keywords.html"
