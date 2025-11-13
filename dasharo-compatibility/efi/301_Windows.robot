*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     EFI Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
EFI001.301 Boot into UEFI OS (Windows)
    [Documentation]    Boot into Windows 11 OS and check whether there is a
    ...    possibility to identify the system
    ...    Previous IDs: EFI001.301
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    (Get-WmiObject -class Win32_OperatingSystem).Caption
    Should Contain    ${out}    Microsoft Windows 11
