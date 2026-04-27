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

Test Tags           semiauto


*** Test Cases ***
DTG001.001 Generate Profile for DTS UEFI Update Workflow
    [Documentation]
    ...    Generate profile for UEFI update workflow. ${FW_FILE} variable
    ...    should contain path to earlier UEFI fw release that allows for
    ...    update workflow. If ${FW_FILE} isn't defined then you'll be asked to
    ...    manually flash correct fw version on DUT
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
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Get Profile After Workflow

DTG002.001 Generate Profile for DTS SeaBIOS Update Workflow
    [Documentation]
    ...    Generate profile for SeaBIOS update workflow. ${FW_FILE} variable
    ...    should contain path to earlier SeaBIOS fw release that allows for
    ...    update workflow. If ${FW_FILE} isn't defined then you'll be asked to
    ...    manually flash correct fw version on DUT
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash earlier version of Dasharo firmware"
    Execute Manual Step While Freeing Serial Connection
    ...    "Boot into DTS. Continue after DTS UI is shown"
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Get Profile After Workflow    trim_last_line=${TRUE}

DTG003.001 Generate Profile for DTS UEFI Initial Deployment workflow
    [Documentation]
    ...    Generate profile for DTS UEFI initial deployment. ${FW_FILE}
    ...    variable should contain path to original/propertiary fw release that
    ...    allows for initial deployment workflow. If ${FW_FILE} isn't defined
    ...    then you'll be asked to manually flash correct fw version on DUT
    ${version}=    Prepare For Initial Deployment    seabios=${False}
    Go Through Initial Deployment    ${version}    skip_me=${TRUE}
    Get Profile After Workflow

DTG004.001 Generate Profile for DTS SeaBIOS Initial Deployment workflow
    [Documentation]
    ...    Generate profile for DTS SeaBIOS initial deployment. ${FW_FILE}
    ...    variable should contain path to original/propertiary fw release that
    ...    allows for initial deployment workflow. If ${FW_FILE} isn't defined
    ...    then you'll be asked to manually flash correct fw version on DUT
    ${version}=    Prepare For Initial Deployment    seabios=${True}
    Go Through Initial Deployment    ${version}    skip_me=${TRUE}
    Get Profile After Workflow

DTG005.001 Generate Profile for DTS Heads Transition workflow
    [Documentation]
    ...    Generate profile for DTS Heads transition. ${FW_FILE}
    ...    variable should contain path to UEFI fw release that
    ...    allows for heads transition workflow. If ${FW_FILE} isn't defined
    ...    then you'll be asked to manually flash correct fw version on DUT
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
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    ${dpp_keys_defined}=    Are DPP Keys Defined
    IF    ${dpp_keys_defined} == ${TRUE}    Provide DPP Credentials
    Go Through Heads Transition    skip_me=${TRUE}
    Get Profile After Workflow

DTG006.001 Generate Profile for DTS UEFI->SeaBIOS Transition workflow
    [Documentation]
    ...    Generate profile for DTS UEFI->SeaBIOS initial deployment.
    ...    ${FW_FILE} variable should contain path to UEFI fw release that
    ...    allows for SeaBIOS transition workflow. If ${FW_FILE} isn't defined
    ...    then you'll be asked to manually flash correct fw version on DUT
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
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Prepare DTS For Profile Generation
    Provide DPP Credentials
    Go Through Transition    DPP SeaBIOS    skip_me=${TRUE}
    Get Profile After Workflow

DTG007.001 Generate Profile for DTS SeaBIOS->UEFI Transition workflow
    [Documentation]
    ...    Generate profile for DTS SeaBIOS->UEFI initial deployment.
    ...    ${FW_FILE} variable should contain path to SeaBIOS fw release that
    ...    allows for UEFI transition workflow. If ${FW_FILE} isn't defined
    ...    then you'll be asked to manually flash correct fw version on DUT
    Flash FW Automatically Or Manually
    ...    FW_FILE    "Flash Dasharo SeaBIOS firmware"
    Execute Manual Step While Freeing Serial Connection
    ...    "Boot into DTS. Continue after DTS UI is shown"
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
    Execute Command In Terminal    export DTS_CONFIG_REF="${DTS_CONFIG_REF}"
    VAR    ${dasharo_ectool}=
    ...    \#!/bin/bash
    ...    if [ "\$1" != "flash" ]; then
    ...    /usr/bin/dasharo_ectool "\$@"
    ...    fi
    ...    separator=${\n}
    Execute Command In Terminal    echo '${dasharo_ectool}' >/tmp/bin/dasharo_ectool
    Execute Command In Terminal    chmod +x /tmp/bin/dasharo_ectool
    Write Into Terminal    PATH="/tmp/bin:$PATH" dts-boot

Get Profile After Workflow
    [Documentation]    Should be called after workflow completes. This keyword
    ...    should be used with update/initial deployment/transition workflows
    ...    which end up with reboot.
    [Arguments]    ${trim_last_line}=${FALSE}
    # After fake 'reboot' call DTS displays DTS_CONFIRM_CHECKPOINT prompt
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${date}=    Get Current Date    exclude_millis=${TRUE}
    Execute Command In Terminal    systemctl start sshd
    # get all logs + profiles
    VAR    ${logs_dir}=    ${CURDIR}/dts-gen-profiles/${date}-${CONFIG}-${TEST_NAME}
    Get File From DUT    /tmp/logs/*
    ...    ${logs_dir}/    verify=${FALSE}
    IF    ${trim_last_line}
        ${rc}=    Run And Return Rc
        ...    sed -i '$ d' "${logs_dir}/profile"
        Should Be Equal As Integers    ${rc}    0
        ${rc}=    Run And Return Rc
        ...    sed -i '$ d' "${logs_dir}/debug_profile"
        Should Be Equal As Integers    ${rc}    0
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
