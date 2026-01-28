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
    Skip If    '${OPTIONS_LIB}' != 'options-lib_dcu'    Only supported when testing via SSH without Serial

    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Log In To Linux
    Switch To Root User

    ${label}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${DEFAULT_BOOT_OS_ID}
    ${bootorder_initial}=    Get BootOrder
    Log    BootOrder initial: ${bootorder_initial}    level=WARN
    ${ubuntu_bootnum}=    Get Bootnum For Label    ${label}
    Log    ${label} original: Boot${ubuntu_bootnum}    level=WARN
    ${custom_bootnum}=    Ensure Custom Entry    ${label}    force=${TRUE}
    Log    ${label} custom: Boot${custom_bootnum}    level=WARN

    ${bootorder_after_step1}=    Get BootOrder
    Log    BootOrder after creating custom bootentry: ${bootorder_after_step1}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder_after_step1}    ${custom_bootnum}

    Set UEFI Option    NetworkBoot    ${TRUE}
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux
    Switch To Root User
    ${bootorder_immediate}=    Get BootOrder
    Log    BootOrder immediately after Set UEFI Option: ${bootorder_immediate}    level=WARN

    Login To Windows
    Execute Reboot Command
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Login To Linux
    Switch To Root User
    ${bootorder_immediate}=    Get BootOrder
    Log    BootOrder after booting Windows: ${bootorder_immediate}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder_after_step1}    ${custom_bootnum}

    Flash Via Internal Programmer    ${FW_FILE}    region=bios
    ${bootorder_immediate}=    Get BootOrder
    Log    BootOrder immediately after flashing: ${bootorder_immediate}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder_after_step1}    ${custom_bootnum}

    Execute Reboot Command    assume_correct_boot=${TRUE}
    Sleep    10s
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Log In To Linux
    Switch To Root User
    ${bootorder_after_reboot}=    Get BootOrder
    Log    BootOrder after reboot: ${bootorder_after_reboot}    level=WARN
    BootOrder Should Start With Bootnum    ${bootorder_after_step1}    ${custom_bootnum}
