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
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
SMW001.201 Wi-fi connection after cold boot (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a cold boot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW001.001 not supported
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Power Cycle On
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END
    Exit From Root User

SMW002.201 Wi-fi connection after warm boot (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a warm boot.
    ...    Previous IDs: SMW002.001
    Skip If    not ${M2_WIFI_SUPPORT}    SMW002.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMW002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wi-Fi Connection After Warm Boot
    Exit From Root User

SMW003.201 Wi-fi connection after reboot (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a reboot.
    ...    Previous IDs: SMW003.001
    Skip If    not ${M2_WIFI_SUPPORT}    SMW003.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMW003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wi-Fi Connection After Reboot
    Exit From Root User

SMW004.201 Wi-fi connection after suspension (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.001
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW004.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMW004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension
    Exit From Root User

SMW005.201 Wi-fi connection after suspension (Ubuntu) (S0ix)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.002
    Skip If    not ${M2_WIFI_SUPPORT}    SMW005.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW005.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMW005.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension    S0ix
    Exit From Root User

SMW006.201 Wi-fi connection after suspension (Ubuntu) (S3)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.003
    Skip If    not ${M2_WIFI_SUPPORT}    SMW006.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMW006.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension    S3
    Exit From Root User

SMW002.202 Wi-fi connection after warm boot (Fedora)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a warm boot.
    ...    Previous IDs: SMW002.001
    Skip If    not ${M2_WIFI_SUPPORT}    SMW002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SMW002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Wi-Fi Connection After Warm Boot
    Exit From Root User

SMW003.202 Wi-fi connection after reboot (Fedora)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a reboot.
    ...    Previous IDs: SMW003.202
    Skip If    not ${M2_WIFI_SUPPORT}    SMW003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SMW003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Wi-Fi Connection After Reboot
    Exit From Root User

SMW004.202 Wi-fi connection after suspension (Fedora)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.001
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.202 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SMW004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension
    Exit From Root User

SMW005.202 Wi-fi connection after suspension (Fedora) (S0ix)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.002
    Skip If    not ${M2_WIFI_SUPPORT}    SMW005.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SMW005.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension    S0ix
    Exit From Root User

SMW006.202 Wi-fi connection after suspension (Fedora) (S3)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    ...    Previous IDs: SMW004.003
    Skip If    not ${M2_WIFI_SUPPORT}    SMW006.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SMW006.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Wi-fi Connection After Suspension    S3
    Exit From Root User

SMW001.203 Wi-fi detection after cold boot (QubesOS)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a cold boot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW001.203 not supported
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SMW001.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SMW001.203 not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Execute the following command: `lspci | grep "Network controller:"`
    Execute Manual Step    [4/4] Match the command output with actual DUT's hardware

SMW002.203 Wi-fi detection after warm boot (QubesOS)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a warm boot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW002.203 not supported
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SMW002.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SMW002.203 not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Execute the following command: `lspci | grep "Network controller:"`
    Execute Manual Step    [4/4] Match the command output with actual DUT's hardware

SMW003.203 Wi-fi detection after reboot (QubesOS)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a reboot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW003.203 not supported
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SMW003.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SMW003.203 not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Execute the following command: `lspci | grep "Network controller:"`
    Execute Manual Step    [4/4] Match the command output with actual DUT's hardware

SMW004.203 Wi-fi detection after suspension (QubesOS)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after resuming from suspension.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.203 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.203 not supported
    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    SMW004.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SMW004.203 not supported
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Open Dom0 Xfce Terminal (or any text editor).
    Execute Manual Step    [3/4] Execute the following command: `lspci | grep "Network controller:"`
    Execute Manual Step    [4/4] Match the command output with actual DUT's hardware


*** Keywords ***
Wi-fi Connection After Suspension
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}

    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END

Wi-Fi Connection After Warm Boot
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a warm boot.
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Warmboot Using Rtcwake
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END

Wi-Fi Connection After Reboot
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a reboot.
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux

    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END
