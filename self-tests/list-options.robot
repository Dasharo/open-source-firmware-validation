*** Settings ***
Documentation       This suite verifies the correct operation of keywords
...                 getting and setting state of numerical options.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Get Current State Of List Option In ME Menu
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${state}=    Get Option State    ${me_menu}    Intel ME mode
    # Starts with capital letter, no extra trailing whitespaces
    Should Match Regexp    ${state}    ^[A-Z][\\w()\\s-]+\\S$

Parse Available Selections Of List Option In Me Menu
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    Enter Submenu From Snapshot    ${me_menu}    Intel ME mode
    ${out}=    Read From Terminal Until    ---/
    Log    ${out}
    ${opts}=    Extract Strings From Frame    ${out}
    Log    ${opts}
    Should Be Equal As Strings    ${opts}[0]    Enabled
    Should Be Equal As Strings    ${opts}[1]    Disabled (Soft)
    Should Be Equal As Strings    ${opts}[2]    Disabled (HAP)

Select Invalid State Of List Option In ME Menu
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${status}=    Run Keyword And Return Status
    ...    Set ME State    Fake State
    Should Not Be True    ${status}

Select State Of List Option In ME Menu (top-bottom)
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${me_states}=    Create List    Enabled    Disabled (Soft)    Disabled (HAP)
    FOR    ${state}    IN    @{me_states}
        Set ME State    ${state}
        Check ME State
    END

Select State Of List Option In ME Menu (bottom-top)
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${me_states}=    Create List    Disabled (HAP)    Disabled (Soft)    Enabled
    FOR    ${state}    IN    @{me_states}
        Set ME State    ${state}
        Check ME State
    END

# TODO: Current version of Get Option State kwd does not handle list options
# splitting into multiple lines

Get Current State Of List Option In Memory Menu
    [Documentation]    Checks whether the numerical option can be set.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    ${state}=    Get Option State    ${memory_menu}    Memory SPD Profile
    # Starts with capital letter, no extra trailing whitespaces
    Should Match Regexp    ${state}    ^[A-Z][\\w()\\s-]+\\S$

Parse Available Selections Of List Option In Memory Menu
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    Enter Submenu From Snapshot    ${memory_menu}    Memory SPD Profile
    ${out}=    Read From Terminal Until    ---/
    Log    ${out}
    ${opts}=    Extract Strings From Frame    ${out}
    Log    ${opts}
    Should Be Equal As Strings    ${opts}[0]    JEDEC (safe non-overclocked default)
    Should Be Equal As Strings    ${opts}[1]    XMP#1 (predefined extreme memory profile)
    Should Be Equal As Strings    ${opts}[2]    XMP#2 (predefined extreme memory profile)
    Should Be Equal As Strings    ${opts}[3]    XMP#3 (predefined extreme memory profile)


*** Keywords ***
Set ME State
    [Arguments]    ${state}
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    Set Option State    ${me_menu}    Intel ME mode    ${state}
    Save Changes And Reset    2    4

Check ME State
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${me_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Intel Management Engine Options
    ${state}=    Get Option State    ${me_menu}    Intel ME mode
    Should Be Equal    ${state}    ${state}
    Save Changes And Reset    2    4
