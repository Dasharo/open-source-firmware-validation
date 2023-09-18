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
NBA001.001 Enable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be enabled. If this option is activated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will appear.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBA001.001 not supported
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'    Remap Keys Variables To PiKVM
    Power On
    Enter Dasharo System Features
    Enter Submenu In Tianocore    Networking Options
    ${network_boot_enabled}=    Check If Tianocore Setting Is Enabled In Current Menu    Enable network boot
    IF    not ${network_boot_enabled}
        Refresh Serial Screen In BIOS Editable Settings Menu
        Enter Submenu In Tianocore    Enable network boot    ESC to exit
        Save Changes And Reset    2    4
    ELSE
        Log    Reboot
        Press Key N Times    2    ${ESC}
        Press Key N Times And Enter    4    ${ARROW_DOWN}
    END

    Enter Boot Menu Tianocore
    ${output}=    Read From Terminal Until    ESC to exit
    Should Contain    ${output}    Network Boot

NBA002.001 Disable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be disabled. If this option is deactivated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will be hidden.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBA002.001 not supported
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'    Remap Keys Variables To PiKVM
    Power On
    Enter Dasharo System Features
    Enter Submenu In Tianocore    Networking Options
    ${network_boot_enabled}=    Check If Tianocore Setting Is Enabled In Current Menu    Enable network boot
    IF    ${network_boot_enabled}
        Refresh Serial Screen In BIOS Editable Settings Menu
        Enter Submenu In Tianocore    Enable network boot    ESC to exit
        Save Changes And Reset    2    4
    ELSE
        Log    Reboot
        Press Key N Times    2    ${ESC}
        Press Key N Times And Enter    4    ${ARROW_DOWN}
    END

    Enter Boot Menu Tianocore
    ${output}=    Read From Terminal Until    ESC to exit
    Should Not Contain    ${output}    Network Boot
