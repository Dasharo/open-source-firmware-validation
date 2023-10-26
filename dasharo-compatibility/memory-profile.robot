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
Resource            ../lib/bios/menus.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggests (not
#    exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
MPS001.001 Switching to XMP profile
    [Documentation]    XMP DRAM profiles have higher memory frequencies and/or
    ...    timings and are often necessary to get sticks to perform as
    ...    advertised by its manufacturer. Enabling such profile should keep
    ...    the system operational and change memory speed to a higher one.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MPS001.001 not supported
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    # Training 32 GiB of DDR5 takes longer than 3 minutes
    Telnet.Set Timeout    5 min
    # Boot and remember current memory speed
    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${old_speed}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${old_speed}
    # Switch profile and reset
    ${setup_menu}=    Parse Menu Snapshot Into Construction    ${out}    3    1
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    ${current_profile}=    Get Option State    ${memory_menu}    Memory SPD Profile
    Should Start With    ${current_profile}    JEDEC
    Set Option State    ${memory_menu}    Memory SPD Profile    XMP#1 (predefined
    Save Changes And Reset    2    4
    # Verify that frequency has changed
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${new_speed}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${new_speed}
    Should Not Be Equal    ${old_speed}    ${new_speed}

MPS002.001 Switching back to JEDEC profile
    [Documentation]    JEDEC profile is a safe default for memory configuration.
    ...    We should be able to select it again.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    MPS002.001 not supported
    Skip If    not ${MEMORY_PROFILE_SUPPORT}
    # Boot and remember current memory speed
    Power On
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${old_speed}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${old_speed}
    # Switch profile and reset
    ${setup_menu}=    Parse Menu Snapshot Into Construction    ${out}    3    1
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${memory_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Memory Configuration
    ${current_profile}=    Get Option State    ${memory_menu}    Memory SPD Profile
    Should Start With    ${current_profile}    XMP#1
    Set Option State    ${memory_menu}    Memory SPD Profile    JEDEC (safe
    Save Changes And Reset    2    4
    # Verify that frequency has changed
    Enter Setup Menu Tianocore
    ${out}=    Read From Terminal Until    <Enter>=Select Entry
    ${new_speed}=    Get Lines Matching Regexp    ${out}    .*RAM @ \\d+ MHz.*
    Should Not Be Empty    ${new_speed}
    Should Not Be Equal    ${old_speed}    ${new_speed}
