*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${TINYCORE_URL}=                https://distro.ibiblio.org/tinycorelinux/14.x/x86/release/CorePlus-14.0.iso
${DTS_URL}=                     https://dl.3mdeb.com/open-source-firmware/DTS/v1.2.8/dts-base-image-v1.2.8.iso
<<<<<<< HEAD
${DISK_IMAGE_PATH}=             ../osfv-test-data/image.img
=======
${DISK_IMAGE_URL}=              https://github.com/Dasharo/osfv-test-data/raw/main/image.img
>>>>>>> 71330910 (change cloud links to those from submodule)

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
        Copy File    ${DISK_IMAGE_PATH}    ${CURDIR}/../dl-cache/image.img
        Add HDD To Qemu    img_name=${DL_CACHE_DIR}/image.img
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Remove All Supported Systems From Efi
            Copy File    ${DISK_IMAGE_PATH}    ${CURDIR}
            Execute Command In Terminal    mkdir /mnt/disk_image
            Execute Command In Terminal    losetup /dev/loop99 -P ./image.img
            Execute Command In Terminal    mount /dev/loop99p1 /mnt/disk_image
            Execute Command In Terminal
            ...    rsync -a --ignore-existing --exclude /mnt/disk_image/EFI/Ubuntu /mnt/disk_image/EFI/Microsoft /mnt/disk_image/EFI/* /boot/efi/EFI/
            Execute Command In Terminal    sync
        ELSE
            Skip    unsupported
        END
    END

Clear Out EFI Partition
    [Documentation]    Prepares a bootable EFI partition with OS files
    ...    by unmounting the hard drive in Qemu, or erasing files on the DUT
    ...    via PiKVM

    Power On

    IF    "${MANUFACTURER}" == "QEMU"
        Remove Drive From Qemu
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Remove All Supported Systems From Efi
        ELSE
            Skip    unsupported
        END
    END

Remove All Supported Systems From Efi
    # We do not want to remove Ubuntu or Windows bootloaders
    @{dirs}=    Create List    Centos    debian    DTS    Fedora
    ...    opensuse    qubes    Redhat    Suse
    FOR    ${dir}    IN    @{dirs}
        Execute Command In Terminal    rm -r /boot/efi/EFI/${dir}
    END

Prepare Required Files For Qemu
    IF    "${MANUFACTURER}" == "QEMU"
        Download To Host Cache
        ...    dts-base-image-v1.2.8.iso
        ...    ${DTS_URL}
        ...    f42b59633dbcc16ecbd7c98a880c582c5235c22626d7204202c922f3a7fa231b
        Download To Host Cache
        ...    esp-scanning.img
        ...    ${DISK_IMAGE_URL}
        ...    a0cf9c6cc561585b375a7416a5bdb98caad4c48d22f87098844b6e294a3c0aff
        Download To Host Cache
        ...    CorePlus-14.0.iso
        ...    ${TINYCORE_URL}
        ...    5c0c5c7c835070f0adcaeafad540252e9dd2935c02e57de6112fb92fb5d6f9c5
    END
