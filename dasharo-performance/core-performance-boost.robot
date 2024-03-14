*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
CPB001.001 Check if disabling CPB decreases performance
    [Documentation]    This Test Checks Whether Performance Changes With Core Performance Boost Disabled
    Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    APU configuration tests not supported.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Core Performance Boost    ${FALSE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${first_check}=    Execute Command In Terminal
    ...    dd if=/dev/zero of=/dev/null bs=64k count=1M 2>&1 | awk 'END{printf $(NF-3)}'
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${apu_menu}=    Enter Dasharo Submenu    ${setup_menu}    Dasharo APU Configuration
    Set Option State    ${apu_menu}    Core Performance Boost    ${TRUE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${second_check}=    Execute Command In Terminal
    ...    dd if=/dev/zero of=/dev/null bs=64k count=1M 2>&1 | awk 'END{printf $(NF-3)}'
    ${status}=    Evaluate    ${first_check} > ${second_check}
    Should Be True    ${status}
