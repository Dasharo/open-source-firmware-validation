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
SPD001.001
    [Documentation]    This test case verifies that RAM speed is correctly
    ...    indicated in setup menu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EFI001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    ${setup_menu}=    Get Menu Construction    Select Entry    0    1
    ${desired_line}=    Set Variable    ${EMPTY}
    ${cpu_line}=    Set Variable    ${EMPTY}
    FOR    ${line}    IN    @{setup_menu}
        ${found}=    Run Keyword And Return Status    Should Contain    ${line}    MB RAM @
        ${found_cpu}=    Run Keyword And Return Status    Should Contain    ${line}    GHz
        IF    ${found} == ${TRUE}
            ${desired_line}=    Set Variable    ${line}
        END
        IF    ${found_cpu} == ${TRUE}
            ${cpu_line}=    Set Variable    ${line}
        END
    END
    Log    ${desired_line}
    Log    ${cpu_line}

    ${freq_tmp}=    Fetch From Right    ${desired_line}    @
    ${freq}=    Fetch From Left    ${freq_tmp}    MHz

    ${ram_tmp}=    Fetch From Right    ${desired_line}    ${DMIDECODE_FIRMWARE_VERSION}
    ${ram}=    Fetch From Left    ${ram_tmp}    MB

    ${cpu_tmp}=    Fetch From Left    ${cpu_line}    GHz
    ${cpu}=    Fetch From Right    ${cpu_tmp}    @

    Should Not Be Equal As Numbers    ${freq}    0
    Should Not Be Equal As Numbers    ${ram}    0
    Should Not Be Equal As Numbers    ${cpu}    0
