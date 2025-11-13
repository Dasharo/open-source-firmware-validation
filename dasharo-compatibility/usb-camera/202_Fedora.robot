*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     CAM Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init CAM Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CAM001.202 Integrated webcam (Fedora)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
    Integrated Webcam Linux

CAM002.202 Integrated IR Camera (Fedora)
    [Documentation]    Check whether the integrated infrared camera is
    ...    initialized correctly and can be accessed from the Linux OS.
    ...    Assumption: No external camera connected. Camera exposes separate
    ...    devnodes for visible-spectrum and IR modes, in that order.
    Skip If    not ${IR_CAMERA_SUPPORT}    CAM002.202 not supported
    Integrated IR Camera Linux


*** Keywords ***
Init CAM Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
