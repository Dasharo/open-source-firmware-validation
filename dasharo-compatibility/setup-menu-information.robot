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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${UEFI_COMPATIBLE_INTERFACE_SUPPORT}    UEFI interface tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SET001.001 CPU clock speed displayed in setup menu
    [Documentation]    This test case verifies that CPU clock speed is
    ...    correctly indicated in setup menu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EFI001.001 not supported

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${cpu_line}=    Get Lines Matching Regexp    ${out}    .*GHz

    ${clock_speed}=    Get Regexp Matches    ${cpu_line}    \\b\\d+\\.\\d{2}\\s*GHz\\b
    Log    ${clock_speed[0]}

    ${cpu}=    Fetch From Left    ${clock_speed[0]}    GHz

    Should Not Be Equal As Numbers    ${cpu}    0

SET002.001 RAM speed displayed in setup menu
    [Documentation]    This test case verifies that RAM speed is correctly
    ...    indicated in setup menu.

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*

    ${freq_tmp}=    Fetch From Right    ${ram_line}    @
    ${freq}=    Fetch From Left    ${freq_tmp}    MHz

    Should Not Be Equal As Numbers    ${freq}    0

SET003.001 RAM size displayed in setup menu
    [Documentation]    This test case verifies that RAM size is correctly
    ...    indicated in setup menu.

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*MB RAM.*

    ${ram_tmp}=    Fetch From Right    ${ram_line}    ${DMIDECODE_FIRMWARE_VERSION}
    ${ram}=    Fetch From Left    ${ram_tmp}    MB

    Should Not Be Equal As Numbers    ${ram}    0

SET004.001 Expected CPU clock speed displayed in setup menu
    [Documentation]    This test case verifies that CPU clock speed is
    ...    correctly indicated in setup menu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EFI001.001 not supported

    ${flags}=    Get Variables
    ${out}=    Run Keyword And Return Status
    ...    Should Be True    "\${PLATFORM_CPU_SPEED}" in $flags
    IF    not ${out}    Skip    Expected CPU speed undefined

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${cpu_line}=    Get Lines Matching Regexp    ${out}    .*GHz

    ${clock_speed}=    Get Regexp Matches    ${cpu_line}    \\b\\d+\\.\\d{2}\\s*GHz\\b
    Log    ${clock_speed[0]}

    ${cpu}=    Fetch From Left    ${clock_speed[0]}    GHz

    Should Be Equal As Numbers    ${cpu}    ${PLATFORM_CPU_SPEED}

SET005.001 Expected RAM speed displayed in setup menu
    [Documentation]    This test case verifies that RAM speed is correctly
    ...    indicated in setup menu.

    ${flags}=    Get Variables
    ${out}=    Run Keyword And Return Status
    ...    Should Be True    "\${PLATFORM_RAM_SPEED}" in $flags
    IF    not ${out}    Skip    Expected RAM speed undefined

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*

    ${freq_tmp}=    Fetch From Right    ${ram_line}    @
    ${freq}=    Fetch From Left    ${freq_tmp}    MHz

    Should Be Equal As Numbers    ${freq}    ${PLATFORM_RAM_SPEED}

SET006.001 Expected RAM size displayed in setup menu
    [Documentation]    This test case verifies that RAM size is correctly
    ...    indicated in setup menu.

    ${flags}=    Get Variables
    ${out}=    Run Keyword And Return Status
    ...    Should Be True    "\${PLATFORM_RAM_SIZE}" in $flags
    IF    not ${out}    Skip    Expected RAM size undefined

    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*MB RAM.*

    ${ram_tmp}=    Fetch From Right    ${ram_line}    ${DMIDECODE_FIRMWARE_VERSION}
    ${ram}=    Fetch From Left    ${ram_tmp}    MB

    Should Be Equal As Numbers    ${ram}    ${PLATFORM_RAM_SIZE}
