*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
CAM001.001 USB Camera (Ubuntu 22.04)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS.
    Skip If    not ${usb_camera_detection_support}    CAM001.001 not supportedfi
    Skip If    not ${tests_in_ubuntu_support}    CAM001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Detect or Install Package    ffmpeg
    Detect or Install Package    libinput-tools
    Device detection in Linux    Camera
    ${out0}=    Execute Linux command    ffprobe /dev/video0
    ${out2}=    Execute Linux command    ffprobe /dev/video2
    Should Contain    ${out0}    Input #0, video4linux2,v4l2, from '/dev/video0':
    Should Contain
    ...    ${out0}
    ...    Stream #0:0: Video: rawvideo (YUY2 / 0x32595559), yuyv422, 640x480, 147456 kb/s, 30 fps, 30 tbr, 1000k tbn, 1000k tbc
    Should Contain    ${out2}    Input #0, video4linux2,v4l2, from '/dev/video2':
    Should Contain
    ...    ${out2}
    ...    Stream #0:0: Video: rawvideo (Y800 / 0x30303859), gray, 640x360, 55296 kb/s, 30 fps, 30 tbr, 1000k tbn, 1000k tbc
    Exit from root user

CAM001.002 USB Camera (Windows 11)
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Windows OS.
    Skip If    not ${usb_camera_detection_support}    CAM001.002 not supported
    Skip If    not ${tests_in_windows_support}    CAM001.002 not supported
    Power On
    Login to Windows
    ${out}=    Get USB Devices Windows
    Should Contain    ${out}    Chicony USB2.0 Camera
