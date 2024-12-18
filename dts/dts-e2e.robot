*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=40 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${DTS_SUPPORT}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


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
${DTS_DCR_UEFI_OPT}=                c
${DTS_DPP_UEFI_OPT}=                d
${DTS_DPP_SEA_OPT}=                 s
# DTS subscription checkpoints:
${DTS_NOACCESS_DPP_UEFI}=           DPP version (coreboot + UEFI) available but you don't have access
${DTS_NOACCESS_DPP_SEABIOS}=        DPP version (coreboot + SeaBIOS) available but you don't have access
${DTS_NOACCESS_DPP_HEADS}=          DPP version (coreboot + Heads) available but you don't have access


*** Test Cases ***
E2E001.001 HCL Report test
    [Documentation]    Verify that HCL Report is being executed with all
    ...    expected messages. The report should not fail even if it failed to
    ...    collect some data, because it is responsible only for collecting.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

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

################################################################################
# NovaCustom tests:
################################################################################

E2E002.001 NCM NV4XMB,ME,MZ initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NV4XMB,ME,MZ. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4XMB,ME,MZ" TEST_BOARD_MODEL="NV4XMB,ME,MZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.002 NCM NS50_70MU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NS50_70MU. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NS50_70MU" TEST_BOARD_MODEL="NS50_70MU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.003 NCM NS5x_NS7xPU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NS5x_NS7xPU. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NS5x_NS7xPU" TEST_BOARD_MODEL="NS5x_NS7xPU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.004 NCM NV4xPZ initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NV4xPZ. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4xPZ" TEST_BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.005 NCM NV4xPZ transition (Coreboot + UEFI -> Coreboot + Heads) - DPP version, without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom NV4X ADL. We start from Dasharo (coreboot + UEFI) firmware
    ...    with version that should allow for the transition. We insert no DPP
    ...    keys, so we expect no update will be provided, but a message
    ...    encouraging subscription purchase should be visible.
    [Tags]    novacustom_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4xPZ" TEST_BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_HEADS}

E2E002.006 NCM transition NV4xPZ (Coreboot + UEFI -> Heads) - DPP version, with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert correct DPP keys for heads variant.
    [Tags]    novacustom_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4xPZ" TEST_BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb" TEST_USING_OPENSOURCE_EC_FIRM="true"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Heads Transition

    # 5) The final step is rebooting, in this case it is done emmidiately after
    # EC firm. has been updated:
    Wait For Checkpoint    Updating EC...

E2E002.007 NCM V540_6x_TU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V540_6x_TU. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V54x_6x_TU" TEST_BOARD_MODEL="V540TU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_NOVACUSTOM_MODEL="v540tu" TEST_USING_OPENSOURCE_EC_FIRM="true"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.008 NCM V560_6x_TU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V560_6x_TU. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V54x_6x_TU" TEST_BOARD_MODEL="V560TU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_NOVACUSTOM_MODEL="v560tu" TEST_USING_OPENSOURCE_EC_FIRM="true"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.009 NCM V540TNC_TND_TNE initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V540TNC_TND_TNE. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V5xTNC_TND_TNE" TEST_BOARD_MODEL="V540TNx"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    Wait For Checkpoint    1: V540TNx
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    1

    # 6) Choose update to Dasharo:
    Wait For Checkpoint    ${DTS_DCR_UEFI_OPT}) ${DTS_DCR_UEFI_MENUPOINT}
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DCR_UEFI_OPT}

    # 7) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    # 8) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E002.010 NCM V560TNC_TND_TNE initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V560TNC_TND_TNE. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V5xTNC_TND_TNE" TEST_BOARD_MODEL="V560TNx"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    Wait For Checkpoint    2: V560TNx
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    2

    # 6) Choose update to Dasharo:
    Wait For Checkpoint    ${DTS_DCR_UEFI_OPT}) ${DTS_DCR_UEFI_MENUPOINT}
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DCR_UEFI_OPT}

    # 7) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    # 8) The final step is rebooting:
    Wait For Checkpoint    Rebooting

################################################################################
# MSI tests:
#
# Currently these tests cover all use cases for Z690 only, Z790 has the same
# configuration in board_config in dts-scripts and differs only by links to
# artifacts, so it will not cover any new logic. Therefore it was decided to
# leave this tests for future.
################################################################################

E2E003.001 MSI PRO Z690-A DDR4 initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    WIFI DDR4(MS-7D25). This deployment should pass without credentials.
    [Tags]    msi_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.002 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI (MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should pass without credentials.
    [Tags]    msi_comm
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    Go Through Initial Deployment    DCR UEFI

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.003 MSI PRO Z690-A DDR-4 initial deployment (legacy -> Coreboot + UEFI) - DPP version, without credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should not pass without credentials.
    [Tags]    msi_dpp
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E003.004 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - DPP version, without credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    DDR 4(MS-7D25). This deployment should not pass without credentials.
    [Tags]    msi_dpp
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E003.005 MSI PRO Z690-A DDR-4 initial deployment (legacy -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should pass with credentials.
    [Tags]    msi_dpp
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.006 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    DDR 4(MS-7D25). This deployment should pass with credentials.
    [Tags]    msi_dpp
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.007 MSI PRO Z690-A DDR-4 update (Coreboot + UEFI -> Coreboot + UEFI) - community version
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A DDR4(MS-7D25). We start from
    ...    Dasharo (coreboot + UEFI) firmware with version that should allow for
    ...    the update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_comm
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Go Through Update

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.008 MSI PRO Z690-A update (Coreboot + UEFI -> Coreboot + UEFI) - community version
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI(MS-7D25)/PRO Z690-A(MS-7D25). We start from Dasharo
    ...    (coreboot + UEFI) firmware with version that should allow for the
    ...    update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_comm
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Go Through Update

    # 4) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.009 MSI PRO Z690-A DDR-4 update (Coreboot + UEFI -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A DDR4(MS-7D25). We start from
    ...    Dasharo (coreboot + UEFI) firmware with version that should allow for
    ...    the update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_dpp

    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Update

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.010 MSI PRO Z690-A update (Coreboot + UEFI -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI(MS-7D25)/PRO Z690-A(MS-7D25). We start from Dasharo
    ...    (coreboot + UEFI) firmware with version that should allow for the
    ...    update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_dpp

    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) Start update:
    Go Through Update

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.011 MSI PRO Z690-A DDR4 transition (Coreboot + UEFI -> heads) - without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert no DPP keys, so we expect no update will be provided, but a
    ...    message encouraging subscription purchase should be visible.
    [Tags]    msi_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_HEADS}

E2E003.012 MSI PRO Z690-A DDR4 transition (Coreboot + UEFI -> heads) - with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert correct DPP keys for heads variant.
    [Tags]    msi_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Heads Transition

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.013 MSI PRO Z690-A transition (UEFI -> heads) - without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert no DPP keys, so we expect no update will be provided, but a
    ...    message encouraging subscription purchase should be visible.
    [Tags]    msi_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_HEADS}

E2E003.014 MSI PRO Z690-A transition (UEFI -> heads) - with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert correct DPP keys for heads variant.
    [Tags]    msi_heads
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Heads Transition

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

################################################################################
# Dell tests:
################################################################################

E2E004.001 Dell OptiPlex 7010 DPP initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Start installation:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E004.002 Dell Optiplex 7010 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E004.003 Dell Optiplex 7010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E004.004 Dell Optiplex 7010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Update

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E004.005 Dell OptiPlex 9010 DPP initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Start installation:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E004.006 Dell Optiplex 9010 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E004.007 Dell Optiplex 9010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E004.008 Dell Optiplex 9010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    [Tags]    optiplex_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start update:
    Go Through Update

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

################################################################################
# PC Engines tests. Only APU2 is being tested, other APUs have the same
# configuration, but different links, so testing them is not necessary:
################################################################################

E2E005.001 PC Engines DPP initial deployment (legacy -> Coreboot + UEFI) - no credentials
    [Documentation]    Verify DPP (coreboot + UEFI) and (coreboot + SeaBIOS)
    ...    initial deployment logic on PC Engines. We emulate legacy firmware
    ...    and do not provide DPP credentials. There should be no access granted
    ...    for the firmware without credentials.
    [Tags]    pcengines_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Start installation:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E005.002 PC Engines DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Verify DPP (coreboot + UEFI) initial deployment logic on
    ...    PC Engines with credentials provided (these should be provided via
    ...    CMD).
    [Tags]    pcengines_dpp
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E005.003 PC Engines DPP initial deployment (legacy -> Coreboot + SeaBIOS) - without credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DPP keys
    ...    for UEFI variant.
    [Tags]    pcengines_seabios
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Start installation:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_SEABIOS}

E2E005.004 PC Engines DPP initial deployment (legacy -> Coreboot + SeaBIOS) - with credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DPP
    ...    keys for UEFI variant.
    [Tags]    pcengines_seabios
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP SeaBIOS

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

################################################################################
# Odroid tests:
################################################################################

E2E006.001 Odroid H4 initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4
    ...    without credentials provided. User should not have access and DTS
    ...    should inform about it.
    [Tags]    odroid_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Write Into Terminal    dts-boot

    # 3) Start installation:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 5) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E006.002 Odroid H4 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4 with
    ...    credentials provided. User should have access, and firmware should be
    ...    deployed.
    [Tags]    odroid_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E006.003 Odroid H4 update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4
    ...    without credentials provided. User should not have access and DTS
    ...    should inform about it.
    [Tags]    odroid_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_UEFI}

E2E006.004 Odroid H4 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    [Tags]    odroid_dpp
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials Without Packages

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting


*** Keywords ***
Power On And Enter DTS Shell
    [Documentation]    This KW boots DTS using the method defined by user via
    ...    DTS_BOOT_TYPE or the default one. After booting DTS shell is being
    ...    entered.
    # 1) Boot up to DTS UI:
    Power On
    Boot Dasharo Tools Suite    ${DTS_BOOT_TYPE}

    # 2) Enter shell:
    Write Into Terminal    S
    Set Prompt For Terminal    bash-5.2#
    Read From Terminal Until Prompt
    Set DUT Response Timeout    90s

Provide DPP Credentials
    [Documentation]    This KW automatically writes DPP credentials into DTS UI.
    ...    The credentials should be set via CMD or file.
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Bare Into Terminal    ${DTS_CREDENTIALS_OPT}

    # Enter logs key:
    Variable Should Exist    ${DPP_LOGS_KEY}
    Write Into Terminal    ${DPP_LOGS_KEY}
    # Enter download key:
    Variable Should Exist    ${DPP_DOWNLOAD_KEY}
    Write Into Terminal    ${DPP_DOWNLOAD_KEY}
    # Enter password:
    Variable Should Exist    ${DPP_PASSWORD}
    Write Into Terminal    ${DPP_PASSWORD}

Provide DPP Credentials Without Packages
    [Documentation]    This KW automatically writes DPP credentials that do not
    ...    have access to DPP packages into DTS UI and checks out a DPP package
    ...    warning.
    Provide DPP Credentials

    Wait For Checkpoint And Press Enter    ${DTS_CONFIRM_CHECKPOINT}

Wait For Checkpoint
    [Documentation]    This KW waits for checkpoint (first argument) and logs
    ...    everything read up to the checkpoint.
    [Arguments]    ${checkpoint}
    ${out}=    Read From Terminal Until    ${checkpoint}
    Log    ${out}

Wait For Checkpoint And Write
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and writes specified answer (second argument), with logging all
    ...    output before the checkpoint.
    [Arguments]    ${checkpoint}    ${to_write}
    Wait For Checkpoint    ${checkpoint}
    Sleep    1s
    Write Into Terminal    ${to_write}

Wait For Checkpoint And Press Enter
    [Documentation]    This KW waits for checkpoint (first argument)
    ...    and preses enter, with logging all output before the checkpoint.
    [Arguments]    ${checkpoint}
    Wait For Checkpoint    ${checkpoint}
    Sleep    1s
    Write Bare Into Terminal    \r\n

Go Through Initial Deployment
    [Documentation]    This KW goes through standard Dasharo initial deployment
    ...    choosing all needed menu options and answering all questions. The
    ...    only thing which needs to be specified - the Dasharo version to
    ...    deploy (first argument), available versions: DCR UEFI, DPP UEFI, DPP
    ...    SeaBIOS.
    [Arguments]    ${dasharo_version}
    # 1) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    Wait For Checkpoint And Write    ${DTS_HW_PROBE_WARN}    Y
    Set DUT Response Timeout    30s

    # 3) Choose version to install:
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
    # 1) Select initial deployment:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

Go Through Heads Transition
    [Documentation]    This KW goes through transition to Dasharo Heads choosing
    ...    all needed menu options and answering all questions.
    # 1) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 2) Check out all warnings:
    Wait For Checkpoint And Write    ${DTS_HEADS_SWITCH_QUESTION}    Y
    Wait For Checkpoint And Write    ${DTS_SPECIFICATION_WARN}    Y
    Wait For Checkpoint And Write    ${DTS_DEPLOY_WARN}    Y

    # 3) Check for Heads firmware deployment success:
    Wait For Checkpoint    Successfully switched to Dasharo Heads firmware
    Wait For Checkpoint And Write    ${DTS_CONFIRM_CHECKPOINT}    1
