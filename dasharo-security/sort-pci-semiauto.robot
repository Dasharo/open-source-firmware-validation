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
SPS001.001 Ethernet ports are in order
    [Documentation]    This test automates the verification of port order based
    ...    on PCIe bus numbers and checks PCIe switching.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${pci_devices}=    Get PCIe Bus Info With MACs
    Log    PCIe devices and their MACs: ${pci_devices}
    Compare Interface And PCIe Bus Order    ${pci_devices}


*** Keywords ***
Get PCIe Bus Info With MACs
    [Documentation]    Extract PCIe bus numbers and MAC addresses from lspci output.
    ${lspci_output}=    Execute Command In Terminal    lspci -vv
    ${lines}=    Split String    ${lspci_output}    \n
    ${pci_devices}=    Create List
    FOR    ${line}    IN    @{lines}
        ${is_mac_line}=    Evaluate    'Device Serial Number' in '${line}'
        IF    ${is_mac_line}    Append PCIe MAC    ${line}    ${pci_devices}
    END
    RETURN    ${pci_devices}

Append PCIe MAC
    [Arguments]    ${line}    ${pci_devices}
    ${serial}=    Evaluate    '${line}'.split()[-1]
    ${mac}=    Replace String    ${serial}    ff-ff-    ${EMPTY}
    IF    '00-00-00-00-00-00' not in '${mac}'
        Append To List    ${pci_devices}    ${mac}
    END

Compare Interface And PCIe Bus Order
    [Arguments]    ${pci_devices}
    Log    Sorted interfaces: ${ETH_PORTS}
    Log    Sorted PCIe devices: ${pci_devices}
    Should Be Equal As Strings
    ...    ${ETH_PORTS}
    ...    ${pci_devices}
    ...    The interfaces and PCIe buses do not match the expected order!
