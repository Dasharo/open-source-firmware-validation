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
${ITERATIONS}=      6


*** Test Cases ***
CBMEM001.001 Serial boot time measure: coreboot booting time after coldboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after coldboot if
    ...    CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM001.001 not supported
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported

    ${min}    ${max}    ${average}    ${stddev}=
    ...    Measure Coldboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot shortest booting time: ${min} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n
    Log To Console    \nCoreboot booting time std dev: ${stddev} s\n

    Should Be True    ${average} < ${MAX_ACCEPTABLE_AVERAGE_COLDBOOT_TIME_S}
    Should Be True    ${max} < ${MAX_ACCEPTABLE_COLDBOOT_TIME_S}
    Should Be True    ${stddev} < ${MAX_ACCEPTABLE_COLDBOOT_TIME_STD_DEV_S}

CBMEM002.001 Serial boot time measure: coreboot booting time after warmboot
    [Documentation]    Check whether the DUT boots after warmboot and how
    ...    long it takes for coreboot to boot after warmboot if
    ...    CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM002.001 not supported

    ${min}    ${max}    ${average}    ${stddev}=
    ...    Measure Warmboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot shortest booting time: ${min} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n
    Log To Console    \nCoreboot booting time std dev: ${stddev} s\n

    Should Be True    ${average} < ${MAX_ACCEPTABLE_AVERAGE_WARMBOOT_TIME_S}
    Should Be True    ${max} < ${MAX_ACCEPTABLE_WARMBOOT_TIME_S}
    Should Be True    ${stddev} < ${MAX_ACCEPTABLE_WARMBOOT_TIME_STD_DEV_S}

CBMEM003.001 Serial boot time measure: coreboot booting time after system reboot
    [Documentation]    Check whether the DUT boots after system reboot and how
    ...    long it takes for coreboot to boot after system reboot
    ...    if CPU is serial initialized.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM003.001 not supported

    ${min}    ${max}    ${average}    ${stddev}=
    ...    Measure Reboot Time    ${ITERATIONS}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot shortest booting time: ${min} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n
    Log To Console    \nCoreboot booting time std dev: ${stddev} s\n

    Should Be True    ${average} < ${MAX_ACCEPTABLE_AVERAGE_REBOOT_TIME_S}
    Should Be True    ${max} < ${MAX_ACCEPTABLE_REBOOT_TIME_S}
    Should Be True    ${stddev} < ${MAX_ACCEPTABLE_REBOOT_TIME_STD_DEV_S}
