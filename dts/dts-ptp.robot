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
# TODO: We should extend our keyword lybs with keywords for DTS UI, these are
# first candidates. But before doing so - we need to establish some UI rules in
# DTS itself.
${DTS_CHECKPOINT}=                  Enter an option:
${DTS_CONFIRM_CHECKPOINT}=          Press any key to continue
${HCL_REPORT_CHECKPOINT}=           Thank you for contributing to the "Hardware for Linux" project!
${HCL_REPORT_SENDINGLOGS}=
...                                 Do you want to support Dasharo development by sending us logs with your hardware configuration? [N/y]
${DTS_SPECIFICATION_WARN}=          Does it match your actual specification? (Y|n)
${DTS_DEPLOY_WARN}=                 Do you want to deploy this Dasharo Firmware on your platform (Y|n)
${DTS_HW_PROBE_WARN}=               Do you want to participate in this project?
${DTS_HEADS_SWITCH_QUESTION}=       Would you like to switch to Dasharo heads firmware? (Y|n)
# Default DTS boot type, can be overwritten by CMD:
${DTS_BOOT_TYPE}=                   iPXE


*** Test Cases ***
PTP001.001 HCL Report test
    [Documentation]    Verify that HCL Report is being executed with all
    ...    expected messages. The report should not fail even if it failed to
    ...    collect some data, because it is responsible only for collecting.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Prepare DTS for testing:
    Execute Command In Terminal    export DTS_TESTING="true"
    Write Into Terminal    dts-boot

    # 3) Launch HCL report:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    1
    Log    ${out}

    # 4) Check out all HCL Report questions:
    ${out}=    Read From Terminal Until    ${HCL_REPORT_SENDINGLOGS}
    Sleep    2s
    Write Into Terminal    N
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Wait for final HCL Report checkpoint:
    Read From Terminal Until    ${HCL_REPORT_CHECKPOINT}

################################################################################
# NovaCustom tests:
################################################################################

PTP002.001 NCM NV4XMB,ME,MZ initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NV4XMB,ME,MZ. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4XMB,ME,MZ" TEST_BOARD_MODEL="NV4XMB,ME,MZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.002 NCM NS50_70MU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NS50_70MU. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NS50_70MU" TEST_BOARD_MODEL="NS50_70MU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.003 NCM NS5x_NS7xPU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NS5x_NS7xPU. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NS5x_NS7xPU" TEST_BOARD_MODEL="NS5x_NS7xPU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.004 NCM NV4xPZ initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom NV4xPZ. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="NV4xPZ" TEST_BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.005 NCM NV4xPZ transition (Coreboot + UEFI -> Coreboot + Heads) - DPP version, without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom NV4X ADL. We start from Dasharo (coreboot + UEFI) firmware
    ...    with version that should allow for the transition. We insert no DPP
    ...    keys, so we expect no update will be provided, but a message
    ...    encouraging subscription purchase should be visible.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Heads firmware version is available
    Log    ${out}

PTP002.006 NCM transition NV4xPZ (Coreboot + UEFI -> Heads) - DPP version, with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert correct DPP keys for heads variant.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 6) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_HEADS_SWITCH_QUESTION}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) Check for Heads firmware deployment success:
    ${out}=    Read From Terminal Until    ${DTS_CONFIRM_CHECKPOINT}
    Should Contain    ${out}    Successfully switched to Dasharo Heads firmware
    Write Into Terminal    1
    Log    ${out}

    # 8) The final step is rebooting, in this case it is done emmidiately after
    # EC firm. has been updated:
    ${out}=    Read From Terminal Until    Updating EC...

PTP002.007 NCM V540_6x_TU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V540_6x_TU. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V54x_6x_TU" TEST_BOARD_MODEL="V540TU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_NOVACUSTOM_MODEL="v540tu"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.008 NCM V560_6x_TU initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V560_6x_TU. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V54x_6x_TU" TEST_BOARD_MODEL="V560TU"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export TEST_NOVACUSTOM_MODEL="v560tu"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.009 NCM V540TNC_TND_TNE initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V540TNC_TND_TNE. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V5xTNC_TND_TNE" TEST_BOARD_MODEL="V540TNx"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    1: V540TNx
    Write Into Terminal    1

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y

    # This is printed inside board_config function, which is called twice in
    # this workflow: at the beginning of dts and dasharo-deploy scripts, so we
    # see this message twice, this should be fixed from DTS side (FIXME)
    # 5) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    1: V540TNx
    Write Into Terminal    1

    # 6) Choose update to Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 7) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 8) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP002.010 NCM V560TNC_TND_TNE initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for NovaCustom V560TNC_TND_TNE. This deployment
    ...    should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="V5xTNC_TND_TNE" TEST_BOARD_MODEL="V560TNx"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Notebook"
    Write Into Terminal    dts-boot

    # 3) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    2: V560TNx
    Write Into Terminal    2

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # This is printed inside board_config function, which is called twice in
    # this workflow: at the beginning of dts and dasharo-deploy scripts, so we
    # see this message twice, this should be fixed from DTS side (FIXME)
    # 5) This platform board model cannot be manually detected, a message to
    # choose the model appears, and the possible choices are: "0. None below"
    # "1: V540TNx", "2: V560TNx":
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    2: V560TNx
    Write Into Terminal    2

    # 6) Choose update to Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 7) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 8) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

################################################################################
# MSI tests:
#
# Currently these tests cover all use cases for Z690 only, Z790 has the same
# configuration in board_config in dts-scripts and differs only by links to
# artifacts, so it will not cover any new logic. Therefore it was decided to
# leave this tests for future.
################################################################################

PTP003.001 MSI PRO Z690-A DDR4 initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    WIFI DDR4(MS-7D25). This deployment should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP003.002 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - community version
    [Documentation]    Verify logic for initial deployment of community version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI (MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Choose install Dasharo:
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    c) Community version
    Log    ${out}
    Write Into Terminal    c

    # 5) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP003.003 MSI PRO Z690-A DDR-4 initial deployment (legacy -> Coreboot + UEFI) - DPP version, without credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should not pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP003.004 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - DPP version, without credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    DDR 4(MS-7D25). This deployment should not pass without credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP003.005 MSI PRO Z690-A DDR-4 initial deployment (legacy -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    (MS-7D25). This deployment should pass with credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI DDR4(MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP003.006 MSI PRO Z690-A initial deployment (legacy -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify logic for initial deployment of DPP version
    ...    of Dahsaro Firmware for MSI PRO Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A
    ...    DDR 4(MS-7D25). This deployment should pass with credentials.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="MS-7D25" TEST_BOARD_MODEL="PRO Z690-A WIFI (MS-7D25)"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="1.0.0" TEST_SYSTEM_VENDOR="Micro-Star International Co., Ltd."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP003.007 MSI PRO Z690-A DDR-4 update (Coreboot + UEFI -> Coreboot + UEFI) - community version
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A DDR4(MS-7D25). We start from
    ...    Dasharo (coreboot + UEFI) firmware with version that should allow for
    ...    the update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 5) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP003.008 MSI PRO Z690-A update (Coreboot + UEFI -> Coreboot + UEFI) - community version
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI(MS-7D25)/PRO Z690-A(MS-7D25). We start from Dasharo
    ...    (coreboot + UEFI) firmware with version that should allow for the
    ...    update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.


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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 5) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP003.009 MSI PRO Z690-A DDR-4 update (Coreboot + UEFI -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI DDR4(MS-7D25)/PRO Z690-A DDR4(MS-7D25). We start from
    ...    Dasharo (coreboot + UEFI) firmware with version that should allow for
    ...    the update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.


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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 5) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP003.010 MSI PRO Z690-A update (Coreboot + UEFI -> Coreboot + UEFI) - DPP version, with credentials
    [Documentation]    Verify Dasharo (coreboot + UEFI) update logic on MSI PRO
    ...    Z690-A WIFI(MS-7D25)/PRO Z690-A(MS-7D25). We start from Dasharo
    ...    (coreboot + UEFI) firmware with version that should allow for the
    ...    update. This tests tests update via flashrom as well as via UEFI
    ...    Capsule Update, check choose_version in dasharo-deploy script for
    ...    more inf.. Therefore to test update via capsules - you have to
    ...    provide credentials with access to capsules.


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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 5) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP003.011 MSI PRO Z690-A DDR4 transition (Coreboot + UEFI -> heads) - without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert no DPP keys, so we expect no update will be provided, but a
    ...    message encouraging subscription purchase should be visible.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Heads firmware version is available
    Log    ${out}

PTP003.012 MSI PRO Z690-A DDR4 transition (Coreboot + UEFI -> heads) - with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert correct DPP keys for heads variant.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 6) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_HEADS_SWITCH_QUESTION}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) Check for Heads firmware deployment success:
    ${out}=    Read From Terminal Until    ${DTS_CONFIRM_CHECKPOINT}
    Should Contain    ${out}    Successfully switched to Dasharo Heads firmware
    Write Into Terminal    1
    Log    ${out}

    # 8) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP003.013 MSI PRO Z690-A transition (UEFI -> heads) - without credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert no DPP keys, so we expect no update will be provided, but a
    ...    message encouraging subscription purchase should be visible.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Heads firmware version is available
    Log    ${out}

PTP003.014 MSI PRO Z690-A transition (UEFI -> heads) - with credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on
    ...    NovaCustom MSI PRO Z690-A DDR4. We start from Dasharo (coreboot +
    ...    UEFI) firmware with version that should allow for the transition. We
    ...    insert correct DPP keys for heads variant.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 6) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_HEADS_SWITCH_QUESTION}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) Check for Heads firmware deployment success:
    ${out}=    Read From Terminal Until    ${DTS_CONFIRM_CHECKPOINT}
    Should Contain    ${out}    Successfully switched to Dasharo Heads firmware
    Write Into Terminal    1
    Log    ${out}

    # 8) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

################################################################################
# Dell tests:
################################################################################

PTP004.001 Dell OptiPlex 7010 DPP initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Start installation:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP004.002 Dell Optiplex 7010 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 7010" TEST_BOARD_MODEL="OptiPlex 7010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP004.003 Dell Optiplex 7010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Subscription firmware version is available
    Log    ${out}

PTP004.004 Dell Optiplex 7010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    7010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 5) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

PTP004.005 Dell OptiPlex 9010 DPP initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Start installation:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP004.006 Dell Optiplex 9010 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="OptiPlex 9010" TEST_BOARD_MODEL="OptiPlex 9010"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="Dell Inc."
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP004.007 Dell Optiplex 9010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 without credentials provided. User should not have access and
    ...    DTS should inform about it.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Subscription firmware version is available
    Log    ${out}

PTP004.008 Dell Optiplex 9010 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 5) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

################################################################################
# PC Engines tests. Only APU2 is being tested, other APUs have the same
# configuration, but different links, so testing them is not necessary:
################################################################################

PTP005.001 PC Engines DPP initial deployment (legacy -> Coreboot + UEFI) - no credentials
    [Documentation]    Verify DPP (coreboot + UEFI) and (coreboot + SeaBIOS)
    ...    initial deployment logic on PC Engines. We emulate legacy firmware
    ...    and do not provide DPP credentials. There should be no access granted
    ...    for the firmware without credentials.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + SeaBIOS) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP005.002 PC Engines DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Verify DPP (coreboot + UEFI) initial deployment logic on
    ...    PC Engines with credentials provided (these should be provided via
    ...    CMD).
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP005.003 PC Engines DPP initial deployment (legacy -> Coreboot + SeaBIOS) - without credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DPP keys
    ...    for UEFI variant.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + SeaBIOS) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP005.004 PC Engines DPP initial deployment (legacy -> Coreboot + SeaBIOS) - with credentials
    [Documentation]    Verify DPP (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DPP
    ...    keys for UEFI variant.
    # 1) Get into DTS:
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_VENDOR="PC Engines" TEST_SYSTEM_MODEL="APU2"
    Execute Command In Terminal    export TEST_BIOS_VERSION="v4.19.0.1" TEST_BOARD_MODEL="APU2"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain    ${out}    s) DPP version (coreboot + SeaBIOS)
    Log    ${out}
    Write Into Terminal    s

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

################################################################################
# Odroid tests:
################################################################################
PTP006.001 Odroid H4 initial deployment (legacy -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4
    ...    without credentials provided. User should not have access and DTS
    ...    should inform about it.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Write Into Terminal    dts-boot

    # 3) Start installation:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 4) Check whether DTS informs a user about missing access:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available but you don't have access
    Log    ${out}
    Write Into Terminal    b

PTP006.002 Odroid H4 DPP initial deployment (legacy -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4 with
    ...    credentials provided. User should have access, and firmware should be
    ...    deployed.
    # 1) Get into DTS
    Power On And Enter DTS Shell

    # 2) Emulate needed env.:
    Execute Command In Terminal
    ...    export DTS_TESTING="true" TEST_SYSTEM_MODEL="ODROID-H4" TEST_BOARD_MODEL="ODROID-H4"
    Execute Command In Terminal
    ...    export TEST_BIOS_VERSION="v0.0.0" TEST_SYSTEM_VENDOR="HARDKERNEL"
    Write Into Terminal    dts-boot

    # 3) Provide DPP credentials:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start initial deployment:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}
    # Wait for HCL report to do its work, might take some time:
    Set DUT Response Timeout    5m
    # Accept hw-probe question from HCL report:
    ${out}=    Read From Terminal Until    ${DTS_HW_PROBE_WARN}
    Sleep    2s
    Write Into Terminal    Y
    Set DUT Response Timeout    30s

    # 5) Choose update to Dasharo
    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
    Log    ${out}
    Write Into Terminal    d

    # 6) Check out all warnings:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 7) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PTP006.003 Odroid H4 update (Coreboot + UEFI -> Coreboot + UEFI) - without credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Odroid H4
    ...    without credentials provided. User should not have access and DTS
    ...    should inform about it.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 4) User should not have access to Heads update without proper credentials:
    ${out}=    Read From Terminal Until    but your\nsubscription does not give you the access to this firmware
    Should Contain    ${out}    Dasharo Subscription firmware version is available
    Log    ${out}

PTP006.004 Odroid H4 DPP update (Coreboot + UEFI -> Coreboot + UEFI) - with credentials
    [Documentation]    Checks whether a User will have access to initial
    ...    deployment of Dasharo firmware (Coreboot + UEFI) for Dell Optiplex
    ...    9010 with credentials provided. User should have access, and firmware
    ...    should be deployed.
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
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    4
    Provide DPP Credentials

    # 4) Start update:
    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    # 5) Check out all warnings and questions:
    ${out}=    Read From Terminal Until    ${DTS_SPECIFICATION_WARN}
    Write Into Terminal    Y
    Log    ${out}
    ${out}=    Read From Terminal Until    ${DTS_DEPLOY_WARN}
    Write Into Terminal    Y
    Log    ${out}

    # 6) The final step is rebooting:
    ${out}=    Read From Terminal Until    Rebooting

*** Keywords ***
Power On And Enter DTS Shell
    # Check how user wants to boot DTS, options: USB, iPXE. The way to boot DTS
    # Should be defined before running tests, e.g. via CMD or some file, using
    # 1) Boot up to DTS UI:
    Power On
    Boot Dasharo Tools Suite    ${DTS_BOOT_TYPE}

    # 2) Enter shell:
    Write Into Terminal    S
    Set Prompt For Terminal    bash-5.2#
    Read From Terminal Until Prompt
    Set DUT Response Timeout    90s

Provide DPP Credentials
    # Enter logs key:
    Variable Should Exist    ${DPP_LOGS_KEY}
    Write Into Terminal    ${DPP_LOGS_KEY}
    # Enter download key:
    Variable Should Exist    ${DPP_DOWNLOAD_KEY}
    Write Into Terminal    ${DPP_DOWNLOAD_KEY}
    # Enter password:
    Variable Should Exist    ${DPP_PASSWORD}
    Write Into Terminal    ${DPP_PASSWORD}
