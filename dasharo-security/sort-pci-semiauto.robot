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


*** Variables ***
${LSPCI_CMD}=       lspci -vv
${IP_LINK_CMD}=     ip link


*** Test Cases ***
Sort000.000 Port Order and PCIe Switching
    [Documentation]    This test automates the verification of port order based on PCIe bus numbers and checks PCIe switching.

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${interfaces}=    Get Interface MACs
    ${pci_devices}=    Get PCIe Bus Info With MACs
    Log    Interfaces and their MACs: ${interfaces}
    Log    PCIe devices and their MACs: ${pci_devices}
    Compare Interface And PCIe Bus Order    ${interfaces}    ${pci_devices}


*** Keywords ***
Get Interface MACs
    [Documentation]    Retrieves the list of network interfaces along with their MAC addresses.
    ${ip_output}=    Execute Command In Terminal    ${IP_LINK_CMD}
    ${lines}=    Split String    ${ip_output}    \n
    ${interfaces}=    Create Dictionary
    ${interface_loaded}=    Set Variable    False
    ${mac_loaded}=    Set Variable    False
    FOR    ${line}    IN    @{lines}
        ${is_interface_line}=    Evaluate    ':' in '${line}' and '<' in '${line}'
        IF    ${is_interface_line}
            ${line}=    Strip String    ${line}
            ${parts}=    Split String    ${line}    ' '
            ${interface}=    Evaluate    '${line}'.split(" ")[1].strip()
            ${interface_loaded}=    Set Variable    True
        END
        ${is_mac_line}=    Evaluate    ':' in '${line}' and 'link/ether' in '${line}'
        IF    ${is_mac_line}
            ${line}=    Strip String    ${line}
            ${line}=    Replace String    ${line}    :    -
            ${parts}=    Split String    ${line}    ' '
            ${mac}=    Evaluate    '${line}'.split(" ")[1].strip()
            ${mac_loaded}=    Set Variable    True
        END
        IF    ${mac_loaded} and ${interface_loaded}
            Set To Dictionary    ${interfaces}    ${interface}    ${mac}
            ${interface_loaded}=    Set Variable    False
            ${mac_loaded}=    Set Variable    False
        END
    END
    RETURN    ${interfaces}

Append Interface MAC
    [Arguments]    ${line}    ${interfaces}
    ${line}=    Strip String    ${line}
    ${line}=    Replace String    ${line}    :    -
    ${parts}=    Split String    ${line}    ' '
    ${mac}=    Evaluate    '${line}'.split(" ")[1].strip()
    IF    '${mac}' != ''    Set To Dictionary    ${interfaces}    ${mac}

Append Interface
    [Arguments]    ${line}    ${interfaces}
    ${line}=    Strip String    ${line}
    ${parts}=    Split String    ${line}    ' '
    ${interface}=    Evaluate    '${line}'.split(" ")[1].strip()
    IF    '${interface}' != ''
        Set To Dictionary    ${interfaces}    ${interface}
    END

Get PCIe Bus Info With MACs
    [Documentation]    Extract PCIe bus numbers and MAC addresses from lspci output.
    ${lspci_output}=    Execute Command In Terminal    ${LSPCI_CMD}
    ${lines}=    Split String    ${lspci_output}    \n
    ${pci_devices}=    Create Dictionary
    ${current_device}=    Set Variable    None
    FOR    ${line}    IN    @{lines}
        ${is_device_line}=    Evaluate    'Ethernet controller' in '${line}'
        IF    ${is_device_line}
            ${current_device}=    Get Device Bus Info    ${line}
        END
        ${is_mac_line}=    Evaluate    'Device Serial Number' in '${line}'
        IF    ${is_mac_line}
            Append PCIe MAC    ${line}    ${pci_devices}    ${current_device}
        END
    END
    RETURN    ${pci_devices}

Get Device Bus Info
    [Arguments]    ${line}
    ${bus}=    Evaluate    '${line}'.split()[0]
    RETURN    ${bus}

Append PCIe MAC
    [Arguments]    ${line}    ${pci_devices}    ${current_device}
    ${serial}=    Evaluate    '${line}'.split()[-1]
    ${mac}=    Replace String    ${serial}    ff-ff-    ${EMPTY}
    IF    '00-00-00-00-00-00' not in '${mac}'
        Set To Dictionary    ${pci_devices}    ${current_device}    ${mac}
    END

Compare Interface And PCIe Bus Order
    [Arguments]    ${interfaces}    ${pci_devices}
    ${interfaces_val}=    Get Dictionary Values    ${interfaces}
    ${pci_devices_val}=    Get Dictionary Values    ${pci_devices}
    Log    Sorted interfaces: ${interfaces_val}
    Log    Sorted PCIe devices: ${pci_devices_val}
    Should Be Equal As Strings
    ...    ${interfaces_val}
    ...    ${pci_devices_val}
    ...    The interfaces and PCIe buses do not match the expected order!
