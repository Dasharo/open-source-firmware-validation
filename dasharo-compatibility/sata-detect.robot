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

    ${out}=    Execute Command In Terminal
    ...    sudo smartctl -i $(mount | grep -E '(/|/boot) ' | awk '{print $1}' | head -1)
    Log    ${out}
    Should Contain    ${out}    SATA Version is:    SATA

    ${out}=    Execute Command In Terminal    sudo hwinfo --disk
    Log    ${out}
    Should Contain    ${out}    SATA controller
