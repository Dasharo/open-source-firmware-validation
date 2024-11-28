*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    ${USB_DETECTION_ITERATIONS_NUMBER} == 0    USB detection tests skipped
...                     AND
...                     Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UDT001.001 USB detection after coldboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the coldboot (reboot realized by power supply cutting off
    ...    then cutting on).
    Set Local Variable    ${failed_detection}    0
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        Power Cycle On
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        ${found}=    Check USB Stick Detection in Edk2    ${boot_menu}

        IF    '${found}' != '${TRUE}'
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
            IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
                Fail    Detection failed too many times (${failed_detection})
            END
        END
    END

UDT002.001 USB detection after warmboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the warmboot (reboot realized by device turning off then
    ...    turning on).
    Set Local Variable    ${failed_detection}    0
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        Power On
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        ${found}=    Check USB Stick Detection in Edk2    ${boot_menu}

        IF    '${found}' != '${TRUE}'
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
            IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
                Fail    Detection failed too many times (${failed_detection})
            END
        END
    END

UDT003.001 USB detection after system reboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the system reboot (reboot performing by relevant command).
    Set Local Variable    ${failed_detection}    0

    Power On
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
        ${found}=    Check USB Stick Detection in Edk2    ${boot_menu}
        Boot System Or From Connected Disk    ubuntu    boot_menu=${boot_menu}
        Login To Linux
        Switch To Root User
        Execute Reboot Command

        IF    '${found}' != '${TRUE}'
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
            IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
                Fail    Detection failed too many times (${failed_detection})
            END
        END
    END
