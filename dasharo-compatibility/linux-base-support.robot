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

Default Tags        semiauto


*** Test Cases ***
LBT001.201 Ubuntu LTS installation on Hard Disk (Ubuntu)
    [Documentation]    Check whether Ubuntu LTS can be installed on the hard disk of the DUT.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/5] Prepare an Ubuntu LTS installation medium (USB or DVD)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Ubuntu installation medium
    Execute Manual Step    [3/5] Follow the Ubuntu installer steps to complete the installation on the hard disk
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Ubuntu boots successfully from the hard disk after installation

LBT002.201 Boot Ubuntu LTS From Hard Disk (Ubuntu)
    [Documentation]    Check whether Ubuntu LTS boots correctly from the hard disk.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/3] Power on the DUT with Ubuntu LTS installed on the hard disk
    Execute Manual Step    [2/3] Select Ubuntu from the boot menu if multiple OS are present
    Execute Manual Step    [3/3] Confirm Ubuntu boots to the login screen or desktop successfully

LBT003.201 Ubuntu LTS installation on USB storage (Ubuntu)
    [Documentation]    Check whether Ubuntu LTS could be installed on USB storage.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step
    ...    [1/1] According to the Documentation perform the OS installation process. As disk choose the USB stick
    Execute Manual Step    [Expected result] The information about successful installation should be displayed.

LBT004.201 Boot Ubuntu LTS from USB (Ubuntu)
    [Documentation]    Check whether Ubuntu LTS boots correctly from USB storage.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [3/4] In the Boot Menu, select the USB_STORAGE on which the system was previously installed.
    Execute Manual Step    [4/4] Wait for the OPERATING_SYSTEM to boot and note the result.
    Execute Manual Step    [Expected result] The OPERATING_SYSTEM login screen should be displayed.

LBT001.208 Debian stable installation on Hard Disk (Debian)
    [Documentation]    Check whether Debian stable can be installed on the hard disk of the DUT.
    Skip If    '${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/5] Prepare a Debian stable installation medium (USB or DVD)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Debian installation medium
    Execute Manual Step    [3/5] Follow the Debian installer steps to complete the installation on the hard disk
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Debian boots successfully from the hard disk after installation

LBT002.208 Boot Debian from Hard Disk (Debian)
    [Documentation]    Check whether Debian boots correctly from the hard disk.
    Skip If    '${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/3] Power on the DUT with Debian installed on the hard disk
    Execute Manual Step    [2/3] Select Debian from the boot menu if multiple OS are present
    Execute Manual Step    [3/3] Confirm Debian boots to the login screen or desktop successfully

LBT003.208 Debian Stable installation on USB storage (Debian)
    [Documentation]    Check whether Debian Stable distribution could be installed on USB storage.
    Skip If    '${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step
    ...    [1/1] According to the Documentation perform the OS installation process. As disk choose the USB stick
    Execute Manual Step    [Expected result] The information about successful installation should be displayed.

LBT004.208 Boot Debian from USB (Debian)
    [Documentation]    Check whether Debian boots correctly from USB storage.
    Skip If    '${ENV_ID_DEBIAN}' not in ${TESTED_LINUX_DISTROS}
    Execute Manual Step    [1/4] Power on the DUT.
    Execute Manual Step    [2/4] Press BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [3/4] In the Boot Menu, select the USB_STORAGE on which the system was previously installed.
    Execute Manual Step    [4/4] Wait for the OPERATING_SYSTEM to boot and note the result.
    Execute Manual Step    [Expected result] The OPERATING_SYSTEM login screen should be displayed.
