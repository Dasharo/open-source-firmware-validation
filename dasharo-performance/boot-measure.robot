*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CBMEM001.001 Serial boot measure: coreboot booting time after coldboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after coldboot if
    ...    CPU is serial initialized.
    Skip If    not ${serial_boot_measure}    CBMEM001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CBMEM001.001 not supported
    Set Suite Variable    ${iterations}    5
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${INDEX}    IN RANGE    0    ${iterations}
        Power Cycle On
        Boot system or from connected disk    ubuntu
        Login to Linux
        Switch to root user
        Get cbmem from cloud
        ${timestamps}=    Get boot timestamps
        ${length}=    Get Length    ${timestamps}
        Log boot timestamps    ${timestamps}    ${length}
        ${duration}=    Get duration from timestamps    ${timestamps}    ${length}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${INDEX}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
    END
    ${average}=    Evaluate    ${average}/${iterations}
    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM002.001 Serial boot measure: coreboot booting time after warmboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after warmboot if
    ...    CPU is serial initialized.
    Skip If    not ${serial_boot_measure}    CBMEM002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CBMEM002.001 not supported
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${INDEX}    IN RANGE    0    ${iterations}
        Power On
        Boot system or from connected disk    ubuntu
        Login to Linux
        Switch to root user
        Get cbmem from cloud
        ${timestamps}=    Get boot timestamps
        ${length}=    Get Length    ${timestamps}
        Log boot timestamps    ${timestamps}    ${length}
        ${duration}=    Get duration from timestamps    ${timestamps}    ${length}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${INDEX}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
    END
    ${average}=    Evaluate    ${average}/${iterations}
    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM003.001 Serial boot measure: coreboot booting time after system reboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after system reboot
    ...    if CPU is serial initialized.
    Skip If    not ${serial_boot_measure}    CBMEM003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    CBMEM003.001 not supported
    ${average}=    Set Variable    0
    Power On
    Log To Console    \n
    FOR    ${INDEX}    IN RANGE    0    ${iterations}
        Boot operating system    ubuntu
        Login to Linux
        Switch to root user
        Get cbmem from cloud
        ${timestamps}=    Get boot timestamps
        ${length}=    Get Length    ${timestamps}
        Log boot timestamps    ${timestamps}    ${length}
        ${duration}=    Get duration from timestamps    ${timestamps}    ${length}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${INDEX}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
        Telnet.Write Bare    reboot\n
    END
    ${average}=    Evaluate    ${average}/${iterations}
    Log To Console    \nCoreboot average booting time: ${average} s\n
