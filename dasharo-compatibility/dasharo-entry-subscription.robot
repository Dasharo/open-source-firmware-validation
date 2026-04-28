*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DES_SUPPORT}    Dasharo Entry Subscription tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
DES001.101 Initial deployment with DES creds (EDK2 UEFI)
    [Documentation]    Verify that the DUT can perform initial firmware deployment
    ...    using Dasharo Entry Subscription credentials via USB boot medium.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DES001.101 not supported
    Execute Manual Step    [1/6] Prepare a DES-compatible USB boot medium
    Execute Manual Step    [2/6] Power on the DUT and boot from the USB medium
    Execute Manual Step    [3/6] When prompted, enter the Dasharo Entry Subscription credentials
    Execute Manual Step    [4/6] Select the desired firmware image from the DES menu
    Execute Manual Step    [5/6] Confirm the firmware flashing process completes successfully
    Execute Manual Step    [6/6] Reboot and verify the DUT boots with the newly deployed Dasharo firmware

DES001.103 Initial deployment with DES creds (iPXE)
    [Documentation]    Verify that the DUT can perform initial firmware deployment
    ...    using Dasharo Entry Subscription credentials via iPXE network boot.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DES001.103 not supported
    Execute Manual Step    [1/6] Power on the DUT and enter the boot menu
    Execute Manual Step    [2/6] Select iPXE network boot from the boot menu
    Execute Manual Step    [3/6] When prompted, enter the Dasharo Entry Subscription credentials
    Execute Manual Step    [4/6] Select the desired firmware image from the DES menu
    Execute Manual Step    [5/6] Confirm the firmware flashing process completes successfully
    Execute Manual Step    [6/6] Reboot and verify the DUT boots with the newly deployed Dasharo firmware
