*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SAT001.411 SATA support (ESXi)
    [Documentation]    Verify that a SATA storage device is detected by the ESXi system
    ...    and optionally check SMART data if available.
    ...    Previous IDs: SAT001.011
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    SAT001.411 not supported
    Skip If    '${ENV_ID_ESXI}' not in ${TESTED_LINUX_DISTROS}    SAT001.411 not supported

    Pause Execution
    ...    This is a manual test to confirm SATA device detection and optional SMART info on ESXi.

    Execute Manual Step    [1/6] Insert SATA SSD or HDD into the DUT
    Execute Manual Step    [2/6] Power on the DUT
    Execute Manual Step    [3/6] Boot into ESXi
    Execute Manual Step    [4/6] Log in using SSH
    Execute Manual Step    [5/6] Run command: esxcli storage core device list
    ...    - Confirm that the SATA device appears in the list
    ...    - Match by model/vendor/type
    Execute Manual Step    [6/6] (Optional) Run: esxcli storage core device smart get -d <DeviceName>
    ...    - Replace <DeviceName> with e.g. t10.ATA______
    ...    - Confirm SMART data includes model, serial number, and firmware revision
