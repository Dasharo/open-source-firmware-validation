*** Settings ***
Library     Collections
Resource    ../keywords.robot
Resource    ../lib/platform/power.robot


*** Keywords ***
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
    VAR    ${BOOTED_OS_ID}=    ${ENV_ID_PFSENSE}    scope=GLOBAL
    Load OS Credentials    ${BOOTED_OS_ID}

Boot OPNsense Installer
    [Documentation]    Run /efi/boot/bootx64.efi file from OPNEFI-labeled partition;
    Enter Boot From File
    Enter Volume In File Explorer    OPNEFI
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    Read From Terminal Until    login:
    VAR    ${BOOTED_OS_ID}=    ${ENV_ID_OPNSENSE}    scope=GLOBAL
    Load OS Credentials    ${BOOTED_OS_ID}

Enter PfSense Shell
    Write Into Terminal    8
    Read From Terminal Until    ${DEVICE_OS_ROOT_PROMPT}
    Set Prompt For Terminal    ${DEVICE_OS_ROOT_PROMPT}

Enter PfSense Rescue Shell
    ${menu}=    Read From Terminal Until    <Cancel>
    # end would be 5 but it's 3 due to two empty lines
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    5    3
    Enter Submenu From Snapshot
    ...    ${construction}
    ...    Rescue Shell Launch a shell for rescue operations
    ...    "APP"
    Set Prompt For Terminal    ${DEVICE_OS_RESCUE_PROMPT}

Enter OPNsense Shell
    Read From Terminal Until    login:
    Write Into Terminal    ${DEVICE_OS_USERNAME}
    Read From Terminal Until    Password:
    Write Into Terminal    ${DEVICE_OS_PASSWORD}
    Read From Terminal Until    Enter an option:
    Write Into Terminal    8
    Read From Terminal Until    ${DEVICE_OS_ROOT_PROMPT}
    Set Prompt For Terminal    ${DEVICE_OS_ROOT_PROMPT}

Boot PfSense
    [Documentation]    PFBOOT -> /efi/boot/bootx64.efi
    Enter Boot From File
    Enter Volume In File Explorer    PFBOOT
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    Enter an option:
    VAR    ${BOOTED_OS_ID}=    ${ENV_ID_PFSENSE}    scope=GLOBAL
    Load OS Credentials    ${BOOTED_OS_ID}

Boot OPNsense
    [Documentation]    OPNBOOT -> /efi/boot/bootx64.efi
    Enter Boot From File
    Enter Volume In File Explorer    OPNBOOT
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    VAR    ${BOOTED_OS_ID}=    ${ENV_ID_OPNSENSE}    scope=GLOBAL
    Load OS Credentials    ${BOOTED_OS_ID}
