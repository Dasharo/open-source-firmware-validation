*** Settings ***
Library         Collections
Library         String
Library         ./PlatformParser.py
Resource        ../lib/dts-lib.robot

Suite Setup     Prepare DTS E2E Test Suite
# Doesn't require qemu to run, can be used for quick debugging
# To print all exports for all tests:
# `robot -t "*all platforms" dts/dts-e2e-helper.robot`


*** Test Cases ***
E2EH001.001 Print names and exports of test cases to be generated for all platforms
    [Documentation]    Print out all generated tests along with used exports
    Log To Console    ${EMPTY}
    FOR    ${platform}    IN    @{DTS_PLATFORM_VARIABLES}
        Print Test Names And Exports    ${platform}
    END

E2EH002.001 Print names and exports of test cases to be generated for one platform
    [Documentation]    Print out all generated tests for one platform along with
    ...    used exports
    Log To Console    ${EMPTY}
    Print Test Names And Exports    ${CONFIG}

E2EH003.001 Print names of test cases to be generated
    [Documentation]    Print out names of all generated tests
    Log To Console    ${EMPTY}
    &{workflows}=    Get All Platforms Workflows
    FOR    ${platform}    ${platform_workflows}    IN    &{workflows}
        FOR    ${platform_workflow}    IN    @{platform_workflows}
            ${workflow}    ${release}=    Set Variable    @{platform_workflow}
            Log To Console    ${platform} ${workflow} - ${release}
        END
    END


*** Keywords ***
Print Test Names And Exports
    [Documentation]    Print tests generated for one platform and exports used
    ...    in this test
    [Arguments]    ${platform}
    VAR    ${platform_variables}=    ${DTS_PLATFORM_VARIABLES}[${platform}]
    @{workflows}=    Get Platform Workflows    ${platform}
    Log To Console    --------------------------------------------------
    Log To Console    ${platform}
    Log To Console    --------------------------------------------------
    FOR    ${platform_workflows}    IN    @{workflows}
        ${workflow}    ${release}=    Set Variable    ${platform_workflows}
        @{exports}=    Prepare Test Exports    ${workflow}    ${platform_variables}    ${DTS_CONFIG_REF}
        Log To Console    ---------------
        Log To Console    ${platform} ${workflow} - ${release}
        Log To Console    ---------------
        FOR    ${export}    IN    @{exports}
            Log To Console    ${export}
        END
    END

Get Platform Workflows
    [Arguments]    ${platform}
    VAR    ${platform_variables}=    ${DTS_PLATFORM_VARIABLES}[${platform}]
    VAR    @{workflows}=    @{EMPTY}
    FOR    ${workflow}    IN    @{platform_variables}[DTS_TEST_WORKFLOWS]
        FOR    ${release}    IN    @{platform_variables}[DTS_TEST_WORKFLOW_RELEASES][${workflow}]
            VAR    @{platform_workflow}=    ${workflow}    ${release}
            Append To List    ${workflows}    ${platform_workflow}
        END
    END
    RETURN    ${workflows}

Get All Platforms Workflows
    VAR    &{all_workflows}=    &{EMPTY}
    FOR    ${platform}    IN    @{DTS_PLATFORM_VARIABLES}
        @{platform_workflows}=    Get Platform Workflows    ${platform}
        Set To Dictionary    ${all_workflows}    ${platform}=${platform_workflows}
    END
    RETURN    ${all_workflows}

Prepare DTS E2E Test Suite
    &{dts_vars}=    Get DTS Test Variables
    VAR    ${DTS_PLATFORM_VARIABLES}=    ${dts_vars}    scope=SUITE
