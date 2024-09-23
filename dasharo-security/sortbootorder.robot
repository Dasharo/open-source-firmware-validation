*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SEBO001.001 Verify lspci
    [Documentation]    This test verifies that the MAC addresses from lspci -vv command are correctly mapped to PCIe bus numbers in reverse order.

    # Step 1: Execute the lspci command to retrieve PCIe device details
    ${lspci_output}=    Execute Command In Terminal    lspci    -vv    stdout=STDOUT
    Log    ${lspci_output}

    # Step 2: Parse the output to extract PCIe bus and MAC address
    ${parsed_pci_data}=    Parse Lspci Output    ${lspci_output}

    # Step 3: Sort parsed data by PCIe bus number in reverse order
    ${sorted_pci_data}=    Sort Dictionary By Keys Reverse    ${parsed_pci_data}

    # Step 4: Verify the MAC addresses follow the expected reverse order pattern
    Verify MAC Order Reverse    ${sorted_pci_data}


*** Keywords ***
Parse Lspci Output
    [Documentation]    Parses the lspci output and extracts PCIe bus numbers and corresponding MAC addresses.
    [Arguments]    ${lspci_output}
    ${pci_data}=    Create Dictionary
    ${lines}=    Split String    ${lspci_output}    \n
    FOR    ${line}    IN    @{lines}
        IF    "Ethernet controller" in ${line}
            ${is_bus_line}=    Set Variable    True    False
        ELSE
            ${is_bus_line}=    Set Variable    ${None}
        END
        IF    ${is_bus_line}
            Set Global Variable    ${CURRENT_BUS}    ${line.split()[0]}
        END
        IF    "Device Serial Number" in ${line}
            ${is_serial_line}=    Set Variable    True    False
        ELSE
            ${is_serial_line}=    Set Variable    ${None}
        END
        IF    ${is_serial_line}
            ${mac}=    Extract MAC From Serial Line    ${line}
        END
        IF    ${is_serial_line}
            Set To Dictionary    ${pci_data}    ${CURRENT_BUS}    ${mac}
        END
    END
    RETURN    ${pci_data}

Extract MAC From Serial Line
    [Documentation]    Extracts MAC address from the lspci Device Serial Number line, ignoring FF bytes in the middle.
    [Arguments]    ${line}
    ${serial_number}=    Split String    ${line.split()[-1]}    -
    ${mac}=    Create List
    FOR    ${part}    IN    @{serial_number}
        Run Keyword Unless    "${part}" == "ff"    Append To List    ${mac}    ${part}
    END
    RETURN    ${':'.join(${mac})}

Sort Dictionary By Keys Reverse
    [Documentation]    Sorts dictionary by keys (PCIe bus numbers) in reverse order.
    [Arguments]    ${dictionary}
    ${keys}=    Get Dictionary Keys    ${dictionary}
    ${sorted_keys}=    Sort List    ${keys}    reverse=True
    ${sorted_dict}=    Create Dictionary
    FOR    ${key}    IN    @{sorted_keys}
        Set To Dictionary    ${sorted_dict}    ${key}    ${dictionary}[${key}]
    END
    RETURN    ${sorted_dict}

Verify MAC Order Reverse
    [Documentation]    Verifies that the MAC addresses are in reverse order of their PCIe bus numbers.
    [Arguments]    ${sorted_pci_data}
    ${prev_mac}=    None
    FOR    ${bus}    ${mac}    IN    &{sorted_pci_data}
        IF    ${prev_mac} != None
            Compare MAC Addresses    ${prev_mac}    ${mac}
        END
        Set Global Variable    ${PREV_MAC}    ${mac}
    END

Compare MAC Addresses
    [Documentation]    Compares two MAC addresses to ensure the previous one is higher (reverse order).
    [Arguments]    ${prev_mac}    ${current_mac}
    ${prev_mac_value}=    Convert MAC To Integer    ${prev_mac}
    ${current_mac_value}=    Convert MAC To Integer    ${current_mac}
    Should Be True    ${prev_mac_value} > ${current_mac_value}

Convert MAC To Integer
    [Documentation]    Converts a MAC address from string format to an integer for comparison.
    [Arguments]    ${mac}
    ${mac_parts}=    Split String    ${mac}    :
    ${mac_int}=    Evaluate    int(''.join(${mac_parts}), 16)
    RETURN    ${mac_int}
