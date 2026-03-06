*** Settings ***
Library             Collections
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/custom_bootentries.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
Bootorder Persistence Via SSH
    [Documentation]    Tests if the DEFAULT_BOOT_OS is persistently the first
    ...    bootentry in the bootorder across a couple problematic scenarios.
    ...    Prerequisite: Run `util/basic-platform-setup.robot` (BPS009)
    Skip If    '${OPTIONS_LIB}' != 'options-lib_dcu'    Only supported when testing via SSH without Serial

    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Log In To Linux
    Switch To Root User

    ${label}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${DEFAULT_BOOT_OS_ID}
    ${custom_bootname}=    Get Custom Bootentry Name    ${DEFAULT_BOOT_OS_ID}
    ${custom_bootnum}=    Get Bootnum For Label    ${custom_bootname}

    ${bootorder}=    Get BootOrder
    Log    BootOrder at start: ${bootorder}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}

    Set UEFI Option    NetworkBoot    ${TRUE}
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux
    Switch To Root User
    ${bootorder}=    Get BootOrder
    Log    BootOrder immediately after Set UEFI Option: ${bootorder}    level=WARN

    Boot And Login To Windows
    Execute Reboot Command
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux
    Switch To Root User
    ${bootorder}=    Get BootOrder
    Log    BootOrder after booting Windows: ${bootorder}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}

    Flash Via Internal Programmer    ${FW_FILE}    region=bios
    ${bootorder}=    Get BootOrder
    Log    BootOrder immediately after flashing: ${bootorder}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}

    Execute Reboot Command    assume_correct_boot=${TRUE}
    Sleep    10s
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Log In To Linux
    Switch To Root User
    ${bootorder}=    Get BootOrder
    Log    BootOrder after reboot: ${bootorder}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}
