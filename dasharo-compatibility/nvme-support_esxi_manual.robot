*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NVME_DISK_SUPPORT}    NVMe disk tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
NVM001.411 NVMe support (ESXi)
    [Documentation]    Verify that ESXi is installed and booted from an NVMe drive.
    ...    Check that NVMe is detected and marked as the boot device.
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    NVM001.411 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    NVM001.411 not supported

    Pause Execution
    ...    This is a manual test to verify NVMe support and boot status on ESXi.

    Execute Manual Step    [1/5] Ensure NVMe drive is installed in M.2 slot on DUT
    Execute Manual Step    [2/5] Power on the DUT
    Execute Manual Step    [3/5] Boot into ESXi installed on the NVMe disk
    Execute Manual Step    [4/5] Log in via SSH
    Execute Manual Step    [5/5] Run command: esxcli storage core nvme device list
    ...    - Confirm that output lists the NVMe device
    ...    - Confirm that it includes the line: Is Boot Device: true
