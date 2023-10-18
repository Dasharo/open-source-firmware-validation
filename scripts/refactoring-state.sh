#!/usr/bin/env bash

kwds_to_remove=(
"Select Option From List"
"Read Option List Contents"
"Get Relative Menu Position"
"Check If Tianocore Setting Is Enabled In Current Menu"
"Change To Next Option In Setting"
"Reenter Menu"
"Check If Submenu Exists Tianocore"
"Get Menu Reference Tianocore"
"Enter Submenu In Tianocore"
"Change Numeric Value Of Setting"
"Enter Dasharo Submenu Snapshot"
)

echo "Keywords that should not be used, but are still used:"
for file in $(find . -type f -name "*.robot"); do
  for kwd in "${kwds_to_remove[@]}"; do
      grep -i -n -H "$kwd" "$file"
  done
done
