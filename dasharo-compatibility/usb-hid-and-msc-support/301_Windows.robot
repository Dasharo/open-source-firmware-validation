*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     USB Suite Setup
...                     AND    Depends On    ${TESTS_IN_WINDOWS_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
USB001.301 USB devices detected by OS (Windows)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly in Windows OS.
    ...    Previous IDs: USB001.003
    Depends On    ${USB_DISKS_DETECTION_SUPPORT}
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    IF    ${HAS_KEYBOARD}    Should Contain    ${out}    HIDClass
    IF    ${HAS_USB_STORAGE}    Should Contain    ${out}    DiskDrive

USB002.301 USB keyboard in OS (Windows)
    [Documentation]    Check whether the external USB keyboard is detected
    ...    correctly by the Windows OS.
    ...    Previous IDs: USB002.003
    Depends On    ${USB_KEYBOARD_DETECTION_SUPPORT}
    Depends On    ${HAS_KEYBOARD}
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    ${keyboard}=    Get Lines Matching Regexp    ${out}    ^CreationClassName\\s+:\\sWin32_Keyboard.*$
    Should Not Be Empty    ${keyboard}

USB003.301 Upload 1GB file on USB storage (Windows)
    [Documentation]    Check whether the 1GB file can be transferred from the
    ...    operating system to the USB storage.
    ...    Previous IDs: USB003.003
    Depends On    ${UPLOAD_ON_USB_SUPPORT}
    Depends On    ${HAS_USB_STORAGE}
    Power On
    Login To Windows
    Generate 1GB File In Windows
    # Work only with one attached USB storage
    ${drive_letter}=    Get Drive Letter Of USB
    Execute Command In Terminal
    ...    Copy-Item -Path C:\\Users\\user\\test_file.txt ${drive_letter}:    120
    ${hash1}=    Get Hash Of File    test_file.txt
    ${hash2}=    Get Hash Of File    ${drive_letter}:\\test_file.txt
    Execute Command In Terminal    Remove-Item -Path C:\\Users\\user\\test_file.txt
    Execute Command In Terminal
    ...    Remove-Item -Path ${drive_letter}:\\test_file.txt    120
    Should Be Equal    ${hash1}    ${hash2}
