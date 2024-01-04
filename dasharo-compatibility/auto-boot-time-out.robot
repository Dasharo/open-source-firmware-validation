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
BMM001.001 Change Auto Boot Time-out and check after reboot
    [Documentation]    Check whether setting Auto Boot Time-out to 7 the value
    ...    is remembered after restart
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    BMM001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    BMM001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${boot_timeout}=    Evaluate    ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE} + 1
    ${boot_timeout}=    Convert To String    ${boot_timeout}
    Set Option State    ${boot_mgr_menu}    Auto Boot Time-out    ${boot_timeout}
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${timeout_value}=    Get Option State    ${boot_mgr_menu}    Auto Boot Time-out
    Should Be Equal As Integers    ${timeout_value}    ${boot_timeout}

BMM002.001 F9 resets Auto Boot Time-out to default value
    [Documentation]    Check whether pressing F9 resets Auto Boot Time-out to
    ...    default value
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    BMM002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    BMM002.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${timeout_value}=    Get Option State    ${boot_mgr_menu}    Auto Boot Time-out
    IF    ${timeout_value} == ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}
        ${boot_timeout}=    Evaluate    ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE} + 1
        ${boot_timeout}=    Convert To String    ${boot_timeout}
        # Something is not right at this point. Either there is some race condition in
        # pressing keys or soemthign else. After setting an option to different value
        # then default, confirming it, it is changed. However pressing F9 does not restore
        # the default for some reason (change is not saved after reboot). Performing
        # it manually works though.
        Set Option State    ${boot_mgr_menu}    Auto Boot Time-out    ${boot_timeout}
    END
    Reset To Defaults Tianocore
    Save Changes And Reset

    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    ${timeout_value}=    Get Option State    ${boot_mgr_menu}    Auto Boot Time-out
    Should Be Equal As Integers    ${timeout_value}    ${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}

BMM003.001 Check Auto Boot Time-out option not accept non-numeric values
    [Documentation]    Check whether Auto Boot Time-out accepts only numeric
    ...    values.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    BMM003.001 not supported
    Skip If    "${DUT_CONNECTION_METHOD}" == "pikvm"    BMM003.001 not supported with PiKVM input
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${boot_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Boot Maintenance Manager
    Try To Insert Non-numeric Values Into Numeric Option    ${boot_mgr_menu}    Auto Boot Time-out
