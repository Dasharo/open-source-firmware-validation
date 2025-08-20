*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${INTEL_CBNT_SUPPORT}    Intel CBnT not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
BGSM001.201 Setup Menu BtG info
    [Documentation]    Check whether setting Auto Boot Time-out to 7 the value
    ...    is remembered after restart
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}

    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_system_features_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${submenu}=    Enter Dasharo Submenu    ${dasharo_system_features_menu}    Intel Management Engine Options

    VAR    ${s_acm_success}=    ${False}
    VAR    ${cpu_debug}=    ${False}
    VAR    ${bsp_init}=    ${False}
    VAR    ${reg_cont}=    ${False}
    VAR    ${nem_enabled}=    ${False}
    VAR    ${tpm_success}=    ${False}
    VAR    ${measured_boot}=    ${False}
    VAR    ${verified_boot}=    ${False}
    VAR    ${boot_guard}=    ${False}
    VAR    ${dma_protection}=    ${False}
    Write Bare Into Terminal    ${ARROW_UP}    # this is necessary to unlock next keyword for good
    FOR    ${i}    IN RANGE    0    45
        ${submenu}=    Get Submenu Construction
        Match BtG Option State    ${submenu}    S-ACM Startup Success <Yes>    s_acm_success
        Match BtG Option State    ${submenu}    CPU Debugging    cpu_debug    Boot Policy: Disable <Yes>
        Match BtG Option State    ${submenu}    BSP #INIT    bsp_init    Boot Policy: Protected <Yes>
        Match BtG Option State    ${submenu}    Register Contents <No>    reg_cont    Valid
        Match BtG Option State    ${submenu}    DMA Protection <Yes>    dma_protection
        Match BtG Option State    ${submenu}    TPM Success <Yes>    tpm_success
        Match BtG Option State    ${submenu}    NEM Enabled <Yes>    nem_enabled
        Match BtG Option State    ${submenu}    Verified Boot <Yes>    verified_boot

        Write Bare Into Terminal    ${ARROW_DOWN}
        Sleep    1s
    END

    ${all_found}=    Evaluate
    ...    ${s_acm_success} and ${cpu_debug} and ${bsp_init} and ${reg_cont} and ${tpm_success} and ${dma_protection} and ${nem_enabled} and ${verified_boot}
    # Final verification
    Log To Console    \n===== Results =====
    Log To Console    S-ACM Startup Success: ${s_acm_success}
    Log To Console    CPU Debugging (Boot Policy: Disable <Yes>): ${cpu_debug}
    Log To Console    BSP #INIT (Boot Policy: Disable <Yes>): ${bsp_init}
    Log To Console    Register Contents Valid: ${reg_cont}
    Log To Console    DMA Protection <Yes>: ${dma_protection}
    Log To Console    TPM Success <Yes>: ${tpm_success}
    Log To Console    NEM Enabled <Yes>: ${nem_enabled}
    Log To Console    Verified Boot <Yes>: ${verified_boot}
    Log To Console    =====================
    Should Be True    ${all_found}


*** Keywords ***
Match BtG Option State
    [Arguments]    ${submenu}    ${wanted_option}    ${varname}    ${second_option}=None
    VAR    ${final_match}=    ${False}

    ${index1}=    Get Index From List    ${submenu}    ${wanted_option}
    IF    ${index1} != -1
        IF    '${second_option}' != 'None'
            ${index2}=    Evaluate    ${index1} + 1
            IF    ${index2} < len(${submenu})
                ${final_match}=    Run Keyword And Return Status
                ...    Should Contain
                ...    '${submenu}[${index2}]'
                ...    '${second_option}'
            END
        ELSE
            VAR    ${final_match}=    ${True}
        END
    END

    IF    ${final_match}
        VAR    ${${varname}}=    ${True}    scope=TEST
    END
