*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVM Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init NVM Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.202 NVMe support in OS (Fedora)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    Check NVMe Support Linux


*** Keywords ***
Init NVM Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
