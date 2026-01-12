*** Settings ***
Documentation       GPU header for OSFV Performance Library

Library             Dialogs
Resource            common.robot


*** Keywords ***
Run Unigine Superposition On Ubuntu
    [Documentation]    Wrapper for PTS. Run suite, gather and process
    ...    results. It assumes DUT is logged in into regular user
    ...    account on Ubuntu
    [Arguments]    ${test_run_name}=gpu_test${CURRENT_DATE}

    # Required for graphical benchmarking over ssh
    Execute Manual Step    Please ensure DUT has active desktop session
    ...    by logging into Gnome Desktop.
    VAR    ${cmd}=    DISPLAY=:1

    IF    ${NVIDIA_GRAPHICS_CARD_SUPPORT}
        VAR    ${cmd}=    ${cmd}
        ...    __GLX_VENDOR_LIBRARY_NAME=nvidia __NV_PRIME_RENDER_OFFLOAD=1    separator=${SPACE}
        ...    __VK_LAYER_NV_optimus=NVIDIA_only
        ...    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
        ...    separator=${SPACE}
    END

    VAR    ${cmd}=    ${cmd}    phoronix-test-suite batch-run    separator=${SPACE}
    VAR    ${cmd}=    ${cmd}    unigine-super RESULT_NAME=${test_run_name}    separator=${SPACE}

    Write Into Terminal    ${cmd}
    # Test options
    Read From Terminal Until    Resolution:
    # 1: 800 x 600 2: 1024 x 768 3: 1280 x 1024
    # 4: 1600 x 1200 5: 1920 x 1080 6: 1920 x 1200
    Write Into Terminal    5    # Full HD 1920 x 1080
    Read From Terminal Until    Mode:
    # 1 : Fullscreen 2: Windowed
    Write Into Terminal    2    # Test in-window performance
    Read From Terminal Until    Quality:
    # 1: Low 2: Medium 3: High 4: Ultra
    Write Into Terminal    2    # Medium preset
    # Test takes around 11 minutes, but will repeat runs if deviation is too high,
    # therefore we give almost 3x that time to ensure it has enough to rerun
    Set DUT Response Timeout    1800
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    Average:
    ...    Benchmark did not produce results
    ${lines}=    Split String    ${out}    \n
    FOR    ${line}    IN    @{lines}
        IF    '''Average''' in '''${line}'''
            ${parts}=    Split String    ${line}
            ${value}=    Get From List    ${parts}    1
            RETURN    ${value}
        END
    END
    Fail    Could not acquire results
