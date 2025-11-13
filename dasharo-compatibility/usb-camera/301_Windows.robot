*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     CAM Suite Setup
...                     AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CAM001.301 Integrated webcam (Windows)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Windows OS.
    ...    Previous IDs: CAM001.002
    Power On
    Login To Windows
    ${out}=    Get USB Devices Windows
    Should Contain Any    ${out}    Camera    BisonCam
    Execute Shutdown Command
