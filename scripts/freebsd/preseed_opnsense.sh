#!/bin/sh

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

LABEL=OPNBOOT
INSTALLER_ROOT_PARTITION=/dev/da0p4
INSTALLER_MOUNT_DIR=/mnt
BSDINSTALL_DIR=/usr/libexec/bsdinstall
TARGET_FILES="opnsense-zfs zfsboot"

echo FreeBSD+OPNsense bsdinstall modifier
echo
echo "WARNING: This script is supposed to be executed on any FreeBSD-compatible system."
echo "Please connect OPNsense Installer USB stick and verify it's root partition device name to be: " ${INSTALLER_ROOT_PARTITION}
echo "Please type 'yes' to continue."
echo

read ANSWER_WARN
if [ $ANSWER_WARN != yes ];
then
    exit 1;
fi

# patch_esp_command $new_esp_label $file_prefix $file_to_patch
patch_esp_command()
{
    local new_esp_label="$1" file_prefix="$2" file_to_patch="$3"
    echo
    echo ${new_esp_label} "->" ${file_prefix}/${file_to_patch}

    awk -v sq="'" -v dq='"' -v ROOT_LABEL=${new_esp_label} '/^NEWFS_ESP=/ { print "NEWFS_ESP=" sq "newfs_msdos -L " ROOT_LABEL " " dq "%s" dq sq; next; }; { print; }' ${file_prefix}/${file_to_patch} > /tmp/${file_to_patch}
    echo " -- DIFF:"
    diff /tmp/${file_to_patch} ${INSTALLER_MOUNT_DIR}${BSDINSTALL_DIR}/${file_to_patch}
    echo "--- END OF DIFF"

    echo Do you want to apply? Type 'yes'.
    echo

    read ANSWER_DIFF
    if [ $ANSWER_DIFF != yes ];
    then
        return
    fi
    mv /tmp/${file_to_patch} ${file_prefix}/${file_to_patch}
    chmod +x ${file_prefix}/${file_to_patch}
}

umount ${INSTALLER_MOUNT_DIR}
mount -w ${INSTALLER_ROOT_PARTITION} ${INSTALLER_MOUNT_DIR}
ls -l ${INSTALLER_MOUNT_DIR}${BSDINSTALL_DIR}/*zfs*

for installer_file in ${TARGET_FILES}; do
    patch_esp_command ${LABEL} ${INSTALLER_MOUNT_DIR}${BSDINSTALL_DIR} ${installer_file}
done

umount ${INSTALLER_MOUNT_DIR}
echo "It is done."
