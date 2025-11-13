*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     ECR Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
ECR001.301 Battery monitoring - charge level in OS (Windows)
    [Documentation]    Check whether battery charge level can be read in
    ...    Windows OS.
    ...    Previous IDs: ECR001.002
    Power On
    Login To Windows
    ${out}=    Get Battery Power Level Windows
    Should Be True    ${out} > 0 and ${out} < 101
    Execute Shutdown Command

ECR002.301 Battery monitoring - charging state in OS (Windows)
    [Documentation]    Check whether the battery state can be read in Windows
    ...    OS.
    ...    Previous IDs: ECR002.002
    Power On
    Login To Windows
    Check If Battery Is Charging Windows
    Execute Shutdown Command

ECR003.301 Touchpad in OS - (Windows)
    [Documentation]    Check whether touchpad is visible in Windows OS.
    ...    Touchpad steering and effect detection must be checked
    ...    manually.
    ...    Previous IDs: ECR003.002
    Power On
    Login To Windows
    ${out}=    Get Pointing Devices Windows
    Should Contain    ${out}    HID-compliant mouse
    Execute Shutdown Command
