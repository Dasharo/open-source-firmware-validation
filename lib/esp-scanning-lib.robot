*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${TINYCORE_URL}=                https://distro.ibiblio.org/tinycorelinux/14.x/x86/release/CorePlus-14.0.iso
${DTS_URL}=                     https://dl.3mdeb.com/open-source-firmware/DTS/v1.2.8/dts-base-image-v1.2.8.iso
${DISK_IMAGE_URL}=              https://cloud.3mdeb.com/index.php/s/BwLyjHT9fRncXMY/download/image.img

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
        Download To Host Cache
        ...    image.img
        ...    ${DISK_IMAGE_URL}
        ...    031560742d6b337ed684cfdb90d3c5eb48f13576f4751b33095e8d1566d72e83
        Add HDD To Qemu    img_name=${DL_CACHE_DIR}/image.img
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Remove All Supported Systems From Efi
            Execute Command In Terminal    wget ${DISK_IMAGE_URL} -O image.img    timeout=180s
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
