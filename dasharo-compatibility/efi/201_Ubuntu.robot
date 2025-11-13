*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     EFI Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Init EFI Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
EFI001.201 Boot into UEFI OS (Ubuntu)
    [Documentation]    Boot into Linux OS and check whether there is a
    ...    possibility to identify the system.
    ...    Previous IDs: EFI001.001
    ${out}=    Execute Command In Terminal    cat /etc/os-release
    Should Contain    ${out}    Ubuntu


*** Keywords ***
Init EFI Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
