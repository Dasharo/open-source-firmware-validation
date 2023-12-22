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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${ITERATIONS}=      5


*** Test Cases ***
CBMEM001.001 Serial boot time measure: coreboot booting time after coldboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after coldboot if
    ...    CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM001.001 not supported
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Power Cycle On    power_button=${TRUE}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM002.001 Serial boot time measure: coreboot booting time after warmboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after warmboot if
    ...    CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM002.001 not supported
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM003.001 Serial boot time measure: coreboot booting time after system reboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after system reboot
    ...    if CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM003.001 not supported
    Power On
    ${average}=    Set Variable    0
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    Log To Console    \nCoreboot average booting time: ${average} s\n
    Execute Reboot Command


*** Keywords ***
Get Boot Time From Cbmem
    [Documentation]    Calculates boot time based on cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    Get Cbmem From Cloud
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    ${lines}=    Split To Lines    ${out_cbmem}
    ${first_line}=    Get From List    ${lines}    0
    ${last_line}=    Get From List    ${lines}    -1
    ${first_timestamp}=    Get Timestamp From Cbmem Log    ${first_line}
    ${last_timestamp}=    Get Timestamp From Cbmem Log    ${last_line}
    ${boot_time}=    Evaluate    (${last_timestamp} - ${first_timestamp}) / 1000000
    RETURN    ${boot_time}

Get Timestamp From Cbmem Log
    [Documentation]    Returns timestamp from a single cbmem -T log line
    [Arguments]    ${line}
    ${columns}=    Split String    ${line}
    ${timestamp}=    Get From List    ${columns}    1
    RETURN    ${timestamp}
