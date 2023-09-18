*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
NBA001.001 Enable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be enabled. If this option is activated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will appear.
    Skip If    not ${tests_in_firmware_support}    NBA001.001 not supported
    IF    '${dut_connection_method}' == 'pikvm'    Remap keys variables to PiKVM
    Power On
    Enter Dasharo System Features
    Enter submenu in Tianocore    Networking Options
    ${network_boot_enabled}=    Check if Tianocore setting is enabled in current menu    Enable network boot
    IF    not ${network_boot_enabled}
        Refresh serial screen in BIOS editable settings menu
        Enter submenu in Tianocore    Enable network boot    ESC to exit
        Save changes and reset    2    4
    ELSE
        Log    Reboot
        Press key n times    2    ${ESC}
        Press key n times and enter    4    ${ARROW_DOWN}
    END

    Enter Boot Menu Tianocore
    ${output}=    Read From Terminal Until    ESC to exit
    Should Contain    ${output}    Network Boot

NBA002.001 Disable Network Boot (firmware)
    [Documentation]    This test aims to verify that the Network Boot option
    ...    might be disabled. If this option is deactivated, an additional option
    ...    in the Boot menu which allows to boot the system from iPXE servers
    ...    will be hidden.
    Skip If    not ${tests_in_firmware_support}    NBA002.001 not supported
    IF    '${dut_connection_method}' == 'pikvm'    Remap keys variables to PiKVM
    Power On
    Enter Dasharo System Features
    Enter submenu in Tianocore    Networking Options
    ${network_boot_enabled}=    Check if Tianocore setting is enabled in current menu    Enable network boot
    IF    ${network_boot_enabled}
        Refresh serial screen in BIOS editable settings menu
        Enter submenu in Tianocore    Enable network boot    ESC to exit
        Save changes and reset    2    4
    ELSE
        Log    Reboot
        Press key n times    2    ${ESC}
        Press key n times and enter    4    ${ARROW_DOWN}
    END

    Enter Boot Menu Tianocore
    ${output}=    Read From Terminal Until    ESC to exit
    Should Not Contain    ${output}    Network Boot
