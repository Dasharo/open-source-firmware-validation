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
                ${platform}    ${workflow}    ${release}
            END
        END
    END
    [Teardown]    Teardown Template E2E DTS Test

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

E2E002.001 DCR Initial Deployment On Msi-pro-z690-a-ddr5 With 13th Gen CPU Should Fail
    [Documentation]    Check if installing DCR v1.1.1 fails on
    ...    msi-pro-z690-a-ddr5 with 13gen CPU.
    Perform DCR Initial Deployment On Incompatible CPU Regression Test    msi-pro-z690-a-ddr5

E2E002.002 DCR Initial Deployment On Msi-pro-z690-a-wifi-ddr4 With 13th Gen CPU Should Fail
    [Documentation]    Check if installing DCR v1.1.1 fails on
    ...    msi-pro-z690-a-wifi-ddr4 with 13gen CPU.
    Perform DCR Initial Deployment On Incompatible CPU Regression Test    msi-pro-z690-a-wifi-ddr4

E2E003.001 DCR UEFI Update On Msi-pro-z690-a-ddr5 With 13th Gen CPU Should Fail
    [Documentation]    Check if updating to DCR v1.1.1 fails on
    ...    msi-pro-z690-a-ddr5 with 13gen CPU.
    Perform DCR UEFI Update On Incompatible CPU Regression Test    msi-pro-z690-a-ddr5

E2E003.002 DCR UEFI Update On Msi-pro-z690-a-wifi-ddr4 With 13th Gen CPU Should Fail
    [Documentation]    Check if updating to DCR v1.1.1 fails on
    ...    msi-pro-z690-a-wifi-ddr4 with 13gen CPU.
    Perform DCR UEFI Update On Incompatible CPU Regression Test    msi-pro-z690-a-wifi-ddr4


*** Keywords ***
# robocop: disable:0919
${platform} ${workflow} - ${release}
    [Documentation]    Fallback keyword, should only enter if there is a typo
    ...    in DTS_TEST_WORKFLOWS or DTS_TEST_RELEASES
    Fail    Unknown workflow (${workflow}) or release (${release})
# robocop: enable

${platform} UEFI Update - DCR
    [Documentation]    Update workflow for Dasharo Community Release
    Prepare E2E Test
    Go Through Update    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} SeaBIOS Update - DCR
    [Documentation]    Update workflow for Dasharo Community Release
    Prepare E2E Test
    Go Through Update
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} Initial Deployment - DCR
    [Documentation]    Initial deployment workflow for Dasharo Community Release
    Prepare E2E Test
    Go Through Initial Deployment    DCR UEFI    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} UEFI Update - DPP
    [Documentation]    Update workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Update    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} SeaBIOS Update - DPP
    [Documentation]    Update workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Update
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} Initial Deployment - DPP
    [Documentation]    Initial deployment workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Initial Deployment    DPP UEFI    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} UEFI->Heads Transition - DPP
    [Documentation]    Heads transition workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Heads Transition    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} SeaBIOS->UEFI Transition - DPP
    [Documentation]    Heads transition workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Transition    DPP UEFI
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} Dasharo (coreboot+UEFI) To Dasharo (Slim Bootloader+UEFI) Transition - DPP
    [Documentation]    Transition to Dasharo (Slim) workflow with DPP credentials
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Transition    DPP Slim Bootloader + UEFI    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

${platform} Dasharo (Slim Bootloader+UEFI) Initial Deployment - DPP
    [Documentation]    Initial deployment workflow for Slim Bootloadere + UEFI
    Prepare E2E Test
    Provide DPP Credentials
    Go Through Initial Deployment    DPP Slim Bootloader + UEFI    skip_me=${TRUE}
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

Prepare E2E Test
    [Documentation]    Prepare everything needed for platform and workflow
    ...    emulation. Keyword has to be run in shell. After keyword ends we
    ...    should be in DTS menu
    ${platform}=    Evaluate    '${TEST_NAME}'.split()[1]
    ${release}=    Evaluate    '${TEST_NAME}'.split()[-1]
    ${workflow}=    Evaluate    ' '.join('${TEST_NAME}'.split()[2:-2])
    # Verify if DTS_CONFIG_REF is set via `-v` argument
    Variable Should Exist    ${DTS_CONFIG_REF}
    Export Shell Variables For Emulation
    ...    ${workflow}
    ...    ${release}
    ...    ${DTS_PLATFORM_VARIABLES}[${platform}]
    ...    ${DTS_CONFIG_REF}
    # TODO: needed by 'Go Through Initial Deployment' keyword for couple of
    # NovaCustom boards
    VAR    ${DTS_TEST_BOARD_MODEL}=    ${DTS_PLATFORM_VARIABLES}[${platform}][DTS_TEST_BOARD_MODEL]    scope=TEST
    Execute Command In Terminal
    ...    rm -rf /etc/cloud-pass /root/.mc /*.tar.gz /root/*.tar.gz /tmp/logs/*profile /tmp/dts-temp-files
    Write Into Terminal    dts-boot

Prepare DTS Test
    [Documentation]    Used as test setup. Starts new SSH session so we start
    ...    with clean shell environment for each test
    Start New DTS SSH Session In QEMU

Teardown Template E2E DTS Test
    [Documentation]    Close SSH session, verify profile if needed and cleanup
    ...    all possible changes made during test
    Restore Initial DUT Connection Method
    # not sure if it's needed if we don't want to keep multiple sessions in
    # background
    SSHLibrary.Close Connection
    Set Prompt For Terminal    bash-5.2#
    TRY
        ${platform}=    Evaluate    '${TEST_NAME}'.split()[1]
        ${release}=    Evaluate    '${TEST_NAME}'.split()[-1]
        ${workflow}=    Evaluate    ' '.join('${TEST_NAME}'.split()[2:-2])
        VAR    ${profiles}=    ${DTS_PLATFORM_VARIABLES}[${platform}][DTS_TEST_WORKFLOW_PROFILES]
        ${verify_profile}=    Run Keyword And Return Status    List Should Contain Value
        ...    ${profiles}    ${{ ("${workflow}", "${release}" ) }}
        IF    ${verify_profile}
            # strip 'E2Exxx: ' prefix from test name
            ${profile_name}=    Evaluate    $TEST_NAME.split(":")[1].strip()
            VAR    ${profile}=    ${CURDIR}/profiles/${profile_name}.profile
            OperatingSystem.File Should Exist    ${profile}
            IF    "${TEST_STATUS}" == "PASS"
                Get File From DUT    /tmp/logs/profile    /tmp/robotframework-dts-profile
                ${rc}    ${output}=    Run And Return Rc And Output
                ...    diff -u1 /tmp/robotframework-dts-profile "${profile}"
                Should Be Equal As Integers    ${rc}    0    Profiles are not identical!
            END
        ELSE
            Log    Workflow isn't configured for profile verification.    WARN
        END
    FINALLY
        Execute Command In Terminal
        ...    rm -rf /etc/cloud-pass /root/.mc /*.tar.gz /root/*.tar.gz /tmp/logs /tmp/dts-temp-files
    END

Teardown DTS Test
    [Documentation]    Close SSH session and cleanup all possible changes made
    ...    during test
    Restore Initial DUT Connection Method
    # not sure if it's needed if we don't want to keep multiple sessions in
    # background
    SSHLibrary.Close Connection
    Set Prompt For Terminal    bash-5.2#
    Execute Command In Terminal
    ...    rm -rf /etc/cloud-pass /root/.mc /*.tar.gz /root/*.tar.gz /tmp/logs /tmp/dts-temp-files

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
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=SUITE
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=SUITE
    Power On And Enter DTS Shell
    Set Prompt For Terminal    bash-5.2#
    Execute Command In Terminal    systemctl start sshd

Perform DCR Initial Deployment On Incompatible CPU Regression Test
    [Documentation]    Given a board with DCR-incompatible CPU, expect an error
    ...    when trying to perform an Initial Deployment
    [Arguments]    ${board}

    # 1) Prepare DTS for testing:
    Export Shell Variables For Emulation
    ...    Initial Deployment
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[${board}]
    ...    ${DTS_CONFIG_REF}

    Execute Command In Terminal
    ...    export TEST_CPU_VERSION="13th Gen Intel(R) Core(TM) i9-13900K"

    Write Into Terminal    dts-boot

    # 2) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 3) Wait for HCL report to do its work:
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    N

    # 4) Choose version to install:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DCR_UEFI_OPT}

    # 5) Pass the test if the "Aborting deployment..." message shows up:
    ${checkpoint}=    Wait For Checkpoint    ${DTS_13_GEN_REGRESSION}

Perform DCR UEFI Update On Incompatible CPU Regression Test
    [Documentation]    Given a board with DCR-incompatible CPU, expect an error
    ...    when trying to perform UEFI Update
    [Arguments]    ${board}

    # 1) Prepare DTS for testing:
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[${board}]
    ...    ${DTS_CONFIG_REF}

    Execute Command In Terminal
    ...    export TEST_CPU_VERSION="13th Gen Intel(R) Core(TM) i9-13900K"

    Write Into Terminal    dts-boot

    # 2) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 3) Pass the test if the "Aborting deployment..." message shows up:
    ${checkpoint}=    Wait For Checkpoint    ${DTS_13_GEN_REGRESSION}
