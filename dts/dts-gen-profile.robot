*** Settings ***
Library             Collections
Library             DateTime
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot

Suite Setup         Prepare DTS Gen Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          DTS Gen Test Setup


*** Test Cases ***
DTG001.001 Generate Profile for DTS UEFI Update Workflow
    [Documentation]    Generate profile for UEFI update workflow.
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash earlier version of Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        TRY
            Set UEFI Option    MeMode    Disabled (HAP)
        EXCEPT
            Log    Couldn't disable ME, previous fw likely doesn't have that option
        END
    END
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Get Profile After Workflow

DTG002.001 Generate Profile for DTS SeaBIOS Update Workflow
    [Documentation]    Generate profile for SeaBIOS update workflow.
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash earlier version of Dasharo firmware"
    Execute Manual Step While Freeing Serial Connection
    ...    "Boot into DTS. Continue after DTS UI is shown"
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Get Profile After Workflow

DTG003.001 Generate Profile for DTS UEFI Initial Deployment workflow
    [Documentation]    Generate profile for DTS UEFI initial deployment
    ${version}=    Prepare For Initial Deployment    seabios=${False}
    Go Through Initial Deployment    ${version}    skip_me=${TRUE}
    Get Profile After Workflow

DTG004.001 Generate Profile for DTS SeaBIOS Initial Deployment workflow
    [Documentation]    Generate profile for DTS SeaBIOS initial deployment
    ${version}=    Prepare For Initial Deployment    seabios=${True}
    Go Through Initial Deployment    ${version}    skip_me=${TRUE}
    Get Profile After Workflow

DTG005.001 Generate Profile for DTS Heads Transition workflow
    [Documentation]    Generate profile for DTS Heads transition
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        TRY
            Set UEFI Option    MeMode    Disabled (HAP)
        EXCEPT
            Log    Couldn't disable ME
        END
    END
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Heads Transition
    Wait For Checkpoint    Rebooting
    Get Profile After Workflow

DTG006.001 Generate Profile for DTS UEFI->SeaBIOS Transition workflow
    [Documentation]    Generate profile for DTS SeaBIOS->UEFI initial deployment
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash Dasharo firmware"
    Make Sure That Flash Locks Are Disabled
    IF    "${DASHARO_INTEL_ME_MENU_SUPPORT}" == "${TRUE}"
        TRY
            Set UEFI Option    MeMode    Disabled (HAP)
        EXCEPT
            Log    Couldn't disable ME
        END
    END
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}
        Provide DPP Credentials
        VAR    ${version}=    DPP UEFI
    ELSE
        VAR    ${version}=    DCR UEFI
    END
    Go Through Transition    ${version}    skip_me=${TRUE}
    Get Profile After Workflow

DTG007.001 Generate Profile for DTS SeaBIOS->UEFI Transition workflow
    [Documentation]    Generate profile for DTS SeaBIOS->UEFI initial deployment
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash Dasharo SeaBIOS firmware"
    Execute Manual Step While Freeing Serial Connection
    ...    "Boot into DTS. Continue after DTS UI is shown"
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    Provide DPP Credentials
    Go Through Transition    DPP SeaBIOS    skip_me=${TRUE}
    Get Profile After Workflow


*** Keywords ***
DTS Gen Test Setup
    Depends On    ${DTS_SUPPORT}
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}    Restore Initial DUT Connection Method

Prepare DTS Gen Suite
    Prepare Test Suite
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=SUITE
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=SUITE

Prepare DTS For Profile Generation
    [Documentation]    Should be called inside DTS shell. After keyword finishes
    ...    you should be in DTS UI
    Execute Command In Terminal    rm -f /tmp/logs/*profile
    Execute Command In Terminal    mkdir -p /tmp/bin
    Execute Command In Terminal    echo '#!/bin/bash' >/tmp/bin/reboot
    Execute Command In Terminal    chmod +x /tmp/bin/reboot
    Write Into Terminal    PATH="/tmp/bin:$PATH" dts-boot

Get Profile After Workflow
    [Documentation]    Should be called after workflow completes. This keyword
    ...    should be used with update/initial deployment/transition workflows
    ...    which end up with reboot.
    # After fake 'reboot' call DTS displays DTS_CONFIRM_CHECKPOINT prompt
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${date}=    Get Current Date    exclude_millis=${TRUE}
    Execute Command In Terminal    systemctl start sshd
    # get all logs + profiles
    Get File From DUT    /tmp/logs/*
    ...    ${CURDIR}/dts-gen-profiles/${date}-${TEST_NAME}/    verify=${FALSE}

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
    IF    not ${variable_exists} or '''${POWER_CTRL}''' == '''none'''
        Execute Manual Step While Freeing Serial Connection    ${msg}
    ELSE
        Flash Firmware    ${${fw_var}}
        Power On
        Set DUT Response Timeout    5m
    END

Prepare For Initial Deployment
    [Documentation]    Prepare for deployment, from flashing up to entering
    ...    DPP keys. Returns deployment type to pass to
    ...    'Go Through Initial Deployment' keyword
    [Arguments]    ${seabios}=${False}
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash non-Dasharo/propertiary firmware"
    Execute Manual Step While Freeing Serial Connection
    ...    "Boot into DTS. Continue after DTS UI is shown"
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        Write Bare Into Terminal    K
        VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=TEST
        Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:~#
        # Spawn DTS menu on SSH console
        Write Into Terminal    dts-boot
    END
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${seabios}
        Provide DPP Credentials
        VAR    ${version}=    DPP SeaBIOS
    ELSE IF    ${dpp_keys_defined} == ${TRUE}
        Provide DPP Credentials
        VAR    ${version}=    DPP UEFI
    ELSE
        VAR    ${version}=    DCR UEFI
    END
    RETURN    ${version}

Execute Manual Step While Freeing Serial Connection
    [Documentation]    In case you need to connect to DUT via serial to do
    ...    manual steps. Arguments are the same as for 'Execute Manual Step'
    [Arguments]    ${msg}
    Telnet.Close All Connections
    Execute Manual Step
    ...    ${msg}. Make sure to close serial connection before continuing
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}
