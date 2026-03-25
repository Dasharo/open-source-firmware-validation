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
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_HCL_OPT}

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

################################################################################
# Credentials tests:
################################################################################

E2E007.001 Check credentials are being saved correctly
    [Documentation]    Check that credentials are saved to /etc/cloud-pass and
    ...    to mc correctly
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    Provide DPP Credentials
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${creds}=    Execute Command In Terminal    cat /etc/cloud-pass
    @{lines}=    Split To Lines    ${creds}
    ${line_num}=    Get Length    ${lines}
    Should Be Equal As Integers    ${line_num}    2    cloud-pass file should have only 2 lines
    IF    "${lines}[0]" != "${DPP_EMAIL}" or "${lines}[1]" != "${DPP_PASSWORD}"
        Fail    E-mail or password is different from expected
    END
    ${creds2}=    Execute Command In Terminal    mc alias ls premium | grep "Key" | awk '{print $3}'
    Should Be Equal    ${creds}    ${creds2}
    ...    /etc/cloud-pass and mc credentials differ

E2E007.002 Check old credentials are being overwritten by new
    [Documentation]    Make sure that entering new credentials results in old
    ...    being overwritten. Requires 2 sets of working credentials as mc
    ...    doesn't save credentials that do not work.
    Depends On Variable    \${DPP_EMAIL_FW_ONLY}
    Depends On Variable    \${DPP_PASSWORD_FW_ONLY}
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    Provide DPP Credentials
    VAR    ${DPP_EMAIL}=    ${DPP_EMAIL_FW_ONLY}    scope=TEST
    VAR    ${DPP_PASSWORD}=    ${DPP_PASSWORD_FW_ONLY}    scope=TEST
    Provide DPP Credentials
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS

    ${creds}=    Execute Command In Terminal    cat /etc/cloud-pass
    @{lines}=    Split To Lines    ${creds}
    ${line_num}=    Get Length    ${lines}
    Should Be Equal As Integers    ${line_num}    2    cloud-pass file should have only 2 lines
    IF    "${lines}[0]" != "${DPP_EMAIL_FW_ONLY}" or "${lines}[1]" != "${DPP_PASSWORD_FW_ONLY}"
        Fail    E-mail or password is different from expected
    END
    ${creds2}=    Execute Command In Terminal    mc alias ls premium | grep "Key" | awk '{print $3}'
    Should Be Equal    ${creds}    ${creds2}
    ...    /etc/cloud-pass and mc credentials differ

E2E007.003 Check wrong credentials should not allow to log into DPP services
    [Documentation]    Entering wrong credentials shouldn't allow access to DPP
    ...    services and shouldn't be saved
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    VAR    ${DPP_EMAIL}=    test@email.com    scope=TEST
    VAR    ${DPP_PASSWORD}=    test-password    scope=TEST
    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    Cannot log in to DPP server
    Should Not Contain    ${out}    Dasharo DPP credentials are valid and have been saved
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${creds}=    Execute Command In Terminal    cat /etc/cloud-pass
    Should Not Contain Any    ${creds}    ${DPP_EMAIL}    ${DPP_PASSWORD}
    ${creds2}=    Execute Command In Terminal
    ...    mc alias ls premium | grep "Key" | awk '{print $3}'
    Should Not Contain Any    ${creds2}    ${DPP_EMAIL}    ${DPP_PASSWORD}

E2E007.004 Check correct credentials should allow to log into DPP services
    [Documentation]    Entering correct credentials should allow access to DPP
    ...    services
    # We need to simulate supported platform
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[odroid-h4-plus]
    ...    ${DTS_CONFIG_REF}
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    Dasharo Pro Package (DPP): YES
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${rc}=    Execute Command In Terminal And Return RC    mc ls premium
    Should Be Equal As Integers    ${rc}    0
    ...    mc command failed to list buckets

E2E007.005 Check empty e-mail should not pass
    [Documentation]    Entering empty e-mail shouldn't be allowed
    Write Into Terminal    dts-boot
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_CREDENTIALS_OPT}
    Wait For Checkpoint And Press Enter    ${DPP_EMAIL_CHECKPOINT}
    Set DUT Response Timeout    15s
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${lines}=    Execute Command In Terminal
    ...    cat /etc/cloud-pass 2>/dev/null | wc -l
    Should Be Equal As Integers    ${lines}    0    cloud-pass shouldn't exist or at least be empty

E2E007.006 Check empty password should not pass
    [Documentation]    Entering empty password shouldn't be allowed
    Write Into Terminal    dts-boot
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_CREDENTIALS_OPT}
    Wait For Checkpoint And Write    ${DPP_EMAIL_CHECKPOINT}    ${DPP_EMAIL}
    Wait For Checkpoint And Press Enter    ${DPP_PASSWORD_CHECKPOINT}
    ${out}=    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Should Not Contain    ${out}    Dasharo Pro Package (DPP):
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${lines}=    Execute Command In Terminal
    ...    cat /etc/cloud-pass 2>/dev/null | wc -l
    Should Be Equal As Integers    ${lines}    0    cloud-pass shouldn't exist or at least be empty

E2E007.008 Check DPP credentials with access to only firmware
    [Documentation]    Those credentials should allow access only to DPP
    ...    firmware
    Depends On Variable    \${DPP_EMAIL_FW_ONLY}
    Depends On Variable    \${DPP_PASSWORD_FW_ONLY}
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[odroid-h4-plus]
    ...    ${DTS_CONFIG_REF}
    Write Into Terminal    dts-boot

    VAR    ${DPP_EMAIL}=    ${DPP_EMAIL_FW_ONLY}    scope=TEST
    VAR    ${DPP_PASSWORD}=    ${DPP_PASSWORD_FW_ONLY}    scope=TEST
    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    Dasharo Pro Package (DPP): YES
    Should Contain    ${out}    DTS Extensions: NO

E2E007.009 Check DPP credentials with access to only extensions
    [Documentation]    Those credentials should allow access only to DTS
    ...    extensions
    Depends On Variable    \${DPP_EMAIL_EXTENSIONS_ONLY}
    Depends On Variable    \${DPP_PASSWORD_EXTENSIONS_ONLY}
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[odroid-h4-plus]
    ...    ${DTS_CONFIG_REF}
    Write Into Terminal    dts-boot

    VAR    ${DPP_EMAIL}=    ${DPP_EMAIL_EXTENSIONS_ONLY}    scope=TEST
    VAR    ${DPP_PASSWORD}=    ${DPP_PASSWORD_EXTENSIONS_ONLY}    scope=TEST
    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    DTS Extensions: YES

E2E007.010 Check DPP credentials without DPP access
    [Documentation]    Those credentials shouldn't allow access to any firmware
    ...    or DTS extensions
    Depends On Variable    \${DPP_EMAIL_NO_ACCESS}
    Depends On Variable    \${DPP_PASSWORD_NO_ACCESS}
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[odroid-h4-plus]
    ...    ${DTS_CONFIG_REF}
    Write Into Terminal    dts-boot

    VAR    ${DPP_EMAIL}=    ${DPP_EMAIL_NO_ACCESS}    scope=TEST
    VAR    ${DPP_PASSWORD}=    ${DPP_PASSWORD_NO_ACCESS}    scope=TEST
    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    Something may be wrong with the DPP credentials
    ${out}=    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Should Contain    ${out}    Dasharo Pro Package (DPP): NO
    Should Contain    ${out}    DTS Extensions: NO

E2E007.011 Check DPP credentials with both DPP firmware and DTS extensions access
    [Documentation]    Those credentials should allow access to both DPP
    ...    firmware and DTS extensions
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[odroid-h4-plus]
    ...    ${DTS_CONFIG_REF}
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Should Contain    ${out}    Dasharo Pro Package (DPP): YES
    Should Contain    ${out}    DTS Extensions: YES

################################################################################
# DTS UI options tests:
################################################################################

E2E008.001 Reboot UI Option Calls Reboot Command
    [Documentation]    Reboot (R) UI option should call mocked reboot command
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Write Bare Into Terminal    R
    Wait For Checkpoint    common_mock: using reboot

E2E008.002 Poweroff UI Option Calls Poweroff Command
    [Documentation]    Poweroff (P) UI option should call mocked poweroff
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Write Bare Into Terminal    P
    Wait For Checkpoint    common_mock: using poweroff

E2E008.003 Launch SSH Server UI Option Enables SSH Server Command
    [Documentation]    Launch SSH Server (K) UI option should start sshd server
    Execute Command In Terminal    export DTS_TESTING="true"
    Execute Command In Terminal    systemctl stop sshd
    Write Into Terminal    dts-boot
    ${out}=    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Should Not Contain    ${out}    SSH status: ON
    Write Bare Into Terminal    K
    ${out}=    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Should Contain All    ${out}    Starting SSH server!    Listening on IPs
    ${out}=    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Should Contain    ${out}    SSH status: ON

E2E008.004 Enable Sending Logs UI Option Should Enable DTS Log Sending
    [Documentation]    Enable Sending DTS Logs (L) should enable automatic log
    ...    sending e.g. when entering shell
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot
    ${out}=    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Should Contain    ${out}    L to enable
    Write Bare Into Terminal    L
    ${out}=    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Should Contain    ${out}    L to disable
    Write Bare Into Terminal    S
    SSHLibrary.Read Until    Sending logs...

################################################################################
# DTS extentions tests:
################################################################################

E2E009.001 DTS extensions are installed and can be used
    [Documentation]    Test that DTS extensions are installed after entering DPP
    ...    keys with access to them and that they can be used after.
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Should Contain    ${out}
    ...    Package txeconfigtool-git-r0.core2_64.rpm have been installed successfully!
    Wait For Checkpoint    ${DTS_CHECKPOINT}
    Enter Shell In DTS
    ${rc}=    Execute Command In Terminal And Return RC    command -V txeconfigtool
    Should Be Equal As Integers    ${rc}    0    txeconfigtool can't be found

E2E010.001 Failure to read flash during update should stop workflow
    [Documentation]    Test that update stops if flash read in
    ...    set_flashrom_update_params function fails.
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_LAYOUT_READ_SHOULD_FAIL="true"
    Write Into Terminal    dts-boot

    VAR    @{checkpoints}=    @{EMPTY}
    Add Checkpoint And Write    ${checkpoints}    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}    bare=${TRUE}
    Add Optional Checkpoint And Write    ${checkpoints}    ${DTS_HEADS_SWITCH_QUESTION}    N
    Add Checkpoint And Write    ${checkpoints}    ${DTS_SPECIFICATION_WARN}    Y
    Add Checkpoint And Write    ${checkpoints}    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoints    ${checkpoints}
    Wait For Checkpoint    Couldn't read flash
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E011.001 Aborting update after smmstore migration failure should stop workflow
    [Documentation]    Test that update stops if user doesn't want to continue
    ...    update after smmstore migration failure
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_BOARD_HAS_SMMSTORE="false"
    Write Into Terminal    dts-boot

    VAR    @{checkpoints}=    @{EMPTY}
    Add Checkpoint And Write    ${checkpoints}    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}    bare=${TRUE}
    Add Optional Checkpoint And Write    ${checkpoints}    ${DTS_HEADS_SWITCH_QUESTION}    N
    Add Checkpoint And Write    ${checkpoints}    ${DTS_SPECIFICATION_WARN}    Y
    Add Checkpoint And Write    ${checkpoints}    ${DTS_DEPLOY_WARN}    Y
    Add Checkpoint And Write    ${checkpoints}    Do you want to proceed with update    N
    ${out}=    Wait For Checkpoints    ${checkpoints}
    Should Contain    ${out}    Couldn't migrate BIOS configuration
    Wait For Checkpoint    Aborting...
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E012.001 Continuing update after smmstore migration failure should succeed
    [Documentation]    Test that update succeeds if user wants to continue even
    ...    if smmstore migration failed
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_BOARD_HAS_SMMSTORE="false"
    Write Into Terminal    dts-boot

    VAR    @{checkpoints}=    @{EMPTY}
    Add Checkpoint And Write    ${checkpoints}    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}    bare=${TRUE}
    Add Optional Checkpoint And Write    ${checkpoints}    ${DTS_HEADS_SWITCH_QUESTION}    N
    Add Checkpoint And Write    ${checkpoints}    ${DTS_SPECIFICATION_WARN}    Y
    Add Checkpoint And Write    ${checkpoints}    ${DTS_DEPLOY_WARN}    Y
    Add Checkpoint And Write    ${checkpoints}    Do you want to proceed with update    Y
    ${out}=    Wait For Checkpoints    ${checkpoints}
    Should Contain    ${out}    Couldn't migrate BIOS configuration
    Wait For Checkpoint    Continuing update without migrating BIOS configuration
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

################################################################################
# FUM tests
################################################################################

E2E013.001 Verify that FUM update doesn't start automatically
    [Documentation]    Test that booting via FUM doesn't start update without
    ...    user input
    Execute Command In Terminal    export DTS_TESTING="true"
    Execute Command In Terminal    export TEST_FUM="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint    You have entered Firmware Update Mode
    Wait For Checkpoint    ${DTS_ASK_FOR_CHOICE_PROMPT}

E2E013.002 Verify that FUM update succeeds
    [Documentation]    Test that FUM update succeeds without user input
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_FUM="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

E2E013.003 Verify that entering DTS menu in FUM works
    [Documentation]    Test that booting via FUM doesn't start update without
    ...    user input
    Execute Command In Terminal    export DTS_TESTING="true"
    Execute Command In Terminal    export TEST_FUM="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_MENU_OPT}
    Wait For Checkpoint    ${DTS_CHECKPOINT}

################################################################################
# https://github.com/Dasharo/dasharo-issues/issues/1759 tests
################################################################################

E2E014.001 Verify that capsule update while in FUM stops if unsupported
    [Documentation]    Test that FUM update is stopped with expected error
    ...    message when trying to use capsule update on firmware version that
    ...    doesn't support this combination
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.0"
    Execute Command In Terminal    export TEST_FUM_ORIG="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}
    Wait For Checkpoint    ${CAP_FUM_ERROR}
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E014.002 Verify that fusing while in FUM stops if unsupported
    [Documentation]    Test that fusing while in FUM is stopped with expected
    ...    error message when trying to do it on firmware version that doesn't
    ...    support this combination
    Export Shell Variables For Emulation
    ...    Fuse Platform
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.0"
    Execute Command In Terminal    export TEST_FUM_ORIG="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_MENU_OPT}
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_FUSE_OPT}
    Wait For Checkpoint    ${CAP_FUM_ERROR}
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E014.003 Verify that capsule update while in FUM works if supported
    [Documentation]    Test that FUM capsule update works correctly when on
    ...    firmware version that supports this combination
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.1"
    Execute Command In Terminal    export TEST_SYSTEM_VENDOR="3mdeb_test_config"
    Execute Command In Terminal    export TEST_SYSTEM_MODEL="fum_cap_test"
    Execute Command In Terminal    export TEST_FUM_ORIG="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

E2E014.004 Verify that fusing while in FUM works if supported
    [Documentation]    Test that fusing while in FUM works if done on firmware
    ...    version that supports this combination
    Export Shell Variables For Emulation
    ...    Fuse Platform
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.1"
    Execute Command In Terminal    export TEST_SYSTEM_VENDOR="3mdeb_test_config"
    Execute Command In Terminal    export TEST_SYSTEM_MODEL="fum_cap_test"
    Execute Command In Terminal    export TEST_FUM_ORIG="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_MENU_OPT}
    Go Through Fusing Platform

E2E014.005 Verify that capsule update while in FUM with workaround works
    [Documentation]    Test that FUM capsule update works correctly when using
    ...    replace_fum_efivar.efi
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.0"
    Execute Command In Terminal    export TEST_FUM="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

E2E014.006 Verify that fusing while in FUM with workaround works
    [Documentation]    Test that fusing while in FUM works when using
    ...    replace_fum_efivar.efi
    Export Shell Variables For Emulation
    ...    Fuse Platform
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.0"
    Execute Command In Terminal    export TEST_FUM="true"
    Write Into Terminal    dts-boot

    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_MENU_OPT}
    Go Through Fusing Platform

################################################################################
# IBG signature tests
################################################################################

E2E016.001 Verify that btg_key_validator prints expected error on unknown platform
    [Documentation]    Call btg_key_validator on platform that doesn't support
    ...    fusing
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    btg_key_validator
    Should Contain    ${out}    Platform configuration is missing expected key hash
    Should Not Be Equal As Integers    ${rc}    0

E2E016.002 Verify that btg_key_validator prints expected error on failure to read flash
    [Documentation]    Call btg_key_validator on platform that doesn't support
    ...    reading flash
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    btg_key_validator --key-hash z
    Should Contain    ${out}    Failed to read flash
    Should Not Be Equal As Integers    ${rc}    0

E2E016.003 Verify that btg_key_validator prints expected error on failure to export manifest
    [Documentation]    Call btg_key_validator on malformed binary
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    touch /tmp/test_binary && btg_key_validator --key-hash z --file /tmp/test_binary
    Should Contain    ${out}    Failed to export key manifest
    Should Not Be Equal As Integers    ${rc}    0

E2E016.004 Verify that btg_key_validator prints expected error if hashes don't match
    [Documentation]    Call btg_key_validator on binary signed with unexpected key
    Execute Command In Terminal Should Succeed
    ...    wget -O /tmp/test_binary https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_v5x0_mtl/novacustom_mtl_igpu/novacustom_v540tu_mtl/uefi/v1.0.0/novacustom_v54x_mtl_igpu_v1.0.0_btg_provisioned.cap
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    btg_key_validator --key-hash z --file /tmp/test_binary
    Should Contain    ${out}    Firmware signature doesn't match expected hash
    Should Not Be Equal As Integers    ${rc}    0

E2E016.005 Verify that btg_key_validator prints expected message if hashes match
    [Documentation]    Call btg_key_validator on binary signed with expected key
    Execute Command In Terminal Should Succeed
    ...    wget -O /tmp/test_binary https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_v5x0_mtl/novacustom_mtl_igpu/novacustom_v540tu_mtl/uefi/v1.0.0/novacustom_v54x_mtl_igpu_v1.0.0_btg_provisioned.cap
    ${out}    ${rc}=    Execute Command In Terminal And Return Output And RC
    ...    btg_key_validator --key-hash e64b6b0e82c68fecc58f750d3696c26e1c98bf9e3149c81f3b2ed775eb9d2c157a99c103c62c44c0cdc61be971caeae1 --file /tmp/test_binary
    Should Contain    ${out}    Firmware is signed with expected key hash
    Should Be Equal As Integers    ${rc}    0

E2E016.006 Verify that fuse workflow uses and verifies btg_key_validator
    [Documentation]    Run fuse workflow and simulate btg_key_validator failure
    Export Shell Variables For Emulation
    ...    Fuse Platform
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_KEY_VALIDATOR_RESULT="fail_hash"
    Write Into Terminal    dts-boot

    Set DUT Response Timeout    120s

    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_FUSE_OPT}
    Wait For Checkpoint And Write    ${DTS_FUSE_WARN}    Y
    Wait For Checkpoint    Firmware signature doesn't match expected hash
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

################################################################################
# ROMHOLE migration tests
################################################################################

E2E017.001 Firmware installation should stop if ROMHOLE cannot be read for migration
    [Documentation]    Test checks whether DTS logic prevents user from
    ...    Overwriting ROMHOLE Region In Case There Was A Failure During Read
    Export Shell Variables For Emulation
    ...    UEFI->Heads Transition
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[msi-pro-z790-p-ddr5]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_READ_ROMHOLE_FAIL="true"
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoint    Failed to migrate ROMHOLE.
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E017.002 Firmware installation should stop if there is no place to migrate ROMHOLE to
    [Documentation]    Test checks whether DTS logic prevents user from
    ...    Overwriting ROMHOLE Region In Case There Is No Place To Migrate
    ...    ROMHOLE To
    Export Shell Variables For Emulation
    ...    UEFI->Heads Transition
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[msi-pro-z790-p-ddr5]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_ROMHOLE_MIGRATION_TO=""
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoint    ROMHOLE not found in the firmware file to be flashed. Cannot migrate ROMHOLE.
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E017.003 Firmware installation should stop in case of ROMHOLE migration from CBFS to flashmap
    [Documentation]    Test checks whether DTS logic prevents user from
    ...    potential brick during migration from CBFS to flashmap which is not
    ...    supported yet
    Export Shell Variables For Emulation
    ...    UEFI->Heads Transition
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[msi-pro-z790-p-ddr5]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_ROMHOLE_MIGRATION_FROM="cbfs"
    Execute Command In Terminal    export TEST_ROMHOLE_MIGRATION_TO="flashmap"
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoint    ROMHOLE migration from CBFS is not supported yet. Cannot migrate ROMHOLE.
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

E2E017.004 Firmware installation should stop in case of ROMHOLE migration from CBFS to CBFS
    [Documentation]    Test checks whether DTS logic prevents user from
    ...    potential brick during migration from CBFS to CBFS which is not
    ...    supported yet
    Export Shell Variables For Emulation
    ...    UEFI->Heads Transition
    ...    DPP
    ...    ${DTS_PLATFORM_VARIABLES}[msi-pro-z790-p-ddr5]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_ROMHOLE_MIGRATION_FROM="cbfs"
    Execute Command In Terminal    export TEST_ROMHOLE_MIGRATION_TO="cbfs"
    Write Into Terminal    dts-boot

    ${out}=    Provide DPP Credentials
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoint    ROMHOLE migration from CBFS is not supported yet. Cannot migrate ROMHOLE.
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

################################################################################
# Capsule update tests
################################################################################

E2E018.001 Failure to pass capsule to /dev/efi_capsule_loader is detected
    [Documentation]    Test checks that failure to queue capsule update by
    ...    writing it to /dev/efi_capsule_loader is detected and handled
    ...    gracefully
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v540tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_CAPSULE_UPDATE_FAIL="true"
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 1.0.0-rc8"
    Write Into Terminal    dts-boot

    Set DUT Response Timeout    120s
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Wait For Checkpoint    Failed to queue capsule update!
    Wait For Checkpoint    ${ERROR_LOGS_QUESTION}

################################################################################
# ME operation mode detection tests
################################################################################

E2E019.001 DTS must stop update in case ME is enabled
    [Documentation]    Flashing ME when it is enabled might cause issues, so
    ...    DTS must detect such situation and ask whether to stop update or
    ...    update without flashing ME.
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v560tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_FUM="true"
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_ME_HAP_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_OP_MODE="0"
    Write Into Terminal    dts-boot

    Wait For Checkpoint    You have entered Firmware Update Mode
    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}

    Set DUT Response Timeout    120s
    Wait For Checkpoint    ${DTS_ME_WARN}

E2E019.002 DTS should continue update in case ME is HAP disabled
    [Documentation]    HAP disabled ME operation mode is considered a safe mode
    ...    to update ME. DTS should detect this and proceed with the update.
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v560tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_FUM="true"
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Write Into Terminal    dts-boot

    Wait For Checkpoint    You have entered Firmware Update Mode
    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}

    Set DUT Response Timeout    120s
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

E2E019.003 DTS should continue update in case ME is neither HAP disabled or enabled
    [Documentation]    When the ME is neither in HAP disabled or enabled
    ...    operation modes it is considered a safe mode to update ME. DTS should
    ...    detect it and proceed with the update.
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v560tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_FUM="true"
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_ME_HAP_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_OP_MODE="3"
    Write Into Terminal    dts-boot

    Wait For Checkpoint    You have entered Firmware Update Mode
    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}

    Set DUT Response Timeout    120s
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

E2E019.004 DTS must stop update in case ME operation mode was not detected
    [Documentation]    When the ME operation mode is not detected DST must
    ...    assume it is enabled and ask whether to stop update or
    ...    update without flashing ME. This is because assumming ME is enabled
    ...    is the safest assumption for the end user in such a case.
    Export Shell Variables For Emulation
    ...    UEFI Update
    ...    DCR
    ...    ${DTS_PLATFORM_VARIABLES}[novacustom-v560tu]
    ...    ${DTS_CONFIG_REF}
    Execute Command In Terminal    export TEST_FUM="true"
    Execute Command In Terminal    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) 0.9.0"
    Execute Command In Terminal    export TEST_ME_HAP_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_DISABLED="false"
    Execute Command In Terminal    export TEST_ME_OP_MODE="9"
    Write Into Terminal    dts-boot

    Wait For Checkpoint    You have entered Firmware Update Mode
    Wait For Checkpoint And Write    ${DTS_ASK_FOR_CHOICE_PROMPT}    ${DTS_FUM_UPDATE_OPT}

    Set DUT Response Timeout    120s
    ${out}=    Wait For Checkpoint    ${DTS_ME_WARN}
    Should Contain    ${out}    Can not determine if ME is disabled, assuming enabled.

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

${platform} Fuse Platform - DCR
    [Documentation]    Platform fusing workflow for DCR release
    Prepare E2E Test
    Go Through Fusing Platform
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
    Write Into Terminal    dts-boot

Clean Up DTS Environment
    [Documentation]    Remove and clean up everything that might affect tests.
    ...    Should be run in DTS shell
    Execute Command In Terminal
    ...    rm -rf /etc/cloud-pass /root/.mc /*.tar.gz /root/*.tar.gz /tmp/logs/*profile /tmp/dts-temp-files

Prepare DTS Test
    [Documentation]    Used as test setup. Starts new SSH session so we start
    ...    with clean shell environment for each test
    Execute Command In Terminal    systemctl start sshd
    Start New DTS SSH Session In QEMU
    Clean Up DTS Environment

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
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

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
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 3) Pass the test if the "Aborting deployment..." message shows up:
    ${checkpoint}=    Wait For Checkpoint    ${DTS_13_GEN_REGRESSION}
