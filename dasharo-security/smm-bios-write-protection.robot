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
...                     Skip If    not ${SMM_WRITE_PROTECTION_SUPPORT}    SMM BIOS write protection not supported
...                     AND
...                     Skip If    not ${DASHARO_SECURITY_MENU_SUPPORT}    Dasharo Security menu not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SMM001.001 SMM BIOS write protection enabling (Ubuntu)
    [Documentation]    SMM BIOS write protection is the method to prevent a
    ...    specific region of the firmware from being flashed - when enabled
    ...    allows only SMM code (the privileged code installed by the firmware
    ...    in the system memory) to write to BIOS flash. This test aims to
    ...    verify that, the SMM BIOS protection option is available in the
    ...    Dasharo Security Options and, if the mechanism works correctly -
    ...    during the attempt of firmware flashing information about the
    ...    SMM protection is returned.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${network_menu}    Enable SMM BIOS write    ${TRUE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    SMM protection is enabled

SMM002.001 SMM BIOS write protection disabling (Ubuntu)
    [Documentation]    SMM BIOS write protection is the method to prevent a
    ...    specific region of the firmware from being flashed - when enabled
    ...    allows only SMM code (the privileged code installed by the firmware
    ...    in the system memory) to write to BIOS flash. This test aims to
    ...    verify that, the SMM BIOS protection option is available in the
    ...    Dasharo Security Options and, if the mechanism works correctly -
    ...    during the attempt of firmware flashing information about the
    ...    SMM protection is returned.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    "${OPTIONS_LIB}" == "dcu"
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${network_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Dasharo Security Options
    Set Option State    ${network_menu}    Enable SMM BIOS write    ${FALSE}
    Save Changes And Reset
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Not Contain    ${out_flashrom}    SMM protection is enabled
    Should Not Be Empty    ${out_flashrom}
