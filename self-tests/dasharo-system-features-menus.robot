*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 entering and parsing Dasharo System Features menu and it's submenus.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
Enter Dasharo System Features Menu
    [Documentation]    Check if Dasharo System Features menu can be entered.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${setup_menu}    Dasharo System Features
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Dasharo System Features
    Should Contain    ${out}    Press ESC to exit.

Parse Dasharo System Features Menu
    [Documentation]    Check if Dasharo System Features menu can be parsed.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    List Should Contain Value    ${dasharo_menu}    > Serial Port Configuration
    Menu Construction Should Not Contain Control Text    ${dasharo_menu}

Enter Dasharo Security Options
    [Documentation]    Check if Dasharo Security Options menu can be entered.
    Enter Dasharo Submenu Verification    Dasharo Security Options

Parse Dasharo Security Options
    [Documentation]    Check if Dasharo Security Options menu can be parsed.
    ${security_menu}=    Parsing Dasharo Submenu Verification    Dasharo Security Options
    Should Match Regexp    ${security_menu}[0]    ^Lock the BIOS boot medium \\[.\\].*$
    List Should Contain Value    ${security_menu}    > Enter Firmware Update Mode
    # Second line from "Enable SMM BIOS write protection" should not be there
    List Should Not Contain Value    ${security_menu}    protection
    Menu Construction Should Not Contain Control Text    ${security_menu}

Enter Networking Options
    [Documentation]    Check if Networking Options menu can be entered.
    Enter Dasharo Submenu Verification    Networking Options

Parse Networking Options
    [Documentation]    Check if Networking Options menu can be parsed.
    ${networking_menu}=    Parsing Dasharo Submenu Verification    Networking Options
    ${networking_entries}=    Get Length    ${networking_menu}
    Should Be Equal As Integers    ${networking_entries}    1
    Should Match Regexp    ${networking_menu}[0]    ^Enable network boot \\[.\\].*$
    Menu Construction Should Not Contain Control Text    ${networking_menu}

Enter USB Configuration
    [Documentation]    Check if USB Configuration menu can be entered.
    Enter Dasharo Submenu Verification    USB Configuration

Parse USB Configuration
    [Documentation]    Check if USB Configuration menu can be parsed.
    ${usb_menu}=    Parsing Dasharo Submenu Verification    USB Configuration
    ${usb_entries}=    Get Length    ${usb_menu}
    Should Be Equal As Integers    ${usb_entries}    2
    Should Match Regexp    ${usb_menu}[0]    ^Enable USB stack \\[.\\].*$
    Should Match Regexp    ${usb_menu}[1]    ^Enable USB Mass Storage \\[.\\].*$
    # Second line from "Enable USB Mass Storage driver" should not be there
    List Should Not Contain Value    ${usb_menu}    driver
    Menu Construction Should Not Contain Control Text    ${usb_menu}

Enter Intel Management Engine Options
    [Documentation]    Check if Intel Management Engine menu can be entered.
    Enter Dasharo Submenu Verification    Intel Management Engine Options

Parse Intel Management Engine Options
    [Documentation]    Check if Intel Management Engine menu can be parsed.
    ${me_menu}=    Parsing Dasharo Submenu Verification    Intel Management Engine Options
    ${me_entries}=    Get Length    ${me_menu}
    Should Be Equal As Integers    ${me_entries}    1
    Should Match Regexp    ${me_menu}[0]    ^Intel ME mode <.*>.*$
    Menu Construction Should Not Contain Control Text    ${me_menu}

Enter Chipset Configuration
    [Documentation]    Check if Chipset Configuration menu can be entered.
    Enter Dasharo Submenu Verification    Chipset Configuration

Parse Chipset Configuration
    [Documentation]    Check if Chipset Configuration menu can be parsed.
    ${chipset_menu}=    Parsing Dasharo Submenu Verification    Chipset Configuration
    ${chipset_entries}=    Get Length    ${chipset_menu}
    Should Be Equal As Integers    ${chipset_entries}    3
    Should Match Regexp    ${chipset_menu}[0]    ^Enable PS2 Controller \\[.\\].*$
    Menu Construction Should Not Contain Control Text    ${chipset_menu}

Enter Power Management Options
    [Documentation]    Check if Power Management Options menu can be entered.
    Enter Dasharo Submenu Verification    Power Management Options

Parse Power Management Options
    [Documentation]    Check if Power Management Options menu can be parsed.
    ${power_menu}=    Parsing Dasharo Submenu Verification    Power Management Options
    ${power_entries}=    Get Length    ${power_menu}
    Should Be Equal As Integers    ${power_entries}    4
    Should Match Regexp    ${power_menu}[0]    ^Fan profile <.*>.*$
    # Second line from Batter Start/Stop Chare Threshold should not be there
    List Should Not Contain Value    ${power_menu}    Threshold
    Menu Construction Should Not Contain Control Text    ${power_menu}

Enter PCI/PCIe Configuration
    [Documentation]    Check if PCI/PCIe Configuration menu can be entered.
    Enter Dasharo Submenu Verification    PCI/PCIe Configuration

Parse PCI/PCIe Configuration
    [Documentation]    Check if PCI/PCIe Configuration menu can be parsed.
    ${pci_menu}=    Parsing Dasharo Submenu Verification    PCI/PCIe Configuration
    ${pci_entries}=    Get Length    ${pci_menu}
    Should Be Equal As Integers    ${pci_entries}    2
    Should Match Regexp    ${pci_menu}[0]    ^Enable PCIe Resizeable \\[.\\].*$
    # Second line from Enable PCIe Resizeable BARs should not be there
    List Should Not Contain Value    ${pci_menu}    BARs
    Menu Construction Should Not Contain Control Text    ${pci_menu}

Enter Memory Configuration
    [Documentation]    Check if Memory Configuration menu can be entered.
    Enter Dasharo Submenu Verification    Memory Configuration

Parse Memory Configuration
    [Documentation]    Check if Memory Configuration menu can be parsed.
    ${memory_menu}=    Parsing Dasharo Submenu Verification    Memory Configuration
    ${memory_entries}=    Get Length    ${memory_menu}
    Should Be Equal As Integers    ${memory_entries}    1
    Should Match Regexp    ${memory_menu}[0]    ^Memory SPD Profile <.*$
    # Second line from profile should not be there
    List Should Not Contain Value    ${memory_menu}    non-overclocked default)>
    List Should Not Contain Value    ${memory_menu}    extreme memory profile)>
    Menu Construction Should Not Contain Control Text    ${memory_menu}

Enter Serial Port Configuration
    [Documentation]    Check if Serial Port Configuration menu can be entered.
    Enter Dasharo Submenu Verification    Serial Port Configuration

Parse Serial Port Configuration
    [Documentation]    Check if Serial Port Configuration menu can be parsed.
    ${serial_menu}=    Parsing Dasharo Submenu Verification    Serial Port Configuration
    ${serial_entries}=    Get Length    ${serial_menu}
    Should Be Equal As Integers    ${serial_entries}    1
    Should Match Regexp    ${serial_menu}[0]    ^Enable Serial Port \\[.\\].*$
    # Second line from Enable Serial Port Console Redirection should not be there
    List Should Not Contain Value    ${serial_menu}    Console Redirection
    Menu Construction Should Not Contain Control Text    ${serial_menu}


*** Keywords ***
Enter Dasharo Submenu Verification
    [Documentation]    Enters Dasharo System Features submenu as in the given
    ...    ${submenu_name}. Checks whether the menu can be entered properly.
    [Arguments]    ${submenu_name}
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    Enter Submenu From Snapshot    ${dasharo_menu}    ${submenu_name}
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    ${submenu_name}
    Should Contain    ${out}    Press ESC to exit.
    RETURN    ${out}

Parsing Dasharo Submenu Verification
    [Documentation]    Enters Dasharo System Features submenu as in the given
    ...    ${submenu_name}. Returns parsed submenu construction.
    [Arguments]    ${submenu_name}
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${dasharo_submenu}=    Enter Dasharo Submenu    ${dasharo_menu}    ${submenu_name}
    Log    ${dasharo_submenu}
    RETURN    ${dasharo_submenu}
