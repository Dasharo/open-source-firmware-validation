*** Settings ***
Metadata            ORDER_SENSITIVE

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Setup Esp Scanning Suite
Suite Teardown      Teardown Esp Scanning Suite

Default Tags        automated


*** Test Cases ***
ESP001.101 ESP Scan with OS-specific .efi files added (EDK2 UEFI)
    [Documentation]    This test aims to verify that any properly added .efi
    ...    files will have boot menu entries created for them.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP001.101 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    FOR    ${system}    IN    @{SYSTEMS_FOR_ESP_TESTING}
        Should Contain Match    ${boot_menu}    ${system}*
    END
    FOR    ${system}    IN    @{SYSTEMS_ALWAYS_INSTALLED}
        Should Contain Match    ${boot_menu}    ${system}*
    END

ESP003.101 ESP Scan ignores OSes on removable media (EDK2 UEFI)
    [Documentation]    This test aims to verify that the bootable /EFI
    ...    partitions of removable media are ignored by the scan and aren't
    ...    listed in boot menu, except for DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP003.101 not supported
    Power On
    Mount USB Disk Image    ${TEST_DATA_DIR}/iso/TinyCore-15.0.iso    required=${FALSE}
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Not Contain Match    ${boot_menu}    *CorePlus*

ESP004.101 ESP Scan does not create duplicate entries (EDK2 UEFI)
    [Documentation]    This test aims to verify that the firmware will not
    ...    create duplicate entries, for example, if both shimx64 and grubx64
    ...    are present for a single OS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP004.101 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction

    # In general, boot entries may be duplicated if created by other means.
    # Here we only want to test the duplicates created by the ESP scanning features.
    # These entries have specific format, such as:
    # <OS> (on <DISK>)
    # e.g. Windows Boot Manager (on INTEL SSDPEKNU512GZ)
    ${esp_scanning_entries}=    Get Matches    ${boot_menu}    ^.* \\(on.*\\)$
    List Should Not Contain Duplicates    ${esp_scanning_entries}

ESP005.101 ESP Scan detects Dasharo Tools Suite (EDK2 UEFI)
    [Documentation]    This test aims to verify that the firmware detects
    ...    Dasharo Tools Suite boot media and creates a corresponding boot
    ...    menu entry.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP005.101 not supported
    Power On
    Mount USB Disk Image    ${TEST_DATA_DIR}/dts/dts-base-image-v2.1.3.wic
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Contain Match    ${boot_menu}    Dasharo Tools Suite (on *

ESP006.101 ESP Scan does not find non-block boot devices (EDK2 UEFI)
    [Documentation]    This test aims to verify that the firmware will not
    ...    find non-block boot devices
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP006.101 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    FOR    ${boot_option}    IN    @{boot_menu}
        Should Not Contain    ${boot_option}    on Non-Block Boot Device
    END

ESP002.101 ESP Scan after deleting additional .efi files (EDK2 UEFI)
    [Documentation]    This test aims to verify that none of the systems linger
    ...    on in the boot menu after we've deleted their files from /EFI/.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP002.101 not supported
    Power On
    Clear Out EFI Partition
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    FOR    ${system}    IN    @{SYSTEMS_FOR_ESP_TESTING}
        Should Not Contain Match    ${boot_menu}    ${system}*
    END


*** Keywords ***
Setup Esp Scanning Suite
    [Documentation]    Load platform config and prepare files for the testing
    Prepare Test Suite
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP scanning tests not supported
    Skip If    not ${ESP_SCANNING_SUPPORT}    ESP scanning tests not supported
    Prepare EFI Partition With System Files

Teardown Esp Scanning Suite
    [Documentation]    Teardown ESP suite. To reduce cross-suite interaction
    ...    we clear call Clear Out EFI Partition only if suite run in the
    ...    first place
    IF    ${ESP_SCANNING_SUPPORT} and ${TESTS_IN_FIRMWARE_SUPPORT}
        Clear Out EFI Partition
    END
    Log Out And Close Connection
