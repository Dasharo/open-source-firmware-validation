*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
#...                     AND
#...                     Restore Secure Boot Defaults
Suite Teardown      Run Keywords
...                     Run Keyword If    ${SECURE_BOOT_SUPPORT} and ${TESTS_IN_FIRMWARE_SUPPORT}    Set Secure Boot State To Disabled
...                     AND
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Variables ***
${PFSENSE_PROMPT}=      [2.7.2-RELEASE][root@pfSense.home.arpa]/root


*** Test Cases ***
PFS001.502 Boot pfSense LTS CE (serial output) from disk after cold-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    Power On

PFS002.502 Boot pfSense LTS CE (serial output) from disk after warm-boot
    Power On

PFS003.502 Boot pfSense LTS CE (serial output) from disk after reboot
    Power On

PFS004.502 Boot pfSense LTS CE (serial output) Installer into rescue shell
    Power On
    Boot PfSense Installer
    Enter pfSense Rescue Shell

OPN001.503 OPNsense stable (serial output) installation on Hard Disk
    Power On
    Boot OPNsense Installer

OPN001.503 Boot OPNsense stable (serial output) from Hard Disk
    Power On

PFS001.502 pfSense stable (serial output) installation on Hard Disk
    Power On
    Boot PfSense Installer
#    Enter pfSense Rescue Shell
    Install PsSense On Sata Drive

PFS001.002 Boot pfSense stable (serial output) from Hard Disk
    Power On
    Boot Pf Sense


*** Keywords ***
# Relabel pfSense ESP
#

Boot PfSense Installer
    [Documentation]    Run /EFI/BOOT/bootx64.efi file from PFEFI-labeled partition;
    ...    Select console type vt100 and accept the license
    Enter Boot From File
    Enter Volume In File Explorer    PFEFI
    Execute File In File Explorer    EFI
    Execute File In File Explorer    BOOT
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    Console type [vt100]:
    Write Into Terminal    vt100
    Read From Terminal Until    [Accept]
    Press Enter

Boot OPNsense Installer
    [Documentation]    Run /efi/boot/bootx64.efi file from OPNEFI-labeled partition;
    Enter Boot From File
    Enter Volume In File Explorer    OPNEFI
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    Read From Terminal Until    login:

Enter PfSense Rescue Shell
    ${menu}=    Read From Terminal Until    OK
    # end would be 5 but it's 3 due to two empty lines
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    5    3
    Enter Submenu From Snapshot    ${construction}    Rescue Shell${SPACE * 8}Launch a shell for rescue operations
    Write Into Terminal    root
    Write Into Terminal    root

Enter OPN Sense Rescue Shell:
    Read From Terminal    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    Read From Terminal Until    login:
    Write Into Terminal    root
    Read From Terminal Until    Password:
    Write Into Terminal    opnsense
    Read From Terminal Until    Enter an option:
    Write Into Terminal    8

Boot Pf Sense
    [Documentation]    PFBOOT -> /efi/freebsd/loader.efi
    Enter Boot From File
    Enter Volume In File Explorer    PFBOOT
    Execute File In File Explorer    efi
    Execute File In File Explorer    freebsd
    Execute File In File Explorer    loader.efi
    Read From Terminal Until    Enter an option:
    Write Into Terminal    8
    Read From Terminal Until    ${PFSENSE_PROMPT}

Boot OPN Sense
    Enter Boot From File

