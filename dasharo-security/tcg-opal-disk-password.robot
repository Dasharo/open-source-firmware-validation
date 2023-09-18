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
DMP001.001 TCG OPAL disk password set and check
    [Documentation]    This test doesn't have documentation
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DMP001.001 not supported
    Skip If    not ${TCG_OPAL_DISK_PASSWORD_SUPPORT}    DMP001.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Enter TCG Drive Management Submenu
    # Press key n times and enter    1    ${ARROW_DOWN}
    # Enter submenu in Tianocore    TCG Drive Management    ESC to exit    2
    # test assumes that only the first disk is bootable or there is only
    # one disk
    ${has_connected_disks}=    Check If Any Disk Is Connected
    IF    not ${has_connected_disks}
        Fail    Cannot test disk password feature, no supported disk connected to the system
    END
    Press Key N Times    1    ${ENTER}
    Log    Enable Feature
    Press Key N Times And Enter    2    ${ARROW_DOWN}
    Save Changes And Reset    3
    @{password}=    Set Variable    1    2    3
    Type In New Disk Password    @{password}
    Enter Setup Menu Tianocore
    Reset In Setup Menu Tianocore
    Log    Test if disk password works
    Type In Disk Password    @{password}
    Enter Setup Menu Tianocore
    Remove Disk Password    @{password}


*** Keywords ***
Check If Any Disk Is Connected
    [Documentation]    Looks for message "No disks connected to system".
    ...    Returns false if no disks are connected.
    ${output}=    Read From Terminal Until    F10=Save
    ${res}=    Run Keyword And Return Status
    ...    Should Not Contain    ${output}    No disks connected to system
    RETURN    ${res}
