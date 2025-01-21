*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
# These are always installed, used in many different testing. We do not want
# to remove them during the ESP scanning testing.
@{SYSTEMS_ALWAYS_INSTALLED}=    Windows Boot Manager (on
...                             Ubuntu (on

# These are typically not installed. This suite will create appropriate paths
# and bootloader files for the ESP scanning testing purposes.
@{SYSTEMS_FOR_ESP_TESTING}=     Suse Boot Manager (on
...                             RedHat Boot Manager (on
...                             RedHat (on
...                             Fedora (on
...                             CentOS (on
...                             OpenSuse (on
...                             Debian (on
...                             Qubes OS (on


*** Keywords ***
Prepare EFI Partition With System Files
    [Documentation]    Prepares a bootable EFI partition with OS files
    ...    by mounting a hard drive in Qemu, or creating files on the DUT
    ...    via PiKVM

    Power On
    IF    "${MANUFACTURER}" == "QEMU"
        Add HDD To Qemu    img_name=${TEST_DATA_DIR}/esp-scanning/esp-scanning-disk.img
        # Add HDD To Qemu    img_name=esp-scanning-disk.img
    ELSE
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
        Remove All Supported Systems From Efi
        Send File To DUT    ${TEST_DATA_DIR}/esp-scanning/esp-scanning-disk.img    /tmp/image.img
        Execute Command In Terminal    mkdir /mnt/disk_image
        Execute Command In Terminal    losetup /dev/loop99 -P /tmp/image.img
        Execute Command In Terminal    mount /dev/loop99p1 /mnt/disk_image
        Execute Command In Terminal
        ...    rsync -a --ignore-existing --exclude /mnt/disk_image/EFI/Ubuntu /mnt/disk_image/EFI/Microsoft /mnt/disk_image/EFI/* /boot/efi/EFI/
        Execute Command In Terminal    sync
    END

Clear Out EFI Partition
    [Documentation]    Prepares a bootable EFI partition with OS files
    ...    by unmounting the hard drive in Qemu, or erasing files on the DUT
    ...    via PiKVM

    Power On

    IF    "${MANUFACTURER}" == "QEMU"
        Remove Drive From Qemu
    ELSE
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
        Remove All Supported Systems From Efi
    END

Remove All Supported Systems From Efi
    # We do not want to remove Ubuntu or Windows bootloaders
    @{dirs}=    Create List    Centos    debian    DTS    Fedora
    ...    opensuse    qubes    Redhat    Suse
    FOR    ${dir}    IN    @{dirs}
        Execute Command In Terminal    rm -r /boot/efi/EFI/${dir}
    END
