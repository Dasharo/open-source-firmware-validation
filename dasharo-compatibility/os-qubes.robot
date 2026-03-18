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

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
QBS001.203 Qubes OS installation (Qubes OS)
    [Documentation]    Check whether Qubes OS can be installed on the DUT.
    Execute Manual Step    [1/5] Prepare a Qubes OS installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Qubes OS installation medium
    Execute Manual Step    [3/5] Follow the Qubes OS installer steps to complete the installation
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Qubes OS boots successfully after installation

QBS002.203 Boot Qubes OS (Qubes OS)
    [Documentation]    Check whether Qubes OS boots correctly on the DUT.
    Execute Manual Step    [1/3] Power on the DUT with Qubes OS installed
    Execute Manual Step    [2/3] Select Qubes OS from the boot menu if multiple OS are present
    Execute Manual Step    [3/3] Confirm Qubes OS boots to the login screen or desktop successfully

QBS003.203 Add LUKS key to TPM (Qubes OS)
    [Documentation]    Check whether a LUKS disk encryption key can be added to the TPM in Qubes OS.
    Execute Manual Step    [1/4] Boot into Qubes OS
    Execute Manual Step    [2/4] Open a dom0 terminal and run the appropriate command to add the LUKS key to TPM
    Execute Manual Step    [3/4] Reboot the DUT and verify the disk unlocks automatically via TPM
    Execute Manual Step    [4/4] Confirm the LUKS key is successfully stored in the TPM and used for disk unlock

QBS004.203 Make Qubes the default boot entry (Qubes OS)
    [Documentation]    Check whether Qubes OS can be set as the default boot entry.
    Execute Manual Step    [1/3] Boot into Qubes OS
    Execute Manual Step    [2/3] Use efibootmgr or firmware setup menu to set Qubes OS as the default boot entry
    Execute Manual Step    [3/3] Reboot and confirm Qubes OS boots automatically as the default entry

QBS005.203 Boot installed Qubes from SSD (Qubes OS)
    [Documentation]    Check whether Qubes OS boots correctly from the SSD.
    Execute Manual Step    [1/3] Power on the DUT with Qubes OS installed on the SSD
    Execute Manual Step    [2/3] Wait for Qubes OS to boot from the SSD
    Execute Manual Step    [3/3] Confirm Qubes OS boots successfully from the SSD

QBS006.203 Reboot in Qubes (Qubes OS)
    [Documentation]    Check whether the DUT reboots correctly when running Qubes OS.
    Execute Manual Step    [1/3] Boot into Qubes OS
    Execute Manual Step    [2/3] Initiate a system reboot from Qubes OS (e.g. via the Power menu)
    Execute Manual Step    [3/3] Confirm the DUT reboots and Qubes OS boots again successfully
