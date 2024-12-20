*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SPS001.001 Ethernet ports are in order
    [Documentation]    This test automates the verification of port order based
    ...    on PCIe bus numbers and checks PCIe switching.
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${pci_devices}=    Get MACs
    Log    PCIe devices and their MACs: ${pci_devices}
    Compare Interfaces    ${pci_devices}


*** Keywords ***
Get PCIe
    ${lspci_output}=    Execute Command In Terminal    lspci -nn |grep "${ETHERNET_ID}"
    @{lines}=    Split String    ${lspci_output}    \n
    ${ethernet_devs}=    Create List
    FOR    ${line}    IN    @{lines}
        ${dev}=    Evaluate    '${line}'.split()[0]
        Append To List    ${ethernet_devs}    ${dev}
    END
    RETURN    ${ethernet_devs}

Get MACs
    [Documentation]    Extract MAC addresses from lspci output.
    ${ethernet_devs}=    Get PCIe
    ${pci_devices}=    Create List
    FOR    ${dev}    IN    @{ethernet_devs}
        ${lspci_output}=    Execute Command In Terminal    lspci -s ${dev} -v |grep "Device Serial"
        Append PCIe MAC    ${lspci_output}    ${pci_devices}
    END
    RETURN    ${pci_devices}

Append PCIe MAC
    [Arguments]    ${line}    ${pci_devices}
    ${serial}=    Evaluate    '${line}'.split()[-1]
    ${mac}=    Replace String    ${serial}    ff-ff-    ${EMPTY}
    IF    '00-00-00-00-00-00' not in '${mac}'
        Append To List    ${pci_devices}    ${mac}
    END

Compare Interfaces
    [Arguments]    ${pci_devices}
    Log    ${ETH_PORTS}
    Log    ${pci_devices}
    Should Be Equal As Strings
    ...    ${ETH_PORTS}
    ...    ${pci_devices}
    ...    The interfaces and PCIe buses do not match the expected order!
