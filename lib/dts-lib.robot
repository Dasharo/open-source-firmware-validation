*** Settings ***
Resource    terminal.robot
Resource    bios/menus.robot
Resource    ../keywords.robot


*** Variables ***
# TODO: We should extend our keyword libs with keywords for DTS UI, these are
# first candidates. But before doing so - we need to establish some UI rules in
# DTS itself.
# DTS checkpoints:
${DTS_CHECKPOINT}=                  Enter an option:
${DTS_CONFIRM_CHECKPOINT}=          Press Enter to continue
${HCL_REPORT_CHECKPOINT}=           Please consider contributing to the "Hardware for Linux" project in the future.
${HCL_REPORT_SENDINGLOGS}=
...                                 Do you want to support Dasharo development by sending us logs with your hardware configuration? [N/y]
${DTS_SPECIFICATION_WARN}=          Does it match your actual specification? (Y|n)
${DTS_DEPLOY_WARN}=                 Do you want to deploy this Dasharo Firmware on your platform (Y|n)
${DTS_HW_PROBE_WARN}=               Do you want to participate in this project?
${DTS_HEADS_SWITCH_QUESTION}=       Would you like to switch to Dasharo heads firmware? (Y|n)
${DTS_ME_WARN}=                     Skip ME flashing and proceed with BIOS/firmware flashing/updating? (Y|n)
${DTS_BOARD_QUESTION}=              Choose your board model:
# DTS initial deployment menupoints:
${DTS_DCR_UEFI_MENUPOINT}=          Community version
${DTS_DPP_UEFI_MENUPOINT}=          DPP version (coreboot + UEFI)
${DTS_DPP_SEA_MENUPOINT}=           DPP version (coreboot + SeaBIOS)
# Default DTS boot type, can be overwritten by CMD:
${DTS_BOOT_TYPE}=                   iPXE
# DTS options:
${DTS_HCL_OPT}=                     1
${DTS_DEPLOY_OPT}=                  2
${DTS_CREDENTIALS_OPT}=             4
${DTS_TRANSITION_OPT}=              6
${DTS_DCR_UEFI_OPT}=                c
${DTS_DPP_UEFI_OPT}=                d
${DTS_DPP_SEA_OPT}=                 s
${DTS_LOGS_OPT}=                    l
# DTS release checkpoints:
${DTS_NOACCESS_DPP_UEFI}=           Dasharo Pro Package version (coreboot + UEFI) is also available.
${DTS_NOACCESS_DPP_SEABIOS}=        Dasharo Pro Package version (coreboot + SeaBIOS) is also available.
${DTS_NOACCESS_DPP_HEADS}=          Dasharo Pro Package version (coreboot + Heads) is also available.


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
    Write Bare Into Terminal    chain ${dts_chain_link}\n
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
    Write Into Terminal    ${DPP_EMAIL}
    # Enter password:
    Variable Should Exist    ${DPP_PASSWORD}
    Write Into Terminal    ${DPP_PASSWORD}

    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}

Provide DPP Credentials Without Packages
    [Documentation]    This KW automatically writes DPP credentials that do not
    ...    have access to DPP packages into DTS UI and checks out a DPP package
    ...    warning.
    Provide DPP Credentials

    Wait For Checkpoint And Press Enter    ${DPP_PACKAGES_CHECKPOINT}

Wait For Checkpoint
    [Documentation]    This KW waits for checkpoint (first argument) and logs
    ...    everything read up to the checkpoint. If regexp is ${True} then
    ...    treat checkpoint as regexp
    [Arguments]    ${checkpoint}    ${regexp}=${FALSE}
    IF    ${regexp}
        ${out}=    Read From Terminal Until Regexp    ${checkpoint}
    ELSE
        ${out}=    Read From Terminal Until    ${checkpoint}
    END
    Log    ${out}
    RETURN    ${out}

Wait For Checkpoint And Write
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and writes specified answer (second argument), with logging all
    ...    output before the checkpoint.
    [Arguments]    ${checkpoint}    ${to_write}    ${regexp}=${FALSE}
    ${out}=    Wait For Checkpoint    ${checkpoint}    ${regexp}
    Sleep    1s
    Write Into Terminal    ${to_write}
    RETURN    ${out}

Wait For Either Checkpoint And Write
    [Documentation]    Keywords waits for any of the ${checkpoints} key and if
    ...    it matches then writes value of this element to the console
    [Arguments]    &{checkpoints}
    ${out}=    Wait For Either Checkpoint    @{checkpoints}
    # Find which checkpoint we found
    Sleep    1s
    FOR    ${checkpoint}    ${write}    IN    &{checkpoints}
        IF    """${checkpoint}""" in """${out}"""
            Write Into Terminal    ${checkpoints}[${checkpoint}]
            RETURN    ${out}
        END
    END

    # We shouldn't ever get here
    Fail    Couldn't find checkpoint in returned output

Wait For Either Checkpoint
    [Documentation]    Keywords waits for any of the ${checkpoints} and returns
    ...    console output to that point
    [Arguments]    @{checkpoints}
    VAR    ${regexp}=    ${EMPTY}
    # Iterate over keys (checkpoints)
    FOR    ${checkpoint}    IN    @{checkpoints}
        ${checkpoint_escaped}=    Evaluate
        ...    re.escape("""${checkpoint}""")
        VAR    ${regexp}=    ${regexp}${checkpoint_escaped}|
    END
    # Remove trailing |
    ${regexp}=    Get Substring    ${regexp}    0    -1
    ${out}=    Wait For Checkpoint    ${regexp}    ${TRUE}
    RETURN    ${out}

Wait For Checkpoint And Press Enter
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and preses enter, with logging all output before the checkpoint.
    [Arguments]    ${checkpoint}    ${regexp}=${FALSE}
    ${out}=    Wait For Checkpoint    ${checkpoint}    ${regexp}
    Sleep    1s
    Write Bare Into Terminal    \r\n
    RETURN    ${out}

Go Through Initial Deployment
    [Documentation]    This KW goes through standard Dasharo initial deployment
    ...    choosing all needed menu options and answering all questions. The
    ...    only thing which needs to be specified - the Dasharo version to
    ...    deploy (first argument), available versions: DCR UEFI, DPP UEFI, DPP
    ...    SeaBIOS.
    [Arguments]    ${dasharo_version}

    IF    '${dasharo_version}' == 'DCR UEFI'
        VAR    ${opt}=    ${DTS_DCR_UEFI_OPT}
        VAR    ${menupoint}=    ${DTS_DCR_UEFI_MENUPOINT}
    ELSE IF    '${dasharo_version}' == 'DPP UEFI'
        VAR    ${opt}=    ${DTS_DPP_UEFI_OPT}
        VAR    ${menupoint}=    ${DTS_DPP_UEFI_MENUPOINT}
    ELSE IF    '${dasharo_version}' == 'DPP SeaBIOS'
        VAR    ${opt}=    ${DTS_DPP_SEA_OPT}
        VAR    ${menupoint}=    ${DTS_DPP_SEA_MENUPOINT}
    ELSE
        Fail    No Dasharo version for initial deployment provided!
    END

    # 1) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

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

Go Through Transition
    [Documentation]    This KW goes through standard Dasharo Transition
    ...    choosing all needed menu options and answering all questions. The
    ...    only thing which needs to be specified - the Dasharo version to
    ...    transit to (first argument), available versions: DCR UEFI, DPP UEFI,
    ...    DPP SeaBIOS.
    [Arguments]    ${dasharo_version}
    # 1) Select transition:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_TRANSITION_OPT}

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
    ELSE
        Fail    No Dasharo version for initial deployment provided!
    END

    # 4) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

Go Through Update
    [Documentation]    This KW goes through standard Dasharo update workflow
    ...    choosing all needed menu options and answering all questions.
    ...    If ${skip_me} is set to ${TRUE} then keyword will go through update
    ...    Even if Intel ME cannot be updated
    [Arguments]    ${skip_me}=${FALSE}
    Set DUT Response Timeout    120s
    # 1) Select update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings. Decline Heads if asked
    ${checkpoint}=    Wait For Either Checkpoint And Write
    ...    ${DTS_SPECIFICATION_WARN}=Y
    ...    ${DTS_HEADS_SWITCH_QUESTION}=N
    IF    """${DTS_HEADS_SWITCH_QUESTION}""" in """${checkpoint}"""
        Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    END
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y
    Set DUT Response Timeout    5m
    ${dts_me_warn_escaped}=    Evaluate    re.escape("""${DTS_ME_WARN}""")
    ${checkpoint}=    Wait For Checkpoint
    ...    ${dts_me_warn_escaped}|Rebooting    regexp=${TRUE}
    IF    """${DTS_ME_WARN}""" in """${checkpoint}"""
        IF    ${skip_me}
            Write Into Terminal    Y
            Wait For Checkpoint    Rebooting
        ELSE
            Fail    Cannot update Intel ME
        END
    END

Go Through Heads Transition
    [Documentation]    This KW goes through transition to Dasharo Heads choosing
    ...    all needed menu options and answering all questions.
    Set DUT Response Timeout    120s
    # 1) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    Set DUT Response Timeout    5m
    # 3) Check for Heads firmware deployment success:
    Wait For Checkpoint    Successfully switched to Dasharo Heads firmware
    Wait For Checkpoint And Write    ${DTS_CONFIRM_CHECKPOINT}    1

Export Shell Variables For Emulation
    [Documentation]    Export variables needed for this test
    [Arguments]    ${workflow}    ${dts_test_variables}    ${dts_config_ref_value}=refs/heads/main
    @{exports}=    Prepare Test Exports    ${workflow}    ${dts_test_variables}    ${dts_config_ref_value}
    FOR    ${export_string}    IN    @{exports}
        Execute Command In Terminal    export ${export_string}
    END

Prepare Test Exports
    [Documentation]    Create list with 'export VARIABLE=VALUE` strings.
    [Arguments]    ${workflow}    ${dts_test_variables}    ${dts_config_ref_value}=refs/heads/main
    VAR    &{exports_dict}=    &{dts_test_variables}[DTS_TEST_EXPORTS]
    Set To Dictionary    ${exports_dict}    TEST_BIOS_VERSION=${dts_test_variables}[DTS_TEST_VERSIONS][${workflow}]
    Set To Dictionary    ${exports_dict}    DTS_CONFIG_REF=${dts_config_ref_value}
    IF    "${workflow}" == "Initial Deployment"
        Set To Dictionary    ${exports_dict}    TEST_BIOS_VENDOR=proprietary
    ELSE
        IF    ${dts_test_variables}[DTS_TEST_HAS_EC]
            Set To Dictionary    ${exports_dict}    TEST_USING_OPENSOURCE_EC_FIRM=true
        END
    END
    IF    "SeaBIOS Update" in "${workflow}" or "SeaBIOS->" in "${workflow}"
        Set To Dictionary    ${exports_dict}    TEST_EFI_PRESENT=false
        Set To Dictionary    ${exports_dict}    TEST_IS_SEABIOS=true
    END

    VAR    @{exports}=    @{EMPTY}
    FOR    ${export_variable}    ${export_value}    IN    &{exports_dict}
        Append To List    ${exports}
        ...    export ${export_variable}="${export_value}"
    END

    RETURN    ${exports}
