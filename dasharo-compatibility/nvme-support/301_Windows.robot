*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     NVM Suite Setup
...                     AND    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.301 NVMe support in OS (Windows)
    [Documentation]    Check whether the Operating System can boot from NVMe
    ...    disk in M.2 slot.
    ...    Previous IDs: NVM001.003
    Power On
    Login To Windows
    # Switch to root user
    ${out}=    Execute Command In Terminal    Get-PnpDevice -Status "OK" | where { $_.InstanceId -like "*NVME*"}
    Should Contain    ${out}    DiskDrive
    # Exit from root user
    Execute Shutdown Command
