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
Enter Boot Menu
    [Documentation]    Test Enter Boot Menu kwd
    Power On
    Enter Boot Menu
    ${out}=    Read From Terminal Until    [memtest]
    Should Contain    ${out}    Select boot device:

Enter Boot Menu And Return Construction
    [Documentation]    Test Enter Boot Menu And Return Construction kwd
    Power On
    ${menu}=    Enter Boot Menu And Return Construction
    List Should Not Contain Value    ${menu}    Select boot device:
    List Should Contain Value    ${menu}    1. DVD/CD [AHCI/2: QEMU DVD-ROM ATAPI-4 DVD/CD]
    List Should Contain Value    ${menu}    2. Payload [setup]
    List Should Contain Value    ${menu}    3. Payload [memtest]
    List Should Contain Value    ${menu}    t. TPM Configuration
    Menu Construction Should Not Contain Control Text    ${menu}

Enter Setup Menu
    [Documentation]    Test Enter Setup Menu kwd
    Power On
    Enter Setup Menu
    ${out}=    Read From Terminal Until    Save configuration and exit
    Should Contain    ${out}    PC Engines QEMU x86 q35/ich9 setup

Get sortbootorder Menu Construction
    [Documentation]    Get sortbootorder Menu Construction kwd
    Power On
    Enter Setup Menu
    ${menu}=    Get Sortbootorder Menu Construction
    List Should Not Contain Value    ${menu}    Boot order
    List Should Contain Value    ${menu}    r Restore boot order defaults
    List Should Contain Value    ${menu}    n Network/PXE boot - Currently Disabled
    List Should Contain Value    ${menu}    u USB boot - Currently Enabled
    List Should Contain Value    ${menu}    t Serial console - Currently Enabled
    List Should Contain Value    ${menu}    k Redirect console output to COM2 - Currently Disabled
    List Should Contain Value    ${menu}    o UART C - Currently Enabled - Toggle UART C / GPIO
    List Should Contain Value    ${menu}    p UART D - Currently Enabled - Toggle UART D / GPIO
    List Should Contain Value    ${menu}    m Force mPCIe2 slot CLK (GPP3 PCIe) - Currently Disabled
    List Should Contain Value    ${menu}    h EHCI0 controller - Currently Disabled
    List Should Contain Value    ${menu}    l Core Performance Boost - Currently Enabled
    List Should Contain Value    ${menu}    i Watchdog - Currently Disabled
    List Should Contain Value    ${menu}    j SD 3.0 mode - Currently Disabled
    List Should Contain Value    ${menu}    g Reverse order of PCI addresses - Currently Disabled
    List Should Contain Value    ${menu}    v IOMMU - Currently Disabled
    List Should Contain Value    ${menu}    y PCIe power management features - Currently Disabled
    List Should Contain Value    ${menu}    w Enable BIOS write protect - Currently Disabled
    List Should Contain Value    ${menu}    z Clock menu
    List Should Contain Value    ${menu}    x Exit setup without save
    List Should Contain Value    ${menu}    s Save configuration and exit
    Menu Construction Should Not Contain Control Text    ${menu}

Get Option State
    [Documentation]    Test Get Option State kwd
    Power On
    Enter Setup Menu
    ${menu}=    Get Sortbootorder Menu Construction
    ${state}=    Get Option State    ${menu}    Network/PXE boot
    Should Contain    ${state}    Disabled

Enter Menu From Snapshot and Return sortbootorder Construction
    [Documentation]    Test Enter Menu From Snapshot and Return sortbootorder Construction kwd
    Power On
    Enter Setup Menu
    ${menu}=    Get Sortbootorder Menu Construction
    ${menu}=    Enter Menu From Snapshot And Return Sortbootorder Construction    ${menu}    Network/PXE boot
    List Should Not Contain Value    ${menu}    Boot order
    List Should Contain Value    ${menu}    r Restore boot order defaults
    List Should Contain Value    ${menu}    n Network/PXE boot - Currently Enabled
    List Should Contain Value    ${menu}    u USB boot - Currently Enabled
    List Should Contain Value    ${menu}    t Serial console - Currently Enabled
    List Should Contain Value    ${menu}    k Redirect console output to COM2 - Currently Disabled
    List Should Contain Value    ${menu}    o UART C - Currently Enabled - Toggle UART C / GPIO
    List Should Contain Value    ${menu}    p UART D - Currently Enabled - Toggle UART D / GPIO
    List Should Contain Value    ${menu}    m Force mPCIe2 slot CLK (GPP3 PCIe) - Currently Disabled
    List Should Contain Value    ${menu}    h EHCI0 controller - Currently Disabled
    List Should Contain Value    ${menu}    l Core Performance Boost - Currently Enabled
    List Should Contain Value    ${menu}    i Watchdog - Currently Disabled
    List Should Contain Value    ${menu}    j SD 3.0 mode - Currently Disabled
    List Should Contain Value    ${menu}    g Reverse order of PCI addresses - Currently Disabled
    List Should Contain Value    ${menu}    v IOMMU - Currently Disabled
    List Should Contain Value    ${menu}    y PCIe power management features - Currently Disabled
    List Should Contain Value    ${menu}    w Enable BIOS write protect - Currently Disabled
    List Should Contain Value    ${menu}    z Clock menu
    List Should Contain Value    ${menu}    x Exit setup without save
    List Should Contain Value    ${menu}    s Save configuration and exit
    Menu Construction Should Not Contain Control Text    ${menu}

Enter TPM Configuration
    [Documentation]    Test Enter TPM Configuration kwd
    Power On
    Enter TPM Configuration
    ${out}=    Read From Terminal Until    reboot the machine
    Should Contain    ${out}    Clear TPM

Enable Network Boot
    [Documentation]    Test Enable Network/PXE boot
    Power On
    Enable Network/PXE Boot
    Enter Setup Menu
    ${menu}=    Get Sortbootorder Menu Construction
    List Should Contain Value    ${menu}    n Network/PXE boot - Currently Enabled

Enter iPXE
    [Documentation]    Test Enter iPXE kwd
    Power On
    Enter IPXE
    ${out}=    Read From Terminal Until    autoboot
    Should Contain    ${out}    ipxe shell
