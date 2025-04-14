#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

DRIVE=$1
DRIVE_LABEL=CAPSULE_USB
DRIVE_MOUNT_DIR=/run/media/$USER/$DRIVE_LABEL
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
mkfs.vfat $DRIVE
fatlabel $DRIVE $DRIVE_LABEL
sleep 1
# mount drive

udisksctl mount -b $DRIVE

# create boot directories
mkdir -p $DRIVE_MOUNT_DIR/EFI/BOOT

CAPSULE_BASENAME=$(realpath "$CAPSULE_FW_FILE")
CAPSULE_BASENAME=$(basename "$CAPSULE_BASENAME")
CAPSULE_BASENAME="${CAPSULE_BASENAME%.*}"

# copy files
cp $FILES_DIR/Shell.efi $DRIVE_MOUNT_DIR/EFI/BOOT/bootx64.efi
cp $FILES_DIR/CapsuleApp.efi $DRIVE_MOUNT_DIR/CapsuleApp.efi
cp $FILES_DIR/capsule-update-startup.nsh $DRIVE_MOUNT_DIR/startup.nsh
cp $FILES_DIR/variable_capsule_file.nsh $DRIVE_MOUNT_DIR/variable_capsule_file.nsh
cp $FILES_DIR/variable_step.nsh $DRIVE_MOUNT_DIR/variable_step.nsh
cp $CAPSULE_FILES_DIR/${CAPSULE_BASENAME}_wrong_cert.cap $DRIVE_MOUNT_DIR/wrong_cert.cap
cp $CAPSULE_FILES_DIR/${CAPSULE_BASENAME}_invalid_guid.cap $DRIVE_MOUNT_DIR/invalid_guid.cap
cp $CAPSULE_FW_FILE $DRIVE_MOUNT_DIR/valid_capsule.cap

# cleanup
udisksctl unmount -b $DRIVE

echo "Done"
