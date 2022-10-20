#!/bin/bash

STAND_IP=${RTE_IP:=192.168.4.233}
PXE_IP=${PXE_IP:=192.168.20.206}
PLATFORM=${PLATFORM:=msi-z690-a-ddr5}
AUTOFILL=${AUTOFILL:="0"}
CLOUD=${FIRMWARE:=m}

if [ $# -lt 1 ]; then
    echo ""
    echo "Usage: ./regression.sh <coreboot_rom>"
    echo "  <coreboot_rom> - full path to coreboot.rom binary"
    echo ""
    echo "Environment variables:"
    echo "  STAND_IP - STAND IP address (default: $RTE_IP)"
    echo "  PXE_IP   - PXE server IP address (default: $PXE_IP)"
    echo "  PLATFORM   - platform specific config - available:"
    echo "               - MSI PRO Z690-A DDR5: msi-pro-z690-a-ddr5"
    echo "  AUTOFILL - fill up spreadsheet with the test results (default: $AUTOFILL)"
    echo "  CLOUD - send logs from test to the cloud"
    exit
fi
