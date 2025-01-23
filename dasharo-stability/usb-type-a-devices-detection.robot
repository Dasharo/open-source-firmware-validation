*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}    USB-A devices detection tests not supported
...                     AND
...                     Skip If    ${STABILITY_DETECTION_SUSPEND_ITERATIONS} == 0    USB-A devices detection tests not supported
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SUD001.001 USB devices detection after cold boot (Ubuntu)
#    [Documentation]    Check whether the external USB devices are detected
#    ...    correctly after a cold boot.
#    Skip If    not ${tests_in_ubuntu_support}    SUD001.001 not supported
#    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_coldboot_iterations}
#    Power Cycle On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    List devices in Linux    usb
#    Should Contain    ${out}    ${usb_device}
#    END
#    Exit from root user

SUD002.201 USB devices detection after warm boot (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a warm boot.
    ...    Previous IDs: SUD002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUD002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Warm Boot
    Exit From Root User

SUD003.201 USB devices detection after reboot (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a reboot.
    ...    Previous IDs: SUD003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUD003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Reboot
    Exit From Root User

SUD004.201 USB devices detection after suspension (Ubuntu)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    ...    Previous IDs: SUD004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD004.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUD004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension
    Exit From Root User

SUD005.201 USB devices detection after suspension (Ubuntu) (S0ix)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    ...    Previous IDs: SUD004.002
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD005.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUD005.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension    S0ix
    Exit From Root User

SUD006.201 USB devices detection after suspension (Ubuntu) (S3)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    ...    Previous IDs: SUD004.003
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUD006.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension    S3
    Exit From Root User

SUD002.202 USB devices detection after warm boot (Fedora)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a warm boot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUD002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Warm Boot
    Exit From Root User

SUD003.202 USB devices detection after reboot (Fedora)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a reboot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUD003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Reboot
    Exit From Root User

SUD004.202 USB devices detection after suspension (Fedora)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUD004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension
    Exit From Root User

SUD005.202 USB devices detection after suspension (Fedora) (S0ix)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUD005.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension    S0ix
    Exit From Root User

SUD006.202 USB devices detection after suspension (Fedora) (S3)
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUD006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUD006.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    USB Devices Detection After Suspension    S3
    Exit From Root User


*** Keywords ***
USB Devices Detection After Suspension
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after suspension.
    [Tags]    robot:private
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${USB_DEVICE}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    ${USB_DEVICE}
    END

USB Devices Detection After Warm Boot
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a warm boot.
    [Tags]    robot:private
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${USB_DEVICE}

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Perform Warmboot Using Rtcwake
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    ${USB_DEVICE}
    END

USB Devices Detection After Reboot
    [Documentation]    Check whether the external USB devices are detected
    ...    correctly after a reboot.
    [Tags]    robot:private
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${USB_DEVICE}
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    ${USB_DEVICE}
    END
