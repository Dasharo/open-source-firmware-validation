*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Library    ../lib/QemuMonitor.py    /tmp/qmp-socket
# Required setup keywords:
#    Prepare Test Suite - generic setup keyword for all tests
# Required teardown keywords:
#    Log Out And Close Connection - generic setup keyword for all tests,
#    closes all connections to DUT and PiKVM
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${ESP_SCANNING_SUPPORT}    ESP scanning tests not supported
...                     AND
...                     Prepare Required Files For Qemu
...                     AND
...                     Prepare EFI Partition With System Files
Suite Teardown      Run Keywords
...                     Clear Out EFI Partition    AND
...                     Log Out And Close Connection


*** Test Cases ***
ESP001.001 ESP Scan with OS-specific .efi files added
    [Documentation]    This test aims to verify that any properly added .efi
    ...    files will have boot menu entries created for them.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP001.001 not supported
    Power On
    Prepare EFI Partition With System Files
    Power On Or Reboot
    Enter Boot Menu Tianocore
    Check Boot Menu For All Supported Systems    normal

ESP003.001 ESP Scan ignores OSes on removable media
    [Documentation]    This test aims to verify that the bootable /EFI
    ...    partitions of removable media are ignored by the scan and aren't
    ...    listed in boot menu, except for DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP003.001 not supported
    Power On
    Download ISO And Mount As USB    ${DL_CACHE_DIR}/CorePlus-current.iso
    ...    ${TINYCORE_URL}
    ...    5c0c5c7c835070f0adcaeafad540252e9dd2935c02e57de6112fb92fb5d6f9c5
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Not Contain Match    ${boot_menu}    *CorePlus*

ESP004.001 ESP Scan does not create duplicate entries
    [Documentation]    This test aims to verify that the firmware will not
    ...    create duplicate entries, for example, if both shimx64 and grubx64
    ...    are present for a single OS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP004.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction

    # In general, boot entries may be duplicated if created by other means.
    # Here we only want to test the duplicates created by the ESP scanning features.
    # These entries have specific format, such as:
    # <OS> (on <DISK>)
    # e.g. Windows Boot Manager (on INTEL SSDPEKNU512GZ)
    ${esp_scanning_entries}=    Get Matches    ${boot_menu}    ^.* \\(on.*\\)$
    List Should Not Contain Duplicates    ${esp_scanning_entries}

ESP005.001 ESP Scan detects Dasharo Tools Suite
    [Documentation]    This test aims to verify that the firmware detects
    ...    Dasharo Tools Suite boot media and creates a corresponding boot
    ...    menu entry.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP005.001 not supported
    Power On
    Download ISO And Mount As USB
    ...    ${DL_CACHE_DIR}/dts-base-i${DL_CACHE_DIR}/mage-v1.2.8.iso
    ...    ${DTS_URL}
    ...    f42b59633dbcc16ecbd7c98a880c582c5235c22626d7204202c922f3a7fa231b
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Should Contain Match    ${boot_menu}    Dasharo Tools Suite on (*

ESP006.001 ESP Scan does not find non-block boot devices
    [Documentation]    This test aims to verify that the firmware will not
    ...    find non-block boot devices
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP004.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    FOR    ${boot_option}    IN    @{boot_menu}
        Should Not Contain    ${boot_option}    on Non-Block Boot Device
    END

ESP002.001 ESP Scan after deleting additional .efi files
    [Documentation]    This test aims to verify that none of the systems linger
    ...    on in the boot menu after we've deleted their files from /EFI/.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP002.001 not supported
    Skip If    not ${ESP_SCANNING_SUPPORT}    ESP002.001 not supported

    Power On
    Clear Out EFI Partition
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    FOR    ${system}    IN    @{SYSTEMS_FOR_ESP_TESTING}
        Should Not Contain Match    ${boot_menu}    ${system}*
    END


*** Keywords ***
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
