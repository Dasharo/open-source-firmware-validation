*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../keywords.robot
Resource            ../lib/performance/common.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DGPU001.001 Hybrid Graphics modes: NVIDIA Optimus
    [Documentation]    Verifies that the internal display is connected to the integrated GPU (iGPU) while both iGPU and dGPU are active in Ubuntu.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}
    Set UEFI Option    DGPUState    NVIDIA Optimus
    Power Cycle Into Ubuntu
    Switch To Root User

    ${dgpu_card}    ${igpu_card}=    Get GPU Cards

    ${igpu_display}=    Execute Command In Terminal    ls /sys/class/drm/${igpu_card}-eDP* 2>/dev/null
    ${dgpu_display}=    Execute Command In Terminal    ls /sys/class/drm/${dgpu_card}-eDP* 2>/dev/null

    IF    '${igpu_display}'
        ${igpu_display_status}=    Execute Command In Terminal    cat /sys/class/drm/${igpu_card}-eDP*/enabled
        # sometimes if the directory deos not exist it repeats back the typed command
        # i. e. cat /sys/class/drm/${igpu_card}-eDP*/enabled with enabled at the end, resulting in a false positive
        Should Not Contain    ${igpu_display_status}    cat    msg= "iGPU is not driving the internal display."
        Should Contain    ${igpu_display_status}    enabled    msg= "iGPU is not driving the internal display."
    ELSE
        Fail    msg= "No internal display found for iGPU."
    END

    IF    '${dgpu_display}'
        ${dgpu_display_status}=    Execute Command In Terminal    cat /sys/class/drm/${dgpu_card}-eDP*/enabled
        Should Not Contain    ${dgpu_display_status}    cat    msg= "dGPU is not driving the internal display."
        Should Contain
        ...    ${dgpu_display_status}
        ...    disabled
        ...    msg= "dGPU is incorrectly driving the internal display."
    ELSE
        Log To Console    "No internal display found for dGPU."
    END

    # also including the original logic to be extra sure
    ${dgpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Contain    ${dgpu_status}    VGA    msg= "dGPU is not detected."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Contain    ${igpu_status}    VGA    msg= "iGPU is not detected."

    Log To Console    Internal display is connected to iGPU, and both iGPU and dGPU are active.

DGPU002.001 Hybrid Graphics modes: dGPU Only
    [Documentation]    Verifies that the internal display is connected to the discrete GPU (dGPU) while the integrated GPU (iGPU) is still active.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}
    Skip If    not ${DGPU_ONLY_SUPPORT}
    Set UEFI Option    DGPUState    dGPU Only
    Power Cycle Into Ubuntu
    Switch To Root User

    ${dgpu_card}    ${igpu_card}=    Get GPU Cards

    ${dgpu_display}=    Execute Command In Terminal    ls /sys/class/drm/${dgpu_card}-eDP* 2>/dev/null
    ${igpu_display}=    Execute Command In Terminal    ls /sys/class/drm/${igpu_card}-eDP* 2>/dev/null

    IF    '${dgpu_display}'
        ${dgpu_status}=    Execute Command In Terminal    cat /sys/class/drm/${dgpu_card}-eDP*/enabled
        Should Not Contain    ${dgpu_status}    cat    msg= "iGPU is not driving the internal display."
        Should Contain    ${dgpu_status}    enabled    msg= "dGPU is not driving the internal display."
    ELSE
        Fail    msg= "No internal display found for dGPU."
    END

    IF    '${igpu_display}'
        ${igpu_status}=    Execute Command In Terminal    cat /sys/class/drm/${igpu_card}-eDP*/enabled
        Should Not Contain    ${igpu_status}    cat    msg= "iGPU is not driving the internal display."
        Should Contain    ${igpu_status}    disabled    msg= "iGPU is still driving the internal display."
    ELSE
        Log To Console    "No internal display found for iGPU. Skipping check."
    END

    Log To Console    Internal display is connected to dGPU

DGPU003.001 Hybrid Graphics modes: iGPU Only
    [Documentation]    Verifies that only the discrete GPU (dGPU) is turned off and the integrated GPU (iGPU) is active.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}
    Set UEFI Option    DGPUState    iGPU Only
    Power Cycle Into Ubuntu
    Switch To Root User
    ${gpu_status}=    Execute Command In Terminal    lspci | grep -i nvidia
    Should Not Contain    ${gpu_status}    VGA    msg= "dGPU is still active."

    ${igpu_status}=    Execute Command In Terminal    lspci | grep -i 'intel'
    Should Contain    ${igpu_status}    VGA    msg= "iGPU is not detected."

    Log To Console    Only iGPU is active, and dGPU is turned off.


*** Keywords ***
Get GPU Cards
    ${gpu_cards_raw}=    Execute Command In Terminal
    ...    ls -d /sys/class/drm/card[0-9]*/device/vendor | awk -F'/' '{print $(NF-2)}'
    ${gpu_cards}=    Split String    ${gpu_cards_raw}
    VAR    ${dgpu_card}=    nocard
    VAR    ${igpu_card}=    nocard

    FOR    ${card}    IN    @{gpu_cards}
        ${vendor}=    Execute Command In Terminal    cat /sys/class/drm/${card}/device/vendor
        ${vendor}=    Strip String    ${vendor}
        IF    '${vendor}' == '0x10de'
            VAR    ${dgpu_card}=    ${card}
        ELSE IF    '${vendor}' == '0x8086'
            VAR    ${igpu_card}=    ${card}
        END
    END

    RETURN    ${dgpu_card}    ${igpu_card}
