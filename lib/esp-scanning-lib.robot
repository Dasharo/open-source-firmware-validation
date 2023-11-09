*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${SHIMX64_URL}=         https://cloud.3mdeb.com/index.php/s/TipPHgsCj6MCZHi/download/shimx64.efi
${GRUBX64_URL}=         https://cloud.3mdeb.com/index.php/s/e2JjYANjMsgyXtS/download/grubx64.efi
${TINYCORE_URL}=        https://distro.ibiblio.org/tinycorelinux/14.x/x86/release/CorePlus-14.0.iso
${DTS_URL}=             https://dl.3mdeb.com/open-source-firmware/DTS/v1.2.8/dts-base-image-v1.2.8.iso
${DISK_IMAGE_URL}=      https://cloud.3mdeb.com/index.php/s/BwLyjHT9fRncXMY/download/image.img


*** Keywords ***
Prepare EFI Partition With System Files
    [Documentation]    Prepares a bootable EFI partition with OS files
    ...    by mounting a hard drive in Qemu, or creating files on the DUT
    ...    via PiKVM

    IF    "${MANUFACTURER}" == "QEMU"
        Add HDD To Qemu    img_name=${DL_CACHE_DIR}/image.img
    ELSE
        IF    "${DUT_CONNECTION_METHOD}" == "pikvm"
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Remove All Supported Systems From Efi
            Execute Command In Terminal    wget ${DISK_IMAGE_URL} -O image.img
            Execute Command In Terminal    mkdir /mnt/disk_image
            Execute Command In Terminal    losetup /dev/loop99 -P ./image.img
            Execute Command In Terminal    mount /dev/loop99p1 /mnt/disk_image
            Execute Command In Terminal    cp -r /mnt/disk_image/EFI/* /boot/efi/EFI/
            Execute Command In Terminal    sync
        ELSE
            Skip    unsupported
        END
    END

Clear Out EFI Partition
    [Documentation]    Prepares a bootable EFI partition with OS files
    ...    by unmounting the hard drive in Qemu, or erasing files on the DUT
    ...    via PiKVM

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

Check Boot Menu For All Supported Systems
    [Documentation]    This keyword scans the boot menu, and depending on the
    ...    mode verifies that all or none of the supported OSes are listed.
    ...    Available modes:
    ...    normal - default, checks that all supported systems are listed in
    ...    boot menu
    ...    empty - expects the boot menu to be empty, no additional OSes listed
    ...    double_entry_check - additionally verifies there is only one entry
    ...    per OS
    [Arguments]    ${mode}=normal
    Set DUT Response Timeout    30s

    # You need to scroll down to see some of the entries. As a result,
    # simply getting a single menu construction won't do.

    IF    "${mode}"!="empty"
        ${boot_list_a}=    Get Boot Menu Construction
        Press Key N Times    1    ${ARROW_UP}
        ${boot_list_b}=    Get Menu Construction    Qubes OS    0    0
        ${boot_list}=    Merge Two Lists    ${boot_list_a}    ${boot_list_b}
    ELSE
        ${boot_list}=    Get Boot Menu Construction
    END

    IF    "${mode}"=="empty"
        Only N Occurrences    ${boot_list}    0    *Suse*
        Only N Occurrences    ${boot_list}    0    *RedHat*
    ELSE
        Only N Occurrences    ${boot_list}    2    *Suse*
        Only N Occurrences    ${boot_list}    2    *RedHat*
    END
    @{systems}=    Create List    Fedora    OpenSuse    Windows Boot Manager \(on    CentOS
    ...    Dasharo Tools Suite    Debian
    FOR    ${system}    IN    @{systems}
        IF    "${mode}"=="empty"
            Should Not Contain Match    ${boot_list}    *${system}*
        END
        IF    "${mode}"=="normal"
            Should Contain Match    ${boot_list}    *${system}*
        END
        IF    "${mode}"=="double_entry_check"
            Only N Occurrences    ${boot_list}    1    *${system}*
        END
    END

Only N Occurrences
    [Documentation]    This keyword ensures that there's Only N Occurrences
    ...    of a given entry in a list
    [Arguments]    ${list}    ${n}    ${entry}
    ${x}=    Get Match Count    ${list}    ${entry}
    Should Be Equal As Integers    ${x}    ${n}

Remove All Supported Systems From Efi
    @{systems}=    Create List
    ...    Fedora    Suse    opensuse    Microsoft
    ...    Redhat    Centos    qubes    DTS    debian
    FOR    ${system}    IN    @{systems}
        Execute Command In Terminal    rm -r /boot/efi/EFI/${system}
    END
