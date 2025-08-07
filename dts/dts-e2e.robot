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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Prepare DTS Test
Test Teardown       Teardown DTS Test


*** Test Cases ***
Create tests
    [Template]    ${platform} ${workflow} - ${release}
    FOR    ${platform}    ${platform_variables}    IN    &{DTS_PLATFORM_VARIABLES}
        FOR    ${workflow}    IN    @{platform_variables}[DTS_TEST_WORKFLOWS]
            FOR    ${release}    IN    @{platform_variables}[DTS_TEST_WORKFLOW_RELEASES][${workflow}]
                ${platform}    ${workflow}    ${platform_variables}[DTS_TEST_VERSIONS][${workflow}]
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
${platform} ${workflow} - ${release}
    [Documentation]    Fallback keyword, should only enter if there is a typo
    ...    in DTS_TEST_WORKFLOWS or DTS_TEST_RELEASES
    Fail    Unknown workflow (${workflow}) or release (${release})
# robocop: enable

${platform} UEFI Update - DCR
    [Documentation]    Update workflow for Dasharo Community Release
    Prepare E2E Test    ${platform}    UEFI Update
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} SeaBIOS Update - DCR
    [Documentation]    Update workflow for Dasharo Community Release
    Prepare E2E Test    ${platform}    SeaBIOS Update
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} Initial Deployment - DCR
    [Documentation]    Initial deployment workflow for Dasharo Community Release
    Prepare E2E Test    ${platform}    Initial Deployment
    Go Through Initial Deployment    DCR UEFI
    Wait For Checkpoint    Rebooting

${platform} UEFI Update - DPP
    [Documentation]    Update workflow with DPP credentials
    Prepare E2E Test    ${platform}    UEFI Update
    Provide DPP Credentials
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} SeaBIOS Update - DPP
    [Documentation]    Update workflow with DPP credentials
    Prepare E2E Test    ${platform}    SeaBIOS Update
    Provide DPP Credentials
    Go Through Update
    Wait For Checkpoint    Rebooting

${platform} Initial Deployment - DPP
    [Documentation]    Initial deployment workflow with DPP credentials
    Prepare E2E Test    ${platform}    Initial Deployment
    Provide DPP Credentials
    Go Through Initial Deployment    DPP UEFI
    Wait For Checkpoint    Rebooting

${platform} UEFI->Heads Transition - DPP
    [Documentation]    Heads transition workflow with DPP credentials
    Prepare E2E Test    ${platform}    UEFI->Heads Transition
    Provide DPP Credentials
    Go Through Heads Transition
    Wait For Checkpoint    Rebooting

${platform} SeaBIOS->UEFI Transition - DPP
    [Documentation]    Heads transition workflow with DPP credentials
    Prepare E2E Test    ${platform}    SeaBIOS->UEFI Transition
    Provide DPP Credentials
    Go Through Transition    DPP UEFI
    Wait For Checkpoint    Rebooting

Prepare E2E Test
    [Documentation]    Prepare everything needed for platform and workflow
    ...    emulation. Keyword has to be run in shell. After keyword ends we
    ...    should be in DTS menu
    [Arguments]    ${platform}    ${workflow}
    Export Shell Variables For Emulation    ${workflow}    ${DTS_PLATFORM_VARIABLES}[${platform}]
    # TODO: needed by 'Go Through Initial Deployment' keyword for couple of
    # NovaCustom boards
    VAR    ${DTS_TEST_BOARD_MODEL}=    ${DTS_PLATFORM_VARIABLES}[${platform}][DTS_TEST_BOARD_MODEL]    scope=TEST
    Write Into Terminal    dts-boot

Prepare DTS Test
    [Documentation]    Used as test setup. Starts new SSH session so we start
    ...    with clean shell environment for each test
    Start New DTS SSH Session In QEMU

Teardown DTS Test
    [Documentation]    Close SSH session and cleanup all possible changes made
    ...    during test
    Restore Initial DUT Connection Method
    # not sure if it's needed if we don't want to keep multiple sessions in
    # background
    SSHLibrary.Close Connection
    Set Prompt For Terminal    bash-5.2#
    Execute Linux Command    rm -rf /etc/cloud-pass /root/.mc /*.tar.gz /root/*.tar.gz

Start New DTS SSH Session In QEMU
    [Documentation]    Changes connection method to ssh and logs in to DTS
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=GLOBAL
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
    Prepare Test Suite
    Skip If    not ${DTS_SUPPORT}
    &{dts_vars}=    Get DTS Test Variables
    VAR    ${DTS_PLATFORM_VARIABLES}=    ${dts_vars}    scope=SUITE
    Power On And Enter DTS Shell
    Set Prompt For Terminal    bash-5.2#
    Execute Linux Command    systemctl start sshd
