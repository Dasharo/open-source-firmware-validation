*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=40 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ./TemplateSplit.py    custom_prefix=E2E
Library             ./PlatformParser.py
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot

Suite Setup         Prepare DTS E2E Test Suite
# Suite Teardown      Run Keyword
# ...                     Log Out And Close Connection
Test Setup          Prepare DTS Test
Test Teardown       Teardown DTS Test


*** Test Cases ***
Print All Test Cases To Be Generated
    [Setup]    NONE
    Log To Console    ${EMPTY}
    FOR    ${platform}    ${platform_variables}    IN    &{DTS_PLATFORM_VARIABLES}
        FOR    ${workflow}    IN    @{platform_variables}[DTS_TEST_WORKFLOWS]
            IF    "${workflow}" == "Heads Transition"
                Log To Console    ${platform} ${workflow} - DPP
            ELSE
                FOR    ${subscription}    IN    @{platform_variables}[DTS_TEST_SUBSCRIPTIONS]
                    Log To Console    ${platform} ${workflow} - ${subscription}
                END
            END
        END
    END
    [Teardown]    NONE

Create tests
    [Template]    ${PLATFORM} ${WORKFLOW} - ${SUBSCRIPTION}
    FOR    ${platform}    ${platform_variables}    IN    &{DTS_PLATFORM_VARIABLES}
        FOR    ${workflow}    IN    @{platform_variables}[DTS_TEST_WORKFLOWS]
            IF    "${workflow}" == "Heads Transition"
                ${platform}    ${workflow}    DPP
            ELSE
                FOR    ${subscription}    IN    @{platform_variables}[DTS_TEST_SUBSCRIPTIONS]
                    ${platform}    ${workflow}    ${subscription}
                END
            END
        END
    END

E2E001.001 HCL Report test
    [Documentation]    Verify that HCL Report is being executed with all
    ...    expected messages. The report should not fail even if it failed to
    ...    collect some data, because it is responsible only for collecting.
    # 2) Prepare DTS for testing:
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    # 3) Launch HCL report:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_HCL_OPT}

    # 4) Check out all HCL Report questions:
    Wait For Checkpoint And Write    ${HCL_REPORT_SENDINGLOGS}    N
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Reject hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    N
    Set DUT Response Timeout    30s

    # 5) Wait for final HCL Report checkpoint:
    Wait For Checkpoint    ${HCL_REPORT_CHECKPOINT}


*** Keywords ***
# robocop: disable:0919
${platform} ${workflow} - ${subscription}
    [Documentation]    Fallback keyword, should only enter if there is a typo
    ...    in DTS_TEST_WORKFLOWS or DTS_TEST_SUBSCRIPTIONS
    Fail    Unknown workflow (${workflow}) or subscription (${subscription})
# robocop: enable

${platform} Update - Community Version
    [Documentation]    sss
    Prepare E2E Test    ${platform}    Update
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} Initial Deployment - Community Version
    [Documentation]    sss
    Prepare E2E Test    ${platform}    Initial Deployment
    Write Into Terminal    dts-boot
    Go Through Initial Deployment    DCR UEFI
    Wait For Checkpoint    Rebooting

${platform} Update - DPP
    [Documentation]    sss
    Prepare E2E Test    ${platform}    Update
    Provide DPP Credentials
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} Initial Deployment - DPP
    [Documentation]    sss
    Prepare E2E Test    ${platform}    Initial Deployment
    Provide DPP Credentials
    Go Through Initial Deployment    DPP UEFI
    Wait For Checkpoint    Rebooting

${platform} Heads Transition - DPP
    [Documentation]    sss
    Prepare E2E Test    ${platform}    Heads Transition
    Provide DPP Credentials
    Go Through Heads Transition
    Wait For Checkpoint    Rebooting

Prepare E2E Test
    [Documentation]    sss
    [Arguments]    ${platform}    ${workflow}
    &{dts_test_variables}=    Create Dictionary    &{DTS_PLATFORM_VARIABLES}[${platform}]
    Set Test Variable    \${DTS_TEST_VARIABLES}
    Export Shell Variables For Emulation    ${workflow}

Export Shell Variables For Emulation
    [Documentation]    sss
    [Arguments]    ${workflow}
    &{additional_exports}=    Set Variable
    ...    ${DTS_TEST_VARIABLES}[DTS_TEST_ADDITIONAL_EXPORTS]
    # map shell variables to robot variables which will be exported 1-to-1
    &{variables_mapping}=    Create Dictionary
    ...    TEST_SYSTEM_MODEL=DTS_TEST_SYSTEM_MODEL
    ...    TEST_BOARD_MODEL=DTS_TEST_BOARD_MODEL
    ...    TEST_SYSTEM_VENDOR=DTS_TEST_SYSTEM_VENDOR
    IF    "${workflow}" == "Update" or "${workflow}" == "Heads Transition"
        IF    "{workflow}" == "Heads Transition"
            ${version}=    Set Variable
            ...    ${DTS_TEST_VARIABLES}[DTS_TEST_HEAD_TRANSITION_FROM_VERSION]
        ELSE
            ${version}=    Set Variable
            ...    ${DTS_TEST_VARIABLES}[DTS_TEST_UPDATE_VERSION]
        END
        ${additional_exports}[TEST_BIOS_VERSION]=
        ...    Set Variable    "Dasharo (coreboot+UEFI) ${version}"
        ${additional_exports}[TEST_BIOS_VENDOR]=    Set Variable    "3mdeb"
        IF    ${DTS_TEST_VARIABLES}[DTS_TEST_HAS_EC]
            ${additional_exports}[TEST_USING_OPENSOURCE_EC_FIRM]=
            ...    Set Variable    "true"
        END
    ELSE IF    "${workflow}" == "Initial Deployment"
        ${variables_mapping}[TEST_BIOS_VERSION]=    Set Variable
        ...    DTS_TEST_VERSION
    END
    ${additional_exports}[DTS_TESTING]=    Set Variable    "true"

    FOR    ${export_variable}    ${robot_variable}    IN    &{variables_mapping}
        Log To Console
        ...    export ${export_variable}=${DTS_TEST_VARIABLES}[${robot_variable}]
        # Execute Command In Terminal
        # ...    export ${export_variable}=${DTS_TEST_VARIABLES}[${robot_variable}]
    END
    FOR    ${export_variable}    ${export_value}    IN    &{additional_exports}
        Log To Console
        ...    export ${export_variable}=${export_value}
        # Execute Command In Terminal
        # ...    export ${export_variable}=${export_value}
    END

Prepare DTS Test
    Start New DTS SSH Session In QEMU

Teardown DTS Test
    [Documentation]    Close SSH session and cleanup all possible changes made
    ...    during test
    Restore Initial DUT Connection Method
    # not sure if it's needed if we don't want to keep multiple sessions in
    # background
    SSHLibrary.Close Connection
    Set Prompt For Terminal    bash-5.2#
    Execute Linux Command    rm -rf /etc/cloud-pass /root/.mc

Start New DTS SSH Session In QEMU
    [Documentation]    Changes connection method to ssh and logs in to DTS
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Login To DTS Via SSH In QEMU

Login To DTS Via SSH In QEMU
    [Documentation]    Modified 'Login to Linux via SSH' keyword with ip set to
    ...    localhost and port set to 5222.
    [Arguments]    ${timeout}=180    ${prompt}=root@DasharoToolsSuite:~#
    SSHLibrary.Open Connection    localhost    port=5222    prompt=${prompt}
    SSHLibrary.Set Client Configuration
    ...    timeout=${timeout}
    ...    term_type=vt100
    ...    width=400
    ...    height=100
    ...    escape_ansi=True
    ...    newline=LF
    Wait Until Keyword Succeeds    3x    1s
    ...    SSHLibrary.Login    root

Prepare DTS E2E Test Suite
    # Prepare Test Suite
    # Skip If    not ${DTS_SUPPORT}
    &{dts_platform_variables}=    Get DTS Test Variables
    Set Suite Variable    \${DTS_PLATFORM_VARIABLES}
    # Power On And Enter DTS Shell
    # Execute Linux Command    systemctl start sshd
