*** Settings ***
Documentation       File that contains commonly used libraries, and resources

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot


*** Keywords ***
Power On Default
    [Documentation]    Keyword clears terminal buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    Rte Power Off
    Sleep    10s
    Read From Terminal
    Power Cycle On

Power Cycle Into Ubuntu
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux

Power Cycle Into Windows
    Power Cycle On
    Login To Windows

Power Cycle Into Firmware Setup
    Power Cycle On
    Enter Setup Menu Tianocore
