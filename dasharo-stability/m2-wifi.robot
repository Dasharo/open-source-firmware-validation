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


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SMW001.001 Wi-fi connection after cold boot (Ubuntu)
#    [Documentation]    Check whether the Wi-Fi card is detected and working
#    ...    correctly after performing a cold boot.
#    Skip If    not ${m2_wifi_support}    SMW001.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SMW001.001 not supported
#    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    Detect or install FWTS
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_reboot_iterations}
#    Power Cycle On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    END
#    Exit from root user

SMW002.001 Wi-fi connection after warm boot (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a warm boot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW002.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux
    Detect Or Install FWTS
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Warmboot Using Rtcwake
        Boot Operating System    ubuntu
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END
    Exit From Root User

SMW003.001 Wi-fi connection after reboot (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing a reboot.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW003.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux
    Detect Or Install FWTS
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot Operating System    ubuntu
        Login To Linux
        Switch To Root User
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END

SMW004.001 Wi-fi connection after suspension (Ubuntu)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW004.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.001 not supported
    Wi-fi Connection After Suspension (Ubuntu)

SMW004.002 Wi-fi connection after suspension (Ubuntu) (S0ix)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW004.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.002 not supported
    Set Platform Sleep Type    S0ix
    Wi-fi Connection After Suspension (Ubuntu)    S0ix

SMW004.003 Wi-fi connection after suspension (Ubuntu) (S3)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    Skip If    not ${M2_WIFI_SUPPORT}    SMW004.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMW004.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SMW004.002 not supported
    Set Platform Sleep Type    S3
    Wi-fi Connection After Suspension (Ubuntu)    S3


*** Keywords ***
Wi-fi Connection After Suspension (Ubuntu)
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Or Install Package    pciutils
    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
    Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
    Scan For Wi-Fi In Linux
    Detect Or Install FWTS
    FOR    ${index}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Perform Suspend Test Using FWTS
        ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
        Should Match    ${out}    *${WIFI_CARD_UBUNTU}*
        Scan For Wi-Fi In Linux
    END
    Exit From Root User
