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
Resource            ../lib/cbmem.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${SERIAL_BOOT_MEASURE}    Boot performance measurement tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${ITERATIONS}=      5


*** Test Cases ***
CBMEM001.001 Serial boot time measure: coreboot booting time after coldboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after coldboot if
    ...    CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM001.001 not supported
    Skip If    "${OPTIONS_LIB}" == "dcu"    CBMEM001.001 not supported

    ${average}=    Measure Average Coldboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM002.001 Serial boot time measure: coreboot booting time after warmboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after warmboot if
    ...    CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM002.001 not supported

    ${average}=    Measure Average Warmboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n

CBMEM003.001 Serial boot time measure: coreboot booting time after system reboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after system reboot
    ...    if CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM003.001 not supported

    ${average}=    Measure Average Reboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n
