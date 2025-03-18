*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../keywords.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
DGPU001.001 Check If dGPU Is Turned On
    [Documentation]    Verifies if the discrete GPU (dGPU) is turned on in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Switch To Root User

    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${gpu_status}    NVIDIA    msg= "dGPU is not detected."

    ${active_gpu}=    Execute Command In Terminal    cat /sys/class/drm/card*/device/power/control
    Should Contain    ${active_gpu}    on    msg= "dGPU is not turned on."

    Log    dGPU is active and turned on.

DGPU002.001 Hybrid Graphics mode dGPU Only
    [Documentation]    Verifies that only the discrete GPU (dGPU) is active and the integrated GPU (iGPU) is turned off.

    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    Switch To Root User
    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${gpu_status}    NVIDIA    msg= "dGPU is not detected."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Not Contain    ${igpu_status}    Graphics    msg= "iGPU is still active."

    Log    Only dGPU is active, and iGPU is turned off.


*** Keywords ***
Power Cycle Into Ubuntu
    Power On
    Boot System Or From Connected Disk    201
    Login To Linux
