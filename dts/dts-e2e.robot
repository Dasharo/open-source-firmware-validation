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
...                     Skip If    not ${DTS_SUPPORT}    AND
...                     Power On And Enter DTS Shell    AND
...                     Execute Linux Command    systemctl start sshd
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Prepare DTS Test
Test Teardown       Teardown DTS Test


*** Test Cases ***
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

################################################################################
# NovaCustom tests:
################################################################################

E2E002.001 NCM NV4XMB,ME,MZ initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NV4XMB,ME,MZ. This deployment
    ...    should pass without credentials.
    [Tags]    novacustom_comm
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
    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4xPZ" TEST_BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb" TEST_USING_OPENSOURCE_EC_FIRM="true"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

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
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.006 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    DDR 4(MS-7D25). This deployment should pass with credentials.
    [Tags]    msi_dpp
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

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
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Go Through Update

E2E003.008 MSI PRO Z690-A update (Coreboot + UEFI -> Coreboot + UEFI) - community version
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI(MS-7D25)/PRO Z690-A(MS-7D25). We start from Dasharo
    ...    (coreboot + UEFI) firmware with version that should allow for the
    ...    update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_comm
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Go Through Update

E2E003.009 MSI PRO Z690-A DDR-4 update (Coreboot + UEFI -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A DDR4(MS-7D25). We start from
    ...    Dasharo (coreboot + UEFI) firmware with version that should allow for
    ...    the update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
    [Tags]    msi_dpp
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update Decline Heads

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
    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update Decline Heads

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E003.011 MSI PRO Z690-A DDR4 transition (Coreboot + UEFI -> heads) - without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert no DPP keys, so we expect no update will be provided, but a
    ...    message encouraging subscription purchase should be visible.
    [Tags]    msi_heads

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

    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start Heads transition:
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

    # 2) Emulate needed env.. We assume that transition is from Dasharo UEFI to
    # Dasharo HEAD, so we need to emulate appropriate EC firmware presence:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start Heads transition:
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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update

E2E004.005 Dell OptiPlex 9010 DPP initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    [Tags]    optiplex_dpp

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start initial deployment:
    Go Through Initial Deployment    DPP UEFI

    # 5) The final step is rebooting:
    Wait For Checkpoint    Rebooting

E2E005.003 PC Engines DPP update (Coreboot + SeaBIOS -> Coreboot + SeaBIOS) - without credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) update logic on PC
    ...    Engines. We start from old firmware and insert correct DPP keys for
    ...    SeaBIOS variant.
    [Tags]    pcengines_seabios

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="coreboot 24.04.00.01" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Start update:
    Wait For Checkpoint And Write    ${DTS_CHECKPOINT}    ${DTS_DEPLOY_OPT}

    # 4) User should not have access to Heads update without proper credentials:
    Wait For Checkpoint    ${DTS_NOACCESS_DPP_SEABIOS}

E2E005.004 PC Engines DPP update (Coreboot + SeaBIOS -> Coreboot + SeaBIOS) - with credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) update logic on PC
    ...    Engines. We start from old firmware and insert correct DPP keys for
    ...    SeaBIOS variant.
    [Tags]    pcengines_seabios

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="coreboot 24.04.00.01" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update

################################################################################
# Odroid tests:
################################################################################

E2E006.001 Odroid H4 initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4
    ...    without credentials provided. User should not have access and DTS
    ...    should inform about it.
    [Tags]    odroid_dpp

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

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

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="Dasharo (coreboot+UEFI) v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Execute Command In Terminal    export TEST_BIOS_VENDOR="3mdeb"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    Provide DPP Credentials

    # 4) Start update:
    Go Through Update


*** Keywords ***
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
