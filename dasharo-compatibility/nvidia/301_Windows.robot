*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVI Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVI001.301 NVIDIA Graphics detect (Windows)
    [Documentation]    Check whether the NVIDIA graphics card is initialized
    ...    correctly and can be detected by the Windows 11.
    ...    Previous IDs: NVI001.002
    Power On
    Login To Windows
    ${out}=    Get Video Controllers Windows
    Should Contain    ${out}    NVIDIA GeForce
