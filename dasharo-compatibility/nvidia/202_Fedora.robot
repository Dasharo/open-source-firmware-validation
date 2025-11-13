*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVI Suite Setup
...                     AND    Skip If    "${ENV_ID_FEDORA}" not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init NVI Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVI001.202 NVIDIA Graphics detect (Fedora)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    Check NVIDIA Graphics Detect Linux

NVI002.202 NVIDIA Graphics power management (Fedora)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    Check NVIDIA Graphics Power Management Linux


*** Keywords ***
Init NVI Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
