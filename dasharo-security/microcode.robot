*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../variables.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UCODE001.201 Check if firmware runs on expected microcode revision
    [Documentation]    This test checks if firmware microcode revision matches
    ...    expected value.
    [Tags]    automated    minimal-regression
    Depends On    ${MICROCODE_REVISIONS} != @{EMPTY}    UCODE001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out_cbmem}=    Execute Command In Terminal    cbmem -1 | grep -E "microcode.*revision="
    VAR    ${match_found}=    ${False}
    FOR    ${ucode_rev}    IN    @{MICROCODE_REVISIONS}
        ${match_found}=    Run Keyword And Return Status
        ...    Should Contain    ${out_cbmem}    revision=${ucode_rev}
        IF    ${match_found}    BREAK
    END

    Should Be True    ${match_found}    "Platform does not run on expected microcode revision"
