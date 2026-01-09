#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

DRIVE=$1
DRIVE_LABEL=CAPSULE_USB
FILES_DIR=dasharo-stability/capsule-update-files
CAPSULE_FILES_DIR=dl-cache/edk2

if [[ -z $1 ]]; then
    echo "Usage:
    $0 <flash_drive_device_file>
Example:
    sudo -E $0 /dev/sdc
Note:
    must be run as super user"
    exit 1
fi

if [[ $USER != 'root' ]]; then
    echo "$0 has to be run as root"
    echo "Example:"
    echo "    sudo -E $0 /dev/sdc"
    exit 1
fi

if [[ ! -f $CAPSULE_FW_FILE ]]; then
    echo "CAPSULE_FW_FILE must be a valid capsule, right now CAPSULE_FW_FILE=$CAPSULE_FW_FILE"
    exit 1
fi

if ! [ -b $DRIVE ]; then
    echo "drive $DRIVE doesn't exist"
    exit 1
fi

# try to unmount, fails if not mounted
udisksctl unmount -b $DRIVE || true
# format to fat32
mkfs.vfat -I $DRIVE   # requires root privilege
fatlabel $DRIVE $DRIVE_LABEL
sleep 1
# mount drive
udisksctl mount -b $DRIVE
mount_point=$(udisksctl info -b $DRIVE | grep -Po '^ *MountPoints: *\K.*')

# create boot directories
mkdir -p "$mount_point"/EFI/BOOT

CAPSULE_BASENAME=$(realpath "$CAPSULE_FW_FILE")
CAPSULE_BASENAME=$(basename "$CAPSULE_BASENAME")
CAPSULE_BASENAME="${CAPSULE_BASENAME%.*}"

# copy files
cp osfv-test-data/uefi-shell/Shell.efi "$mount_point"/EFI/BOOT/bootx64.efi
cp $FILES_DIR/CapsuleApp.efi "$mount_point"/CapsuleApp.efi
cp $FILES_DIR/capsule-update-startup.nsh "$mount_point"/startup.nsh
cp $FILES_DIR/variable_capsule_file.nsh "$mount_point"/variable_capsule_file.nsh
cp $FILES_DIR/variable_step.nsh "$mount_point"/variable_step.nsh
cp $CAPSULE_FILES_DIR/${CAPSULE_BASENAME}_wrong_cert.cap "$mount_point"/wrong_cert.cap
cp $CAPSULE_FILES_DIR/${CAPSULE_BASENAME}_invalid_guid.cap "$mount_point"/invalid_guid.cap
cp $CAPSULE_FILES_DIR/${CAPSULE_BASENAME}_invalid_btg_signature.cap "$mount_point"/invalid_btg_signature.cap
cp $CAPSULE_FW_FILE "$mount_point"/valid_capsule.cap
cp $FW_FILE "$mount_point"/pre-capsule.rom


# cleanup
udisksctl unmount -b $DRIVE

echo "Done"
