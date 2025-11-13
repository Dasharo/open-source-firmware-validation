*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     SDC Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init SDC Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SDC001.201 SD Card reader detection (Ubuntu)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    ...    Previous IDs: SDC001.001
    Check SD Card Detection Linux

SDC002.201 SD Card read/write (Ubuntu)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    ...    Previous IDs: SDC002.001
    Check SD Card Read Write Linux


*** Keywords ***
Init SDC Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
