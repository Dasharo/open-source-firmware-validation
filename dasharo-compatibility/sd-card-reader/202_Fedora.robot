*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     SDC Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init SDC Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SDC001.202 SD Card reader detection (Fedora)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Check SD Card Detection Linux

SDC002.202 SD Card read/write (Fedora)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Check SD Card Read Write Linux


*** Keywords ***
Init SDC Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
