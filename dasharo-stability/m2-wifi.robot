*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# Tests will work on laptops with access to the serial console and possibility
# of remote power control
# SMW0001.001 Wi-fi connection after cold boot (Ubuntu 22.04)
#    [Documentation]    Check whether the Wi-Fi card is detected and working
#    ...    correctly after performing a cold boot.
#    Skip If    not ${m2_wifi_support}    SMW001.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SMW001.001 not supported
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

# SMW0002.001 Wi-fi connection after warm boot (Ubuntu 22.04)
#    [Documentation]    Check whether the Wi-Fi card is detected and working
#    ...    correctly after performing a warm boot.
#    Skip If    not ${m2_wifi_support}    SMW002.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SMW002.001 not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    Detect or install FWTS
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_reboot_iterations}
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    END
#    Exit from root user

# SMW0003.001 Wi-fi connection after reboot (Ubuntu 22.04)
#    [Documentation]    Check whether the Wi-Fi card is detected and working
#    ...    correctly after performing a reboot.
#    Skip If    not ${m2_wifi_support}    SMW003.001 not supported
#    Skip If    not ${tests_in_ubuntu_support}    SMW003.001 not supported
#    Power On
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    Detect or install FWTS
#    FOR    ${INDEX}    IN RANGE    0    ${stability_detection_reboot_iterations}
#    Write Into Terminal    reboot
#    Boot operating system    ubuntu
#    Login to Linux
#    Switch to root user
#    ${out}=    Execute Command In Terminal    lspci | grep "Network controller:"
#    Should Match    ${out}    *${wifi_card_ubuntu}*
#    Scan for Wi-Fi in Linux
#    END
#    Exit from root user

SMW0004.001 Wi-fi connection after suspension (Ubuntu 22.04)
    [Documentation]    Check whether the Wi-Fi card is detected and working
    ...    correctly after performing suspension.
    Skip If    not ${M2_WIFI_SUPPORT}    SUD004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUD004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
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
