*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for USB camera tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
CAM Suite Setup
    [Documentation]    Common suite setup for USB camera tests
    Prepare Test Suite
    Skip If    not ${USB_CAMERA_DETECTION_SUPPORT}    USB Camera detection tests not supported

Integrated Webcam Linux
    [Documentation]    Check whether the integrated USB camera is initialized
    ...    correctly and can be accessed from the Linux OS. Assumption: No
    ...    external cameras connected.
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
    ${out}=    List Devices In Linux    usb
    Should Contain Any    ${out}    Camera    BisonCam
    ${out0}=    Execute Linux Command    ffprobe /dev/video2
    Should Contain
    ...    ${out0}
    ...    Stream #0:0: Video: rawvideo (Y800 / 0x30303859), gray
