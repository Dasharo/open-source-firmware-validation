*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SUD001.001 USB devices detection after cold boot (Ubuntu 22.04)
#    [Documentation]    Check whether the external USB devices are detected
#    ...    correctly after a cold boot.
#    Skip If    not ${usb_type-a_devices_detection_support}    SUD001.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SUD001.001 not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    FOR    ${INDEX}    IN RANGE    0    ${usb_type-a_devices_detection_iterations}
#    Power Cycle On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    END
#    Exit from root user

# SUD002.001 USB devices detection after warm boot (Ubuntu 22.04)
#    [Documentation]    Check whether the external USB devices are detected
#    ...    correctly after a warm boot.
#    Skip If    not ${usb_type-a_devices_detection_support}    SUD002.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SUD002.001 not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    Detect or install FWTS
#    FOR    ${INDEX}    IN RANGE    0    ${usb_type-a_devices_detection_iterations}
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    END
#    Exit from root user

SUD003.001 USB devices detection after reboot (Ubuntu 22.04)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a reboot.
    Skip If    not ${usb_type-a_devices_detection_support}    SUD003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SUD003.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${usb_device}
    FOR    ${INDEX}    IN RANGE    0    ${usb_type-a_devices_detection_reboot_iterations}
        Write Into Terminal    reboot
        Sleep    60s
        Login to Linux
        Switch to root user
        ${out}=    List devices in Linux    usb
        Should Contain    ${out}    ${usb_device}
    END

SUD004.001 USB devices detection after suspension (Ubuntu 22.04)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    Skip If    not ${usb_type-a_devices_detection_support}    SUD004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    SUD004.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${usb_device}
    Detect or install FWTS
    FOR    ${INDEX}    IN RANGE    0    ${usb_type-a_devices_detection_iterations}
        Execute Command In Terminal    fwts s3 --s3-sleep-delay=10
        ${out}=    List devices in Linux    usb
        Should Contain    ${out}    ${usb_device}
    END
    Exit from root user
