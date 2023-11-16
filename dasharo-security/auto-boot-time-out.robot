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
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    Set Option State    ${boot_mgr_menu}    Auto Boot Time-out    7
    Save Changes And Reset    2    2

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${timeout_value}=    Get Option State    ${boot_mgr_menu}    Auto Boot Time-out
    Should Be Equal As Integers    ${timeout_value}    7

BMM002.001 F9 resets Auto Boot Time-out to default value
    [Documentation]    Check whether pressing F9 resets Auto Boot Time-out to
    ...    default value
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    RTD011.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    Set Option State    ${boot_mgr_menu}    Auto Boot Time-out    7
    Reset To Defaults Tianocore
    Save Changes And Reset    2    2

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${timeout_value}=    Get Option State    ${boot_mgr_menu}    Auto Boot Time-out
    Should Be Equal As Integers    ${timeout_value}    ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}

BMM003.001 Check Auto Boot Time-out option not accept non-numeric values
    [Documentation]    Check whether Auto Boot Time-out accepts only numeric
    ...    values.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    Try To Insert Non-numeric Values Into Numeric Option    ${boot_mgr_menu}    Auto Boot Time-out
