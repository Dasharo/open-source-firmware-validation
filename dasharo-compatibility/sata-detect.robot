*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
...                     AND
...                     Restore Initial DUT Connection Method
Suite Teardown      Run Keywords
...                     Clear Out EFI Partition    AND
...                     Log Out And Close Connection


*** Test Cases ***
SAT001.001 ESP Scan should contain SATA if it is present
    [Documentation]    This test aims to verify that SATA shows up in the
    ...    boot menu
    Sleep    1
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SAT001.001 not supported
    Power On
    Clear Out EFI Partition
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Log    ${boot_menu}
    Should Contain    ${boot_menu}    SATA

SAT001.002 SATA should be visible from OS
    [Documentation]    This test aims to verify that SATA is detected from OS
    ...    by using smartctl and hwinfo.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SAT001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SAT001.002 not supported

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    Detect Or Install Package    smartmontools
    Detect Or Install Package    hwinfo

    ${out}=    Execute Linux Command    sudo smartctl -i $(mount | grep -E '(/|/boot) ' | awk '{print $1}' | head -1)
    Log    ${out}
    Should Contain    ${out}    SATA Version is:    SATA

    ${out}=    Execute Linux Command    sudo hwinfo --disk
    Log    ${out}
    Should Contain    ${out}    SATA controller


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
