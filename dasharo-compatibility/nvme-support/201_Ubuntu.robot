*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVM Suite Setup
...                     AND    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init NVM Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.201 NVMe support in OS (Ubuntu)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.002
    Check NVMe Support Linux

NVM002.201 NVMe slot change to x2 support in OS (Ubuntu)
    Depends On    ${NVME_X2_SLOT_SUPPORT}
    Check NVMe Slot Change Support Linux    ${ENV_ID_UBUNTU}


*** Keywords ***
Init NVM Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
