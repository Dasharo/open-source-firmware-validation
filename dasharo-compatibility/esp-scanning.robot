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
...                     Prepare Required Files For Qemu
Suite Teardown      Run Keyword
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

ESP002.001 ESP Scan after deleting additional .efi files
    [Documentation]    This test aims to verify that none of the systems linger
    ...    on in the boot menu after we've deleted their files from /EFI/.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP002.001 not supported

    Power On
    Clear Out EFI Partition
    Power On Or Reboot
    Enter Boot Menu Tianocore
    Check Boot Menu For All Supported Systems    empty

ESP003.001 ESP Scan ignores OSes on removable media
    [Documentation]    This test aims to verify that the bootable /EFI
    ...    partitions of removable media are ignored by the scan and aren't
    ...    listed in boot menu, except for DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP003.001 not supported

    Power On
    Download ISO And Mount As USB    img_name=CorePlus-current.iso    img_url=${TINYCORE_URL}
    Power On Or Reboot
    Enter Boot Menu Tianocore
    ${boot_list}=    Get Boot Menu Construction
    Should Not Contain Match    ${boot_list}    *CorePlus*

ESP004.001 ESP Scan does not create duplicate entries
    [Documentation]    This test aims to verify that the firmware will not
    ...    create duplicate entries, for example, if both shimx64 and grubx64
    ...    are present for a single OS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP004.001 not supported

    Power On
    Prepare EFI Partition With System Files
    Power On Or Reboot
    Enter Boot Menu Tianocore
    Check Boot Menu For All Supported Systems    double_entry_check

ESP005.001 ESP Scan detects Dasharo Tools Suite
    [Documentation]    This test aims to verify that the firmware detects
    ...    Dasharo Tools Suite boot media and creates a corresponding boot
    ...    menu entry.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ESP005.001 not supported

    Power On
    Download ISO And Mount As USB    img_name=dts-base-image-v1.2.8.iso    img_url=${DTS_URL}
    Power On Or Reboot
    Enter Boot Menu Tianocore
    ${boot_list}=    Get Boot Menu Construction
    Should Contain Match    ${boot_list}    *Dasharo Tools Suite*


*** Keywords ***
Prepare Required Files For Qemu
    IF    "${MANUFACTURER}" == "QEMU"
        Run    wget -O ./image.img ${DISK_IMAGE_URL}
        Run    wget -O ./dts-base-image-v1.2.8.iso ${DTS_URL}
        Run    wget -O ./CorePlus-current.iso ${TINYCORE_URL}
    END

Power On Or Reboot
    IF    "${MANUFACTURER}" == "QEMU"
        Power On
    ELSE
        Execute Reboot Command
    END
