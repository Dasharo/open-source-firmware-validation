*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../keywords.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
DGPU001.001 Hybrid Graphics modes: NVIDIA Optimus
    [Documentation]    Verifies if both the integrated and discrete GPUs (iGPU & dGPU) are turned on in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Set UEFI Option    DGPUEnabled    NVIDIA Optimus
    Power Cycle Into Ubuntu
    Switch To Root User

    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${gpu_status}    NVIDIA    msg= "dGPU is not detected."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Contain    ${igpu_status}    Graphics    msg= "iGPU is not detected."

    Log To Console    Both iGPU and dGPU are active and turned on.

DGPU002.001 Hybrid Graphics modes: dGPU Only
    [Documentation]    Verifies that only the discrete GPU (dGPU) is active and the integrated GPU (iGPU) is turned off.

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    # Set UEFI Option    Hybrid Graphics Mode    dGPU Only
    Power Cycle Into Ubuntu
    Switch To Root User
    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${gpu_status}    NVIDIA    msg= "dGPU is not detected."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Not Contain    ${igpu_status}    Graphics    msg= "iGPU is still active."

    Log To Console    Only dGPU is active, and iGPU is turned off.

DGPU003.001 Hybrid Graphics modes: iGPU Only
    [Documentation]    Verifies that only the discrete GPU (dGPU) is turned off and the integrated GPU (iGPU) is active.

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Set UEFI Option    DGPUEnabled    iGPU Only
    Power Cycle Into Ubuntu
    Switch To Root User
    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Not Contain    ${gpu_status}    NVIDIA    msg= "dGPU is still active."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Contain    ${igpu_status}    Graphics    msg= "iGPU is not detected."

    Log To Console    Only iGPU is active, and dGPU is turned off.


*** Keywords ***
Power Cycle Into Ubuntu
    Power On
    Boot System Or From Connected Disk    201
    Login To Linux
