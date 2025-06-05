*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DTS_SUPPORT}    DTS tests not supported
...                     AND
...                     Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# This must be in Test Setup, not Suite Setup, because of a known problem
# with QEMU: https://github.com/Dasharo/open-source-firmware-validation/issues/132
Test Setup          Run Keyword If    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     Restore Initial DUT Connection Method


*** Test Cases ***
DTS001.001 Booting DTS from USB works correctly
    [Documentation]    This test aims to verify that DTS is properly booting
    ...    from USB.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS001.001 not supported
    Mount USB Disk Image    ${TEST_DATA_DIR}/dts/dts-base-image-v2.1.3.wic
    Power On
    Boot Dasharo Tools Suite    USB

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    This test aims to verify that the option Dasharo HCL
    ...    report in the DTS menu properly creates the report.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS002.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Write Bare Into Terminal    1
    Read From Terminal Until
    ...    Do you want to support Dasharo development by sending us logs with your hardware configuration? [N/y]
    Write Into Terminal    N
    Set DUT Response Timeout    5m
    Read From Terminal Until    Done! Logs saved to:

DTS003.001 DTS option reboot DUT works correctly
    [Documentation]    This test aims to verify that the option Reboot system
    ...    in the DTS menu reboots the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS004.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Write Bare Into Terminal    R
    # Switch back to serial on PiKVM devices
    Restore Initial DUT Connection Method
    Enter Setup Menu Tianocore

DTS004.001 DTS accessing shell works correctly
    [Documentation]    This test aims to verify that shell can be accessed in
    ...    DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS005.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Write Bare Into Terminal    S
    Read From Terminal Until Regexp    bash-\\d\\.\\d#

DTS005.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    This test aims to verify whether is the possibility to
    ...    flash the DUT firmware by using flashrom in DTS Shell.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS006.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    DTS006.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Execute Command In Terminal    wget -O /tmp/coreboot.rom ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash Via Internal Programmer    /tmp/coreboot.rom
    Power On
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version

DTS006.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to flash the DUT EC firmware by using the built-in
    ...    script in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS008.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS008.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Run EC Transition
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version

DTS007.001 Update device EC firmware by using DTS works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT EC firmware by using dasharo_ectool
    ...    in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS009.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS009.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Flash EC Firmware
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version

DTS008.001 DTS option power-off DUT works correctly
    [Documentation]    This test aims to verify that the option Power off
    ...    system in the DTS menu turns off the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS003.001 not supported
    Power On
    Boot Dasharo Tools Suite    iPXE
    Write Bare Into Terminal    P
    Set DUT Response Timeout    30s
    ${status}=    Run Keyword And Return Status    Enter Setup Menu Tianocore
    Should Not Be True    ${status}

DTS009.001 Update Dasharo firmware by using DTS via USB works correctly
    [Documentation]    This test aims to verify that updating Dasharo by using
    ...    DTS built-in script works correctly when booting DTS via USB.
    ...    Test expects FW_FILE_PREV variable to contain path to Dasharo
    ...    firmware. If FW_FILE_PREV isn't defined then test waits for user to
    ...    flash correct FW. If DPP_EMAIL and DPP_PASSWORD are defined then
    ...    test will load DPP credentials before trying to update.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Flash FW Automatically Or Manually
    ...    FW_FILE_PREV    "Flash earlier version of Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        Set UEFI Option    MeMode    Disabled (HAP)
    END
    Boot Dasharo Tools Suite    USB
    # To refresh screen as next keyword expects DTS checkpoint
    Press Key N Times    1    ${ESC}
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    Enter Setup Menu Tianocore

DTS009.002 Update Dasharo firmware by using DTS via iPXE works correctly
    [Documentation]    This test aims to verify that updating Dasharo by using
    ...    DTS built-in script works correctly when booting DTS via iPXE.
    ...    Test expects FW_FILE_PREV variable to contain path to Dasharo
    ...    firmware. If FW_FILE_PREV isn't defined then test waits for user to
    ...    flash correct FW. If DPP_EMAIL and DPP_PASSWORD are defined then
    ...    test will load DPP credentials before trying to update.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Flash FW Automatically Or Manually
    ...    FW_FILE_PREV    "Flash earlier version of Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        Set UEFI Option    MeMode    Disabled (HAP)
    END
    Boot Dasharo Tools Suite    iPXE
    # To refresh screen as next keyword expects DTS checkpoint
    Press Key N Times    1    ${ESC}
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    Enter Setup Menu Tianocore

DTS010.001 Deploy Dasharo firmware by using DTS works correctly
    [Documentation]    This test aims to verify that deploying Dasharo by using
    ...    DTS built-in script works correctly.
    ...    Test expects FW_FILE_NON_DASHARO variable to contain path to
    ...    non-Dasharo firmware (proprietary). If FW_FILE_NON_DASHARO isn't
    ...    defined then test waits for user to flash correct FW.
    ...    If DPP_EMAIL and DPP_PASSWORD are defined then test will load DPP
    ...    credentials before trying to deploy firmware.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    ${version}=    Prepare For Initial Deployment    seabios=${False}
    Go Through Initial Deployment    ${version}
    Wait For Checkpoint    Rebooting
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    # Not sure how to check if Dasharo fw has serial console enabled by
    # default, assume that it isn't and ask for manual confirmation
    Execute Manual Step    "Confirm that deployment succeeded"

DTS010.002 Deploy Dasharo SeaBios firmware by using DTS works correctly
    [Documentation]    This test aims to verify that deploying Dasharo by using
    ...    DTS built-in script works correctly.
    ...    Test expects FW_FILE_NON_DASHARO variable to contain path to
    ...    non-Dasharo firmware (proprietary). If FW_FILE_NON_DASHARO isn't
    ...    defined then test waits for user to flash correct FW.
    ...    If DPP_EMAIL and DPP_PASSWORD are defined then test will load DPP
    ...    credentials before trying to deploy firmware.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    ${version}=    Prepare For Initial Deployment    seabios=${False}
    Go Through Initial Deployment    ${version}
    Wait For Checkpoint    Rebooting
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    # Not sure how to check if Dasharo fw has serial console enabled by
    # default, assume that it isn't and ask for manual confirmation
    Execute Manual Step    "Confirm that deployment succeeded"

DTS011.001 Heads Transition by using DTS via iPXE works correctly
    [Documentation]    This test aims to verify that Heads Transition by using
    ...    DTS built-in script works correctly.
    ...    Test expects FW_FILE variable to contain path to Dasharo fw with
    ...    enabled serial console from which we will attempt to transition to
    ...    heads. If FW_FILE isn't defined then test waits for user to flash
    ...    correct FW. If DPP_EMAIL and DPP_PASSWORD are defined then test will
    ...    load DPP credentials before trying to deploy firmware.
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}

    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        Set UEFI Option    MeMode    Disabled (HAP)
    END
    Boot Dasharo Tools Suite    iPXE
    # To refresh screen as next keyword expects DTS checkpoint
    Press Key N Times    1    ${ESC}
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Heads Transition
    Wait For Checkpoint    Rebooting
    Restore Initial DUT Connection Method
    Set DUT Response Timeout    5m
    Execute Manual Step    "Confirm that deployment succeeded"


*** Keywords ***
Are DPP Keys Defined
    ${email}=    Run Keyword And Return Status
    ...    Variable Should Exist    $DPP_EMAIL
    ${password}=    Run Keyword And Return Status
    ...    Variable Should Exist    $DPP_PASSWORD
    ${status}=    Run Keyword And Return Status    Should Be True
    ...    ${email} and ${password}
    RETURN    ${status}

Flash FW Automatically Or Manually
    [Documentation]    Flash firmware automatically if it's possible and
    ...    variable with name passed in fw_var exists
    [Arguments]    ${fw_var}    ${msg}="Flash firmware"
    ${variable_exists}=    Run Keyword And Return Status
    ...    Variable Should Exist    \${${fw_var}}
    # Without POWER_CTRL Flash Firmware will try to boot into Linux which won't
    # work
    IF    not ${variable_exists} or '''${POWER_CTRL}''' != '''none'''
        Execute Manual Step    ${msg}
    ELSE
        Flash Firmware    ${FW_FILE_DTS}
    END

Prepare For Initial Deployment
    [Documentation]    Prepare for deployment, from flashing up to entering
    ...    DPP keys. Returns deployment type to pass to
    ...    'Go Through Initial Deployment' keyword
    [Arguments]    ${seabios}=${False}
    Flash FW Automatically Or Manually
    ...    FW_FILE_NON_DASHARO    "Flash non-Dasharo/propertiary firmware"
    Execute Manual Step    "Boot into DTS. Continue after DTS UI is shown"
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Execute Manual Step    "Enable SSH server in DTS"
        Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    END
    # Flush buffer
    Read From Terminal
    # To refresh screen as next keyword expects DTS checkpoint
    Press Key N Times    1    ${ESC}
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${seabios}
        Provide DPP Credentials
        ${version}=    Set Variable    DPP UEFI
    ELSE IF    ${dpp_keys_defined} == ${TRUE}
        Provide DPP Credentials
        ${version}=    Set Variable    DPP UEFI
    ELSE
        ${version}=    Set Variable    DCR UEFI
    END
    RETURN    ${version}
