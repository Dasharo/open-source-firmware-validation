*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     CAM Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init CAM Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
CAM001.201 Integrated webcam (Ubuntu)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
    ...    Previous IDs: CAM001.001
    Integrated Webcam Linux

CAM002.201 Integrated IR Camera (Ubuntu)
    [Documentation]    Check whether the integrated infrared camera is
    ...    initialized correctly and can be accessed from the Linux OS.
    ...    Assumption: No external camera connected. Camera exposes separate
    ...    devnodes for visible-spectrum and IR modes, in that order.
    ...    Previous IDs: CAM002.001
    Skip If    not ${IR_CAMERA_SUPPORT}    CAM002.201 not supported
    Integrated IR Camera Linux


*** Keywords ***
Init CAM Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
