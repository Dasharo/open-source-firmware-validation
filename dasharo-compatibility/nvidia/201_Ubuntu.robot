*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVI Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    "${ENV_ID_UBUNTU}" not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init NVI Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVI001.201 NVIDIA Graphics detect (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Linux OS.
    ...    Previous IDs: NVI001.001
    Check NVIDIA Graphics Detect Linux

NVI002.201 NVIDIA Graphics power management (Ubuntu)
    [Documentation]    Check whether the NVIDIA graphics power management is
    ...    functional and the card powers on only while it's used.
    ...    Previous IDs: NVI002.001
    Check NVIDIA Graphics Power Management Linux


*** Keywords ***
Init NVI Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
