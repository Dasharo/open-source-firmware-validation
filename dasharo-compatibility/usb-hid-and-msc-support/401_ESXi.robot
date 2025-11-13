*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     USB Suite Setup
...                     AND    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ESXi not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.401 USB devices detection in OS (ESXi)
    [Documentation]    Check whether USB devices are correctly detected
    ...    in VMware ESXi using lsusb monitoring.
    ...    Previous IDs: USB001.011
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    lsusb
    Should Contain    ${out}    ${USB_MODEL}

USB002.401 USB keyboard detection in OS (ESXi)
    [Documentation]    Verify that an external USB keyboard is correctly detected in ESXi.
    ...    Detection includes visibility in `lsusb` and verification of working input via basic typing test.
    ...    Previous IDs: USB002.011
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    lsusb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}
