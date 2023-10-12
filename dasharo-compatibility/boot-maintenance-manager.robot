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


*** Test Cases ***
BMM001.001 Set Auto Boot Time-out to 7 and check after reboot
    [Documentation]    Check whether setting Auto Boot Time-out to 7 the value
    ...    is remembered after restart
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD011.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo Submenu    Boot Maintenance Manager
    Refresh Serial Screen In BIOS Editable Settings Menu
    Change Numeric Value Of Setting    Auto Boot Time-out    7
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ${DASHARO_EXIT_PROMPT}
    Restart The DUT
    Enter Setup Menu Tianocore
    Enter Dasharo Submenu    Boot Maintenance Manager
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${value}=    Get Option Value    Auto Boot Time-out    checkpoint=${DASHARO_EXIT_PROMPT}
    Should Be Equal    ${value}    [7]

BMM002.001 F9 resets Auto Boot Time-out to default value
    [Documentation]    Check whether pressing F9 resets Auto Boot Time-out to
    ...    default value
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD011.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter Dasharo Submenu    Boot Maintenance Manager
    Refresh Serial Screen In BIOS Editable Settings Menu
    Reset To Defaults Tianocore    checkpoint=${DASHARO_EXIT_PROMPT}
    Press Key N Times    1    ${F10}
    Write Bare Into Terminal    y
    Read From Terminal Until    ${DASHARO_EXIT_PROMPT}
    Restart The DUT
    Enter Setup Menu Tianocore
    Enter Dasharo Submenu    Boot Maintenance Manager
    Refresh Serial Screen In BIOS Editable Settings Menu
    ${value}=    Get Option Value    Auto Boot Time-out    checkpoint=${DASHARO_EXIT_PROMPT}
    Should Be Equal    ${value}    ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}


*** Keywords ***
Restart The DUT
    [Documentation]    Does the same as power on (turns the power off and on).
    ...    Keyword for future Keyword-based documentation generation.
    Power On
