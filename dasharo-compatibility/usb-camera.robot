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
...                     AND
...                     Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    USB Camera detection tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CAM001.201 Integrated webcam (Ubuntu)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
    ...    Previous IDs: CAM001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CAM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CAM001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Integrated Webcam Linux
    Exit From Root User

CAM002.201 Integrated IR Camera (Ubuntu)
    [Documentation]    Check whether the integrated infrared camera is
    ...    initialized correctly and can be accessed from the Linux OS.
    ...    Assumption: No external camera connected. Camera exposes separate
    ...    devnodes for visible-spectrum and IR modes, in that order.
    ...    Previous IDs: CAM002.001
    Skip If    not ${IR_CAMERA_SUPPORT}    CAM002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CAM002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    CAM002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Integrated IR Camera Linux
    Exit From Root User

CAM001.202 Integrated webcam (Fedora)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CAM001.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Integrated Webcam Linux
    Exit From Root User

CAM002.202 Integrated IR Camera (Fedora)
    [Documentation]    Check whether the integrated infrared camera is
    ...    initialized correctly and can be accessed from the Linux OS.
    ...    Assumption: No external camera connected. Camera exposes separate
    ...    devnodes for visible-spectrum and IR modes, in that order.
    Skip If    not ${IR_CAMERA_SUPPORT}    CAM002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    CAM002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Integrated IR Camera Linux
    Exit From Root User

CAM001.301 Integrated webcam (Windows)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Windows OS.
    ...    Previous IDs: CAM001.002
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CAM001.301 not supported
    Power On
    Login To Windows
    ${out}=    Get USB Devices Windows
    Should Contain    ${out}    Chicony USB2.0 Camera


*** Keywords ***
Integrated Webcam Linux
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
    [Tags]    robot:private
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam
    ${out0}=    Execute Linux Command    ffprobe /dev/video0
    Should Contain    ${out0}    Input #0, video4linux2,v4l2, from '/dev/video0':
    Should Contain
    ...    ${out0}
    ...    Stream #0:0: Video: rawvideo (YUY2 / 0x32595559), yuyv422

Integrated IR Camera Linux
    [Documentation]    Check whether the integrated infrared camera is
    ...    initialized correctly and can be accessed from the Linux OS.
    ...    Assumption: No external camera connected. Camera exposes separate
    ...    devnodes for visible-spectrum and IR modes, in that order.
    [Tags]    robot:private
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam
    ${out0}=    Execute Linux Command    ffprobe /dev/video2
    Should Contain
    ...    ${out0}
    ...    Stream #0:0: Video: rawvideo (Y800 / 0x30303859), gray
