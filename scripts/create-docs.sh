#!/usr/bin/env bash

TEMP_DIR=$(mktemp -d)
if [[ $1 == "UEFI" ]]; then
    IS_UEFI=true
    echo "Generating UEFI version of the documentation"
elif [[ $1 == "DCU" ]]; then
    IS_UEFI=false
    echo "Generating DCU version of the documentation"
else
    echo "Please provide version of the documentation: (UEFI/DCU)"
    echo "Exit"
    exit 0
fi

cat keywords.robot > "$TEMP_DIR/all-keywords.robot"
find lib -name "*.robot" -type f | while read -r file; do
    if [[ $(basename "$file") == "dcu.robot" && $IS_UEFI == 'true' ]]; then
        echo "[DEBUG] Skip dcu.robot"
        continue
    elif [[ $(basename "$file") == "uefi-setup-menu.robot" && $IS_UEFI == 'false' ]]; then
        echo "[DEBUG] Skip uefi-setup-menu.robot"
        continue
    else
        cat "$file" >> "$TEMP_DIR/all-keywords.robot"
    fi
done

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
