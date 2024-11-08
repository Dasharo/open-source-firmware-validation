*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 entering and parsing Boot Menu, Setup Menu, and top-level submenus
...                 of the Setup Menu.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=10 seconds    connection_timeout=40 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Enter Boot Menu SeaBIOS
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    Enter Boot Menu SeaBIOS
    ${out}=    Read From Terminal Until    [memtest]
    Should Contain    ${out}    Select boot device:

Enter Boot Menu SeaBIOS And Return Construction
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    ${menu}=    Enter Boot Menu SeaBIOS And Return Construction
    List Should Not Contain Value    ${menu}    Select boot device:
    List Should Contain Value    ${menu}    1. DVD/CD [AHCI/2: QEMU DVD-ROM ATAPI-4 DVD/CD]
    List Should Contain Value    ${menu}    2. iPXE
    List Should Contain Value    ${menu}    3. Payload [setup]
    List Should Contain Value    ${menu}    4. Payload [memtest]
    List Should Contain Value    ${menu}    t. TPM Configuration
    Menu Construction Should Not Contain Control Text    ${menu}

Enter sortbootorder
    [Documentation]    Test Enter sortbootorder kwd
    Power On
    Enter sortbootorder
    ${out}=    Read From Terminal Until    Save configuration and exit
    Should Contain    ${out}    ### PC Engines QEMU x86 q35/ich9 setup

Enter TPM Configuration
    [Documentation]    Test Enter TPM Configuration kwd
    Power On
    Enter TPM Configuration
    ${out}=    Read From Terminal Until    reboot the machine
    Should Contain    ${out}    Clear TPM

Enter iPXE
    [Documentation]    Test Enter iPXE kwd
    Power On
    Enter iPXE
    ${out}=    Read From Terminal Until    autoboot
    Should Contain    ${out}    ipxe shell
