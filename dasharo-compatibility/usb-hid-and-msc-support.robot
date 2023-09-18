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
# USB001.001 USB devices detected in FW
#    [Documentation]    Check whether USB devices are detected in Tianocore
#    ...    (edk2).
#    Skip If    not ${usb_disks_detection_support}    USB001.001 not supported
#    Power On
#    Enter Tianocore
#    Enter One Time Boot in Tianocore
#    Telnet.Read Until    ${clevo_usb_stick}

USB001.002 USB devices detected by OS (Ubuntu 20.04)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Linux OS.
    Skip If    not ${usb_disks_detection_support}    USB001.002 not supported
    Skip If    not ${tests_in_ubuntu_support}    USB001.002 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${usb_model}
    Exit from root user

USB001.003 USB devices detected by OS (Windows 10)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Windows OS.
    Skip If    not ${usb_disks_detection_support}    USB001.003 not supported
    Skip If    not ${tests_in_windows_support}    USB001.003 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    ${drives}=    Get Lines Matching Regexp    ${out}    ^OK\\s+DiskDrive\\s+.*$
    Should Contain    ${drives}    ${usb_model}

# TODO:
# - when we obtain Pi-KVM rest-api
# USB002.001 USB keyboard detected in FW
#    [Documentation]    Check whether the external USB keyboard is detected
#    ...    correctly by the firmware and all basic keys work
#    ...    according to their labels.
#    Power On
#    Enter Tianocore

USB002.002 USB keyboard in OS (Ubuntu 20.04)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Linux OS and all basic keys work
    ...    according to their labels.
    IF    not ${usb_keyboard_detection_support}
        SKIP    USB002.002 not supported
    END
    IF    not ${tests_in_ubuntu_support}    SKIP    USB002.002 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    List devices in Linux    usb
    Should Contain    ${out}    ${device_usb_keyboard}

USB002.003 USB keyboard in OS (Windows 11)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Windows OS.
    IF    not ${usb_keyboard_detection_support}
        SKIP    USB002.003 not supported
    END
    IF    not ${tests_in_windows_support}    SKIP    USB002.003 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${out}=    Execute Command in Terminal    Get-CimInstance win32_KEYBOARD
    ${keyboard}=    Get Lines Matching Regexp    ${out}    ^CreationClassName\\s+:\\sWin32_Keyboard.*$
    Should Not Be Empty    ${keyboard}

USB003.001 Upload 1GB file on USB storage (Ubuntu 22.04)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    IF    not ${upload_on_usb_support}    SKIP    USB003.001 not supported
    IF    not ${tests_in_ubuntu_support}    SKIP    USB003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Execute Linux command    openssl rand -out test_file.txt -base64 $(( 2**30 * 3/4 ))
    ${path_to_usb}=    Identify Path To USB
    Execute Linux command    cp test_file.txt ${path_to_usb}    120
    Check if files are identical in Linux    test_file.txt    ${path_to_usb}/test_file.txt
    Execute Linux command    rm test_file.txt ${path_to_usb}/test_file.txt
    Exit from root user

USB003.002 Upload 1GB file on USB storage (Windows 11)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    IF    not ${upload_on_usb_support}    SKIP    USB003.002 not supported
    IF    not ${tests_in_windows_support}    SKIP    USB003.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    Generate 1GB File in Windows
    # Work only with one attached USB storage
    ${drive_letter}=    Get Drive Letter Of USB
    Execute Command in Terminal    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:
    ${hash1}=    Get Hash Of File    test_file.txt
    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
    Execute Command in Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
    Execute Command in Terminal    Remove-Item -Path ${drive_letter}:\\test_file.txt
    Should Be Equal    ${hash1}    ${hash2}
