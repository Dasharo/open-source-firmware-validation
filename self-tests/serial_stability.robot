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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
Traditional Serial
    VAR    ${TELNET_FUZZY_MAX_ERRORS}=    0    scope=GLOBAL
    VAR    ${failed}=    ${FALSE}
    FOR    ${i}    IN RANGE    10
        ${st}=    Run Keyword And Return Status    Test
        IF    $st
            Log To Console    PASS
        ELSE
            Log To Console    FAIL
            VAR    ${failed}=    ${TRUE}
        END
    END
    Should Not Be True    $failed

Fuzzy Serial
    VAR    ${TELNET_FUZZY_MAX_ERRORS}=    1    scope=GLOBAL
    VAR    ${failed}=    ${FALSE}
    FOR    ${i}    IN RANGE    10
        ${st}=    Run Keyword And Return Status    Test Fuzzy
        IF    $st
            Log To Console    PASS
        ELSE
            Log To Console    FAIL
            VAR    ${failed}=    ${TRUE}
        END
    END
    Should Not Be True    $failed


*** Keywords ***
Test
    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    List Should Contain Value    ${menu}    > User Password Management
    List Should Contain Value    ${menu}    > Device Manager
    List Should Contain Value    ${menu}    > Dasharo System Features
    List Should Contain Value    ${menu}    > One Time Boot
    List Should Contain Value    ${menu}    > Boot Maintenance Manager
    ${menu}=    Enter Dasharo System Features    ${menu}
    List Should Contain Value    ${menu}    > Dasharo Security Options
    List Should Contain Value    ${menu}    > Networking Options
    List Should Contain Value    ${menu}    > USB Configuration
    List Should Contain Value    ${menu}    > Intel Management Engine Options
    List Should Contain Value    ${menu}    > Power Management Options
    List Should Contain Value    ${menu}    > Serial Port Configuration

Test Fuzzy
    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    List Should Contain Value Fuzzy    ${menu}    > User Password Management    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Device Manager    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Dasharo System Features    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > One Time Boot    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Boot Maintenance Manager    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    ${menu}=    Enter Dasharo System Features    ${menu}
    List Should Contain Value Fuzzy    ${menu}    > Dasharo Security Options    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Networking Options    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > USB Configuration    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy
    ...    ${menu}
    ...    > Intel Management Engine Options
    ...    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Power Management Options    max_errors=${TELNET_FUZZY_MAX_ERRORS}
    List Should Contain Value Fuzzy    ${menu}    > Serial Port Configuration    max_errors=${TELNET_FUZZY_MAX_ERRORS}
