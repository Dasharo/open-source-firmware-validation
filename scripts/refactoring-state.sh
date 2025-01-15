#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

kwds_to_remove=(
"Select Option From List"
"Read Option List Contents"
"Get Relative Menu Position"
"Check If Tianocore Setting Is Enabled In Current Menu"
"Change To Next Option In Setting"
"Check If Submenu Exists Tianocore"
"Get Menu Reference Tianocore"
"Enter Submenu In Tianocore"
"Change Numeric Value Of Setting"
"Enter Dasharo Submenu Snapshot"
"iPXE DTS"
"Launch To DTS Shell"
"Check IPXE Appears Only Once"
"IPXE Dhcp"
"RteCtrl Power On"
"RteCtrl Power Off"
"RteCtrl Relay"
"Get RTE Relay State"
"Sonoff API Setup"
"Sonoff Power Off"
"Sonoff Power On"
"Get Sonoff State"
"RTE REST APU Setup"
"RTE REST APU Setup"
"RteCtrl Get GPIO State"
"Check That USB Devices Are Detected"
"Switch To Root User In Ubuntu Server"
"Get Slot Count"
"Get USB Slot Count"
"Get All USB"
"Enable Option In USB Configuration Submenu"
"Disable Option In USB Configuration Submenu"
"Enable Option In Submenu"
"Disable Option In Submenu"
"Get Intel ME Mode State"
"Power Cycle Off"
"Rte Relay"
"Rte Relay Set"
"Coldboot Via RTE Relay"
"Download To Host Cache"
"Download ISO And Mount As USB"
"Upload And Mount DTS Flash ISO"
"Prepare Required Files For Qemu"
"Get Coreboot Tools From Cloud"
"Get Cbmem From Cloud"
"Get Flashrom From Cloud"
"Get Cbfstool From Cloud"
)

echo "Keywords that should not be used, but are still used:"
find . -type f -name "*.robot" | while IFS= read -r file; do
  for kwd in "${kwds_to_remove[@]}"; do
      grep -i -n -H "$kwd" "$file"
  done
done

vars_to_remove=(
"PIKVM_IP"
"DL_CACHE_DIR"
)

echo "Global variables that should not be used, but are still used:"
find . -type f -name "*.robot" | while IFS= read -r file; do
  for var in "${vars_to_remove[@]}"; do
      grep -n -H "$var" "$file"
  done
done

resources_to_remove=(
"dl-cache.robot"
)

echo "Resources that should not be used, but are still used:"
find . -type f -name "*.robot" | while IFS= read -r file; do
  for resource in "${resources_to_remove[@]}"; do
      grep -n -H "$resource" "$file"
  done
done
