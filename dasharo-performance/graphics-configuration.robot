*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../keywords.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
DGPU001.001 Hybrid Graphics modes: NVIDIA Optimus
    [Documentation]    Verifies that the internal display is connected to the
    ...    integrated GPU (iGPU) while both iGPU and dGPU are active in Ubuntu.

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Set UEFI Option    DGPUEnabled    NVIDIA Optimus
    Power Cycle Into Ubuntu
    Switch To Root User

    ${dgpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${dgpu_status}    NVIDIA    msg= "dGPU is not detected."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Contain    ${igpu_status}    Graphics    msg= "iGPU is not detected."

    ${igpu_display_status}=    Execute Command In Terminal    cat /sys/class/drm/card1-eDP-1/enabled
    Should Contain    ${igpu_display_status}    enabled    msg= "iGPU is not driving the internal display."

    ${dgpu_display_status}=    Execute Command In Terminal    cat /sys/class/drm/card2-eDP-1/enabled
    Should Contain    ${dgpu_display_status}    disabled    msg= "dGPU is incorrectly driving the internal display."

    Log To Console    Internal display is connected to iGPU, and both iGPU and dGPU are active.

DGPU002.001 Hybrid Graphics modes: dGPU Only
    [Documentation]    Verifies that the internal display is connected to the discrete GPU (dGPU) while the integrated GPU (iGPU) is still active.

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Set UEFI Option    DGPUEnabled    dGPU Only
    Power Cycle Into Ubuntu
    Switch To Root User

    ${dgpu_status}=    Execute Command In Terminal    cat /sys/class/drm/card2-eDP-1/enabled
    Should Contain    ${dgpu_status}    enabled    msg= "dGPU is not driving the internal display."

    ${igpu_status}=    Execute Command In Terminal    cat /sys/class/drm/card1-eDP-1/enabled
    Should Contain    ${igpu_status}    disabled    msg= "iGPU is still driving the internal display."

    Log To Console    Internal display is connected to dGPU

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
