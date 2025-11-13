*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVM Suite Setup
...                     AND    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    XCP-NG not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.205 NVMe support in OS (XCP-NG)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.010
    Power On
    Login To OS    ${ENV_ID_XCP_NG}
    ${out}=    List Devices In Linux    pci
    Should Contain    ${out}    ${DEVICE_NVME_DISK}
