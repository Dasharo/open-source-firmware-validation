*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVM Suite Setup
...                     AND    Depends On    ${TESTS_IN_ESXI_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.401 NVMe support in OS (ESXi)
    [Documentation]    Verify that ESXi is installed and booted from an NVMe drive.
    ...    Check that NVMe is detected and marked as the boot device.
    ...    Previous IDs: NVM001.011
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli storage core nvme device list
    Should Contain All    ${out}    Vendor: NVMe    Is Boot Device: true
