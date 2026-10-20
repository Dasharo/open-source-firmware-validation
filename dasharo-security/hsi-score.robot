*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu not supported
...                     AND
...                     Prepare HSI Score Tests
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${HSI_CMD_START}=       fwupdmgr security | sed 's/\\x1b\\[[0-9;]*m//g' |
...                     awk -v want="
${HSI_CMD_END}=         " '/^HSI-[0-9]+/ || /^Runtime Suffix/
...                     { intier = (index($0, want) == 1); next }
...                     intier && /^✔/ { pass++ }
...                     intier && /^✘/ { fail++ }
...                     END { printf "%s pass: %d fail: %d\\n",
...                     want, pass+0, fail+0 }'


*** Test Cases ***
HSI001.201 HSI-1 security tier (Ubuntu)
    [Documentation]    Tests if DUT complies with HSI-1 security level
    Check HSI Score For Tier    HSI-1

HSI002.201 HSI-2 security tier (Ubuntu)
    [Documentation]    Tests if DUT complies with HSI-2 security level
    Check HSI Score For Tier    HSI-2

HSI003.201 HSI-3 security tier (Ubuntu)
    [Documentation]    Tests if DUT complies with HSI-3 security level
    Check HSI Score For Tier    HSI-3

HSI004.201 HSI-4 security tier (Ubuntu)
    [Documentation]    Tests if DUT complies with HSI-4 security level
    Check HSI Score For Tier    HSI-4


*** Keywords ***
Prepare HSI Score Tests
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

Get HSI Section For Tier
    [Documentation]    Returns the part of the log produced by `fwupdmgr security`
    ...    corresponding to a specified HSI tier
    [Arguments]    ${tier}
    # Get the output from fwupdmgr security
    ${output}=    Execute Command In Terminal
    ...    echo n | fwupdmgr security | sed 's/\x1b\[[0-9;]*m//g; s/✔/PASS/; s/✘/FAIL/'

    # Get the section corresponding to HSI tier specified
    ${tier_re}=    Regexp Escape    ${tier}
    VAR    ${pattern}=    (?ms)^${tier_re}\[^\\n]*\\n(.*?)(?:\\n\\s*\\n|\\Z)
    ${matches}=    Get Regexp Matches    ${output}    ${pattern}    1
    Should Not Be Empty    ${matches}    Tier '${tier}' not found
    ${section}=    Remove String    ${matches}[0]    \r
    ${section}=    Replace String    ${section}    PASS    \x1b[32mPASS\x1b[0m
    ${section}=    Replace String    ${section}    FAIL    \x1b[31mFAIL\x1b[0m
    RETURN    ${section}

Check HSI Score For Tier
    [Documentation]    Returns number of passes and fails for a certain HSI tier
    [Arguments]    ${tier}
    ${score}=    Execute Command In Terminal    ${HSI_CMD_START}${tier}${HSI_CMD_END}
    ${score}=    Fetch From Right    ${score}    \n
    ${score_log}=    Get HSI Section For Tier    ${tier}
    Should Contain    ${score}    fail: 0    msg=Log:\n${score_log}\n
