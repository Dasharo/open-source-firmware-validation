*** Settings ***
Resource    terminal.robot
Resource    bios/menus.robot
Resource    ../keywords.robot
Resource    dts-zarhus.robot


*** Variables ***
# TODO: We should extend our keyword libs with keywords for DTS UI, these are
# first candidates. But before doing so - we need to establish some UI rules in
# DTS itself.
# DTS checkpoints:
${DTS_CHECKPOINT}=                              Enter an option:
${DTS_CONFIRM_CHECKPOINT}=                      Press Enter to continue
${HCL_REPORT_CHECKPOINT}=
...                                             Please consider contributing to the "Hardware for Linux" project in the future.
${HCL_REPORT_SENDINGLOGS}=
...                                             Do you want to support Dasharo development by sending us logs with your hardware configuration? [y|n]
${ERROR_LOGS_QUESTION}=                         Do you want to send console logs to 3mdeb? [y|n]:
${DTS_SPECIFICATION_WARN}=                      Does it match your actual specification? [y|n]
${DTS_DEPLOY_WARN}=                             Do you want to deploy this Dasharo Firmware on your platform [y|n]
${DTS_HW_PROBE_WARN}=                           Do you want to participate in this project?
${DTS_HEADS_SWITCH_QUESTION}=                   Would you like to switch to Dasharo heads firmware? [y|n]
${DTS_ME_WARN}=
...                                             Skip ME flashing and proceed with BIOS/firmware flashing/updating? [y|n]
${DTS_BOARD_QUESTION}=                          Choose your board model:
${DTS_FUSE_WARN}=                               Fusing is irreversible. Are you sure you want to continue? [y|n]
${DTS_13_GEN_REGRESSION}=                       Aborting deployment...
${DPP_EMAIL_CHECKPOINT}=                        Enter DPP email:
${DPP_PASSWORD_CHECKPOINT}=                     Enter password:
${DTS_ASK_FOR_CHOICE_PROMPT}=                   Select an option:
# DTS initial deployment menupoints:
${DTS_DCR_UEFI_MENUPOINT}=                      Community version
${DTS_DPP_UEFI_MENUPOINT}=                      DPP version (coreboot + UEFI)
${DTS_DPP_SEA_MENUPOINT}=                       DPP version (coreboot + SeaBIOS)
${DTS_DPP_SLIM_BOOTLOADER_UEFI_MENUPOINT}=      DPP version (Slim Bootloader + UEFI)
# Default DTS boot type, can be overwritten by CMD:
${DTS_BOOT_TYPE}=                               iPXE
# DTS options:
${DTS_HCL_OPT}=                                 1
${DTS_DEPLOY_OPT}=                              2
${DTS_CREDENTIALS_OPT}=                         4
${DTS_TRANSITION_OPT}=                          6
${DTS_FUSE_OPT}=                                7
${DTS_DCR_UEFI_OPT}=                            c
${DTS_DPP_UEFI_OPT}=                            d
${DTS_DPP_SEA_OPT}=                             s
${DTS_DPP_SLIM_BOOTLOADER_UEFI_OPT}=            l
${DTS_LOGS_OPT}=                                l
${DTS_FUM_UPDATE_OPT}=                          1
${DTS_FUM_MENU_OPT}=                            9
# DTS release checkpoints:
${DTS_NOACCESS_DPP_UEFI}=                       Dasharo Pro Package version (coreboot + UEFI) is also available.
${DTS_NOACCESS_DPP_SEABIOS}=                    Dasharo Pro Package version (coreboot + SeaBIOS) is also available.
${DTS_NOACCESS_DPP_HEADS}=                      Dasharo Pro Package version (coreboot + Heads) is also available.


*** Keywords ***
Boot Dasharo Tools Suite Via IPXE Shell
    [Documentation]    Boots DTS via iPXE shell by chaining script. Arguments:
    ...    dts_chain_link: link to the script to chain. This is useful in case
    ...    the version of the DTS being booted has not been released yet or if
    ...    a test version is being used. If no link is given - the standard one
    ...    is being used, that is: http://boot.dasharo.com/dts/dts.ipxe
    [Arguments]    ${dts_chain_link}
    # 1) Check and enable network boot, it is disabled by default:
    Make Sure That Network Boot Is Enabled

    # 2) Enter iPXE shell:
    Enter IPXE

    # 3) Set up net card:
    Write Into Terminal    dhcp net0
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    ok
    Set DUT Response Timeout    60s

    # 4) Try to boot via the link:
    Write Bare Into Terminal    chain ${dts_chain_link}\n    interval=0.2
    Set DUT Response Timeout    5m
    Read From Terminal Until    .cpio.gz...
    Read From Terminal Until    ok

Boot Dasharo Tools Suite Via IPXE Menu
    [Documentation]    Boots DTS via option available in Dasharo iPXE menu.
    # 1) Check and enable network boot, it is disabled by default:
    Make Sure That Network Boot Is Enabled

    # 2) Enter iPXE menu:
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    ${IPXE_BOOT_ENTRY}
    ${ipxe_menu}=    Get IPXE Boot Menu Construction

    # 3) Boot DTS:
    Enter Submenu From Snapshot    ${ipxe_menu}    Dasharo Tools Suite
    Set DUT Response Timeout    5m
    Read From Terminal Until    .cpio.gz...
    Read From Terminal Until    ok

Boot Dasharo Tools Suite
    [Documentation]    Keyword allows to boot Dasharo Tools Suite. Takes the
    ...    boot method (from USB or from iPXE) as parameter.
    [Arguments]    ${dts_booting_method}
    IF    '${dts_booting_method}'=='USB'
        # Assuming ESP scanning works as supposed to, DTS on USB stick
        # should generate such entry
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        Enter Submenu From Snapshot    ${boot_menu}    Dasharo Tools Suite
    ELSE IF    '${dts_booting_method}'=='iPXE'
        IF    ${BOOT_DTS_FROM_IPXE_SHELL} == ${TRUE} or ${NETBOOT_UTILITIES_SUPPORT} == ${TRUE}
            # DTS_IPXE_LINK can be defined before running tests, e.g. via CMD or
            # some file:
            Boot Dasharo Tools Suite Via IPXE Shell    ${DTS_IPXE_LINK}
        ELSE
            Boot Dasharo Tools Suite Via IPXE Menu
        END
    ELSE
        FAIL    Unknown DTS boot method: ${dts_booting_method}
    END

    # For PiKVM devices, we have only input on serial, not output. The video and serial consoles are
    # two different console in case of Linux, they are not in sync anymore as in case of firmware.
    # We have to switch to SSH connection to continue test execution on such devices.
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        # Should be long enough so that DTS can boot
        ${old_timeout}=    Set Timeout    20s
        Run Keyword And Ignore Error
        ...    Read From Terminal Until    Enter an option:
        Set Timeout    ${old_timeout}
        # Enable SSH server and switch to SSH connection by writing on video console "in blind"
        Write Bare Into Terminal    K
        VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=GLOBAL
        Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite:~#
        # Spawn DTS menu on SSH console
        Write Into Terminal    dts-boot
    END
    Read From Terminal Until    Enter an option:
    Sleep    5s

Check HCL Report Creation
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    option for creating HCL report works correctly.
    Enter Shell In DTS
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=GLOBAL
    Execute Command In Terminal    cd /
    ${logs}=    Execute Command In Terminal
    ...    command=/usr/bin/env DEPLOY_REPORT=false SEND_LOGS=true /usr/sbin/dasharo-hcl-report
    ...    timeout=210s
    Should Contain    ${logs}    Thank you
    Should Contain    ${logs}    exited without errors
    Should Contain    ${logs}    send completed

Enter Shell In DTS
    [Documentation]    Keyword allows to drop to Shell in the Dasharo Tools
    ...    Suite.
    Write Bare Into Terminal    S
    Set Prompt For Terminal    bash-5.2#
    # These could be removed once routes priorities in DTS are resolved.
    Sleep    10
    Press Enter
    ${out}=    Read From Terminal
    Log    ${out}
    Remove Extra Default Route

Run EC Transition
    [Documentation]    Keyword allows to run EC Transition procedure in the
    ...    Dasharo Tools Suite.
    Write Bare Into Terminal    6
    Read From Terminal Until    Enter an option:
    Write Into Terminal    1
    ${output}=    Read From Terminal Until    shut down
    Should Contain X Times    ${output}    VERIFIED    2
    Sleep    10s

Flash Firmware In DTS
    [Documentation]    Keyword allows to check if the Dasharo Tools Suite
    ...    ability for flashing firmware work correctly.
    [Arguments]    ${fw_dl_link}=${FW_DOWNLOAD_LINK}
    Execute Command In Terminal
    ...    wget -O /tmp/coreboot.rom ${fw_dl_link}
    ${out}=    Execute Command In Terminal
    ...    command=flashrom --ifd -i bios -p internal -w /tmp/coreboot.rom --noverify-all
    ...    timeout=320s
    ${verified}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    VERIFIED
    IF    ${verified} == ${FALSE}
        ${out}=    Execute Command In Terminal
        ...    command=flashrom --ifd -i bios -p internal -w /tmp/coreboot.rom --noverify-all
        ...    timeout=320s
        Should Contain    ${out}    identical
    END

Remove Extra Default Route
    [Documentation]    If two default routes are present in Linux, remove
    ...    the one NOT pointing to the gateway in test network (192.168.10.1)
    ${route_info}=    Execute Command In Terminal    ip route | grep ^default
    ${devname}=    String.Get Regexp Matches    ${route_info}
    ...    ^default via 172\.16\.0\.1 dev (?P<devname>\\w+)    devname
    ${length}=    Get Length    ${devname}
    IF    ${length} > 0
        Execute Command In Terminal    ip route del default via 172.16.0.1 dev ${devname[0]}
        ${route_info}=    Execute Command In Terminal    ip route | grep ^default
        Log    Default route via 172.16.0.1 dev ${devname[0]} removed
    END

Power On And Enter DTS Shell
    [Documentation]    This KW boots DTS using the method defined by user via
    ...    DTS_BOOT_TYPE or the default one. After booting DTS shell is being
    ...    entered.
    # 1) Boot up to DTS UI:
    Power On
    Boot Dasharo Tools Suite    ${DTS_BOOT_TYPE}

    # 2) Enter shell:
    Write Bare Into Terminal    S
    Set Prompt For Terminal    bash-5.2#
    Read From Terminal Until Prompt
    Set DUT Response Timeout    90s

Enable DTS Log Sending
    [Documentation]    This KW automatically enables sending DTS logs.
    Set DUT Response Timeout    120s
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Bare Into Terminal    ${DTS_LOGS_OPT}

Provide DPP Credentials
    [Documentation]    This KW automatically writes DPP credentials into DTS UI.
    ...    The credentials should be set via CMD or file.
    Set DUT Response Timeout    120s
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Bare Into Terminal    ${DTS_CREDENTIALS_OPT}

    # Enter email:
    Variable Should Exist    ${DPP_EMAIL}
    Wait For Checkpoint And Write    ${DPP_EMAIL_CHECKPOINT}    ${DPP_EMAIL}
    # Enter password:
    Variable Should Exist    ${DPP_PASSWORD}
    Wait For Checkpoint And Write    ${DPP_PASSWORD_CHECKPOINT}    ${DPP_PASSWORD}

    ${out}=    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    RETURN    ${out}

Provide DPP Credentials Without Packages
    [Documentation]    This KW automatically writes DPP credentials that do not
    ...    have access to DPP packages into DTS UI and checks out a DPP package
    ...    warning.
    Provide DPP Credentials

    Wait For Checkpoint And Press Enter    ${DPP_PACKAGES_CHECKPOINT}

Go Through Initial Deployment
    [Documentation]    This KW goes through standard Dasharo initial deployment
    ...    choosing all needed menu options and answering all questions. The
    ...    only thing which needs to be specified - the Dasharo version to
    ...    deploy (first argument), available versions: DCR UEFI, DPP UEFI, DPP
    ...    SeaBIOS.
    [Arguments]    ${dasharo_version}    ${skip_me}=${FALSE}

    IF    '${dasharo_version}' == 'DCR UEFI'
        VAR    ${opt}=    ${DTS_DCR_UEFI_OPT}
        VAR    ${menupoint}=    ${DTS_DCR_UEFI_MENUPOINT}
    ELSE IF    '${dasharo_version}' == 'DPP UEFI'
        VAR    ${opt}=    ${DTS_DPP_UEFI_OPT}
        VAR    ${menupoint}=    ${DTS_DPP_UEFI_MENUPOINT}
    ELSE IF    '${dasharo_version}' == 'DPP SeaBIOS'
        VAR    ${opt}=    ${DTS_DPP_SEA_OPT}
        VAR    ${menupoint}=    ${DTS_DPP_SEA_MENUPOINT}
    ELSE IF    '${dasharo_version}' == 'DPP Slim Bootloader + UEFI'
        VAR    ${opt}=    ${DTS_DPP_SLIM_BOOTLOADER_UEFI_OPT}
        VAR    ${menupoint}=    ${DTS_DPP_SLIM_BOOTLOADER_UEFI_MENUPOINT}
    ELSE
        Fail    No Dasharo version for initial deployment provided!
    END

    # 1) Select initial deployment:
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    N
    Set DUT Response Timeout    120s

    # DTS_BOARD_QUESTION will be asked for NovaCustom V540TNx, V560TNx, V540TU
    # or V560TU
    ${checkpoint}=    Wait For Either Checkpoint
    ...    ${DTS_BOARD_QUESTION}
    ...    ${opt}) ${menupoint}

    IF    """${DTS_BOARD_QUESTION}""" in """${checkpoint}"""
        ${out}=    Wait For Checkpoint    ${DTS_TEST_BOARD_MODEL}
        ${out}=    Get Line    ${out}    -1
        ${out}=    Strip String    ${out}
        ${board_opt}=    Get Regexp Matches    ${out}    ^([0-9]+):    1
        Write Into Terminal    ${board_opt}[0]
        Wait For Checkpoint    ${opt}) ${menupoint}
    END

    # 3) Choose version to install:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${opt}

    # 4) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    Wait For ME Warning Or Reboot    ${skip_me}
    Wait For Checkpoint    Rebooting

Go Through Transition
    [Documentation]    This KW goes through standard Dasharo Transition
    ...    choosing all needed menu options and answering all questions. The
    ...    only thing which needs to be specified - the Dasharo version to
    ...    transit to (first argument), available versions: DCR UEFI, DPP UEFI,
    ...    DPP SeaBIOS.
    [Arguments]    ${dasharo_version}    ${skip_me}=${FALSE}
    # 1) Select transition:
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_TRANSITION_OPT}

    # 2) Choose version to transit to:
    IF    '${dasharo_version}' == 'DCR UEFI'
        Wait For Checkpoint    ${DTS_DCR_UEFI_OPT}) ${DTS_DCR_UEFI_MENUPOINT}
        Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DCR_UEFI_OPT}
    ELSE IF    '${dasharo_version}' == 'DPP UEFI'
        Wait For Checkpoint    ${DTS_DPP_UEFI_OPT}) ${DTS_DPP_UEFI_MENUPOINT}
        Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DPP_UEFI_OPT}
    ELSE IF    '${dasharo_version}' == 'DPP SeaBIOS'
        Wait For Checkpoint    ${DTS_DPP_SEA_OPT}) ${DTS_DPP_SEA_MENUPOINT}
        Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DPP_SEA_OPT}
    ELSE IF    '${dasharo_version}' == 'DPP Slim Bootloader + UEFI'
        Wait For Checkpoint    ${DTS_DPP_SLIM_BOOTLOADER_UEFI_OPT}) ${DTS_DPP_SLIM_BOOTLOADER_UEFI_MENUPOINT}
        Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DPP_SLIM_BOOTLOADER_UEFI_OPT}
    ELSE
        Fail    No Dasharo version for initial deployment provided!
    END

    # 4) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    Wait For ME Warning Or Reboot    ${skip_me}
    Wait For Checkpoint    Rebooting

Go Through Update
    [Documentation]    This KW goes through standard Dasharo update workflow
    ...    choosing all needed menu options and answering all questions.
    ...    If ${skip_me} is set to ${TRUE} then keyword will go through update
    ...    Even if Intel ME cannot be updated
    [Arguments]    ${skip_me}=${FALSE}
    Set DUT Response Timeout    120s
    # 1) Select update:
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings. Decline Heads if asked
    ${checkpoint}=    Wait For Either Checkpoint And Write
    ...    ${DTS_SPECIFICATION_WARN}=Y
    ...    ${DTS_HEADS_SWITCH_QUESTION}=N
    IF    """${DTS_HEADS_SWITCH_QUESTION}""" in """${checkpoint}"""
        Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    END
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Set DUT Response Timeout    5m

    Wait For ME Warning Or Reboot    ${skip_me}
    Wait For Checkpoint    Rebooting

Go Through Heads Transition
    [Documentation]    This KW goes through transition to Dasharo Heads choosing
    ...    all needed menu options and answering all questions.
    [Arguments]    ${skip_me}=${FALSE}
    Set DUT Response Timeout    120s
    # 1) Start update:
    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    Set DUT Response Timeout    5m
    # 3) Check for Heads firmware deployment success:
    ${checkpoint}=    Wait For Either Checkpoint
    ...    ${DTS_ME_WARN}
    ...    Successfully switched to Dasharo Heads firmware
    IF    """${DTS_ME_WARN}""" in """${checkpoint}"""
        IF    ${skip_me}
            Write Into Terminal    Y
            Wait For Checkpoint
            ...    Successfully switched to Dasharo Heads firmware
        ELSE
            Fail    Cannot update Intel ME
        END
    END
    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}
    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

Go Through Fusing Platform
    [Documentation]    This KW goes through standard Dasharo workflow which
    ...    deploys binary that'll fuse platform, choosing all needed menu
    ...    options and answering all questions.
    Set DUT Response Timeout    120s

    Wait For Checkpoint And Write Bare    ${DTS_CHECKPOINT}    ${DTS_FUSE_OPT}
    Wait For Checkpoint And Write    ${DTS_FUSE_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    Wait For Checkpoint    Rebooting in
    Wait For Checkpoint    Rebooting

Export Shell Variables For Emulation
    [Documentation]    Export variables needed for this test
    [Arguments]    ${workflow}
    ...    ${release}
    ...    ${dts_test_variables}
    ...    ${dts_config_ref_value}=refs/heads/main
    @{exports}=    Prepare Test Exports    ${workflow}    ${release}
    ...    ${dts_test_variables}    ${dts_config_ref_value}
    FOR    ${export_string}    IN    @{exports}
        Execute Command In Terminal    ${export_string}
    END

Prepare Test Exports
    [Documentation]    Create list with 'export VARIABLE=VALUE` strings.
    [Arguments]    ${workflow}
    ...    ${release}
    ...    ${dts_test_variables}
    ...    ${dts_config_ref_value}=refs/heads/main
    VAR    &{exports_dict}=    &{dts_test_variables}[DTS_TEST_EXPORTS]

    # Base exports for every workflow
    VAR    &{exports}=    &{EMPTY}
    Set To Dictionary    ${exports}
    ...    TEST_BIOS_VERSION=${dts_test_variables}[DTS_TEST_VERSIONS][${workflow}]
    ...    DTS_CONFIG_REF=${dts_config_ref_value}
    FOR    ${export_variable}    ${export_value}    IN    &{exports_dict}
        Set To Dictionary    ${exports}    ${export_variable}=${export_value}
    END

    # Specific, per workflow exports
    &{workflow_exports}=    Get From Dictionary
    ...    ${dts_test_variables}[DTS_TEST_EXPORTS_PER_WORKFLOW]    ${workflow}
    ...    default=&{EMPTY}
    FOR    ${export_variable}    ${export_value}    IN    &{workflow_exports}
        Set To Dictionary    ${exports}    ${export_variable}=${export_value}
    END

    # Most specific exports, per workflow & release version
    &{full_workflow_exports}=    Get From Dictionary
    ...    ${dts_test_variables}[DTS_TEST_EXPORTS_PER_FULL_WORKFLOW]
    ...    ${{ ("${workflow}", "${release}") }}
    ...    default=&{EMPTY}
    FOR    ${export_variable}    ${export_value}    IN    &{full_workflow_exports}
        Set To Dictionary    ${exports}    ${export_variable}=${export_value}
    END

    # Create list of export strings
    VAR    @{export_strings}=    @{EMPTY}
    FOR    ${export_variable}    ${export_value}    IN    &{exports}
        Append To List    ${export_strings}
        ...    export ${export_variable}="${export_value}"
    END

    RETURN    ${export_strings}

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

Execute Manual Step While Freeing Serial Connection
    [Documentation]    In case you need to connect to DUT via serial to do
    ...    manual steps. Arguments are the same as for 'Execute Manual Step'
    [Arguments]    ${msg}
    Telnet.Close All Connections
    Execute Manual Step
    ...    ${msg}. Make sure to close serial connection before continuing
    Serial Setup    ${RTE_IP}    ${RTE_S2_N_PORT}
