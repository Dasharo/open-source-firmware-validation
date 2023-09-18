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
WBS001.001 Wifi and Bluetooth card power switch disabled (Ubuntu 22.04)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to false
    IF    not ${wifi_bluetooth_card_switch_support}    Skip

    Power On
    # changing settings in UEFI is only possible using serial connection
    IF    '${dut_connection_method}' == 'Telnet'
        Enter Dasharo System Features
        Skip if menu option not available    Networking Options
        Enter submenu in Tianocore    Networking Options
        Skip if menu option not available    Enable Wi-Fi + BT radios
        ${setting}=    Check if Tianocore setting is enabled in current menu    Enable Wi-Fi + BT radios
        IF    ${setting}
            Enter submenu in Tianocore    Enable Wi-Fi + BT radios
        END
        Save changes and boot to OS
    ELSE
        Log    DUT connection method is different from Telnet!
        Log    Cannot change UEFI options, skipping to testing switch results...
    END

    Login to Linux
    ${wifi}=    Check the presence of WiFi Card
    Should Not Be True    ${wifi}
    ${bt}=    Check the presence of Bluetooth Card
    Should Not Be True    ${bt}

WBS002.001 Wifi and Bluetooth card power switch enabled (Ubuntu 22.04)
    [Documentation]    Checks whether Wifi + Bluetooth is detected by Linux
    ...    after setting Enable Wi-Fi + BT radios option to true
    IF    not ${wifi_bluetooth_card_switch_support}    Skip

    Power On
    # changing settings in UEFI is only possible using serial connection
    IF    '${dut_connection_method}' == 'Telnet'
        Enter Dasharo System Features
        Skip if menu option not available    Networking Options
        Enter submenu in Tianocore    Networking Options
        Skip if menu option not available    Enable Wi-Fi + BT radios
        ${setting}=    Check if Tianocore setting is enabled in current menu    Enable Wi-Fi + BT radios
        IF    not ${setting}
            Enter submenu in Tianocore    Enable Wi-Fi + BT radios
        END
        Save changes and boot to OS
    ELSE
        Log    DUT connection method is different from Telnet!
        Log    Cannot change UEFI options, skipping to testing switch results...
    END

    Login to Linux
    ${wifi}=    Check the presence of WiFi Card
    Should Be True    ${wifi}
    ${bt}=    Check the presence of Bluetooth Card
    Should Be True    ${bt}
