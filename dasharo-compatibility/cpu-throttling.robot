*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=300 seconds
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
...                     Skip If    not ${CPU_THROTTLING_SUPPORT}    CPU throttling tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
THR001.001 Try to enter a threshold value that's above the limit
    [Documentation]    Verify that a threshold value that's above the limit
    ...    will get rejected with a proper prompt
    Skip If    not "${OPTIONS_LIB}" == "uefi-setup-menu"
    # According to Intel datasheets, the throttling temperature must be within
    # {TjMax; TjMax - 63}
    Set UEFI Option    CpuThrottlingThreshold    200
    Save Changes
    Read From Terminal Until    error
    Write Bare Into Terminal    c
    Read From Terminal Until    TjMax

THR001.002 Try to enter a threshold value that's below the limit
    [Documentation]    Verify that a threshold value that's below the limit
    ...    will get rejected with a proper prompt
    Skip If    not "${OPTIONS_LIB}" == "uefi-setup-menu"
    Set UEFI Option    CpuThrottlingThreshold    10
    Save Changes
    Read From Terminal Until    error
    Write Bare Into Terminal    c
    Read From Terminal Until    TjMax

THR002.001 Try to enter a threshold value within the limits and verify in Ubuntu
    [Documentation]    Verify whether a reasonable throttling threshold will
    ...    take effect in Ubuntu
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    THR002.001 not supported
    Set UEFI Option    CpuThrottlingThreshold    70
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Stress Test
    # Wait until the stress load gets to "heat up" the CPU
    Sleep    10
    ${out}=    Execute Command In Terminal    sensors
    ${temperature}=    Get CPU Temperature CURRENT
    Should Be True    ${temperature} < 73    # needs a bit of a margin
