*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     SDC Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SDC001.301 SD Card reader detection (Windows)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    ...    Previous IDs: SDC001.002
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" -Class "DiskDrive"
    Should Contain    ${out}    DiskDrive
    # Exit from root user
    Execute Shutdown Command

SDC002.301 SD Card read/write (Windows)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    ...    Previous IDs: SDC002.002
    Power On
    Login To Windows
    SSHLibrary.Put File    drive_letters.ps1    /C:/Users/user
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}
    Execute Shutdown Command
