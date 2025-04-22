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
...                     AND
...                     Restore Secure Boot Defaults
Suite Teardown      Run Keywords
...                     Run Keyword If    ${SECURE_BOOT_SUPPORT} and ${TESTS_IN_FIRMWARE_SUPPORT}    Set Secure Boot State To Disabled
...                     AND
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Variables ***
${PFSENSE_PROMPT}=      [2.7.2-RELEASE][root@pfSense.home.arpa]/root


*** Test Cases ***
BPS001.001 Boot pfSense LTS CE (serial output) from disk after cold-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    Power On

BPS002.001 Boot pfSense LTS CE (serial output) from disk after warm-boot
    Power On

BPS003.001 Boot pfSense LTS CE (serial output) from disk after reboot
    Power On

OPN001.001 OPNsense stable (serial output) installation on Hard Disk
    Power On
    Boot OPNsense Installer

OPN001.002 Boot OPNsense stable (serial output) from Hard Disk
    Power On

PFS001.001 pfSense stable (serial output) installation on Hard Disk
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
    Enter Submenu From Snapshot    ${construction}    Rescue Shell${SPACE_*_8}Launch a shell for rescue operations
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

Install PsSense On Sata Drive
    ${welcome_menu}=    Read From Terminal Until    OK
    # end would be 5 but it's 3 due to two empty lines
    ${welcome_construction}=    Parse Menu Snapshot Into Construction    ${welcome_menu}    5    3
    Enter Submenu From Snapshot    ${welcome_construction}    Install${SPACE_*_13}Install pfSense
    ${partition_construction}=    Get Submenu Construction    OK    5    3
    Enter Submenu From Snapshot    ${partition_construction}    Auto (ZFS)${SPACE_*_2}Guided Root-on-ZFS
    Read From Terminal Until    ZFS Configuration
    ${pool_suspect}=    Read From Terminal
    ${pool_taken}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${pool_suspect}
    ...    pfSense is already taken, please enter a name for the ZFS pool
    ${my_tail2}=    Read From Terminal
    Log To Console    "my tail2"
    Log To Console    ${my_tail2}
    IF    ${pool_taken} == ${TRUE}
        Press Enter
        ${pool_suspect}=    Read From Terminal Until    qqqqqj
    END
    Log To Console    "pool suspect"
    Log To Console    ${pool_suspect}
    ${configure_construction}=    Parse Menu Snapshot Into Construction    ${pool_suspect}    5    1
    # Enter Submenu From Snapshot    ${configure_construction}    T Pool Type/Disks:${SPACE * 3}stripe: 0 disks
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    ${my_tail3}=    Read From Terminal
    Log To Console    "my tail3"
    Log To Console    ${my_tail3}
    ${select_virtual}=    Get Submenu Construction    OK    5    3
    # Read From Terminal Until    Select Virtual Device type
    # ${select_virtual}=    Read From Terminal Until    Cancel

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
