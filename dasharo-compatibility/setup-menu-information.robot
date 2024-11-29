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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${UEFI_COMPATIBLE_INTERFACE_SUPPORT}    UEFI interface tests not supported
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SET001.001 CPU clock speed displayed in setup menu
    [Documentation]    This test case verifies that CPU clock speed is
    ...    correctly indicated in setup menu.

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${cpu_line}=    Get Lines Matching Regexp    ${out}    .*GHz
    Should Not Be Empty    ${cpu_line}    CPU clock speed not found

    ${matches}=    Get Regexp Matches    ${cpu_line}    (\\d+\\.\\d+)\\s+GHz    1
    Should Not Be Equal As Numbers    ${matches}[0]    0

SET002.001 RAM speed displayed in setup menu
    [Documentation]    This test case verifies that RAM speed is correctly
    ...    indicated in setup menu.

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${ram_line}    RAM speed not found

    ${matches}=    Get Regexp Matches    ${ram_line}    (\\d+)\\s*MHz    1
    Should Not Be Equal As Numbers    ${matches}[0]    0

SET003.001 RAM size displayed in setup menu
    [Documentation]    This test case verifies that RAM size is correctly
    ...    indicated in setup menu.

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*MB RAM.*
    Should Not Be Empty    ${ram_line}    RAM size not found

    ${matches}=    Get Regexp Matches    ${ram_line}    (\\d+)\\s*MB\\s*RAM    1
    Should Not Be Equal As Numbers    ${matches}[0]    0

SET004.001 Expected CPU clock speed displayed in setup menu
    [Documentation]    This test case verifies that CPU clock speed is
    ...    correctly indicated in setup menu.
    Depends On Variable    \${PLATFORM_CPU_SPEED}

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${cpu_line}=    Get Lines Matching Regexp    ${out}    .*GHz
    Should Not Be Empty    ${cpu_line}    CPU clock speed not found

    ${matches}=    Get Regexp Matches    ${cpu_line}    (\\d+\\.\\d+) GHz    1
    Should Be Equal As Numbers    ${matches}[0]    ${PLATFORM_CPU_SPEED}

SET005.001 Expected RAM speed displayed in setup menu
    [Documentation]    This test case verifies that RAM speed is correctly
    ...    indicated in setup menu.
    Depends On Variable    \${PLATFORM_RAM_SPEED}

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${ram_line}    RAM speed not found

    ${matches}=    Get Regexp Matches    ${ram_line}    (\\d+)\\s*MHz    1
    Should Be Equal As Numbers    ${matches}[0]    ${PLATFORM_RAM_SPEED}

SET006.001 Expected RAM size displayed in setup menu
    [Documentation]    This test case verifies that RAM size is correctly
    ...    indicated in setup menu.
    Depends On Variable    \${PLATFORM_RAM_SIZE}

    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${ram_line}=    Get Lines Matching Regexp    ${out}    .*MB RAM.*
    Should Not Be Empty    ${ram_line}    RAM size not found

    ${matches}=    Get Regexp Matches    ${ram_line}    (\\d+)\\s*MB\\s*RAM    1
    Should Be Equal As Numbers    ${matches}[0]    ${PLATFORM_RAM_SIZE}
