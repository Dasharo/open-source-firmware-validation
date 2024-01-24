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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UDT001.001 USB detection after coldboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the coldboot (reboot realized by power supply cutting off
    ...    then cutting on).
    Platform Verification
    Set Global Variable    ${FAILED_DETECTION}    0
    Set Local Variable    ${usb}    0
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        TRY
            ${usb}=    Evaluate    0
            Power Cycle On
            IF    '${PAYLOAD}' == 'tianocore'
                Enter Boot Menu Tianocore
                ${menu}=    Read From Terminal Until    ESC to exit
            ELSE IF    '${PAYLOAD}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${PAYLOAD}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${PAYLOAD}
            END
            FOR    ${stick}    IN    @{ATTACHED_USB}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${PLATFORM}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get All USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
        Fail    Detection failed too many times (${failed_detection})
    END

UDT002.001 USB detection after warmboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the warmboot (reboot realized by device turning off then
    ...    turning on).
    Platform Verification
    Set Global Variable    ${FAILED_DETECTION}    0
    Set Local Variable    ${usb}    0
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        TRY
            ${usb}=    Evaluate    0
            Power On
            IF    '${PAYLOAD}' == 'tianocore'
                ${menu}=    Enter Tianocore And Return Menu
            ELSE IF    '${PAYLOAD}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${PAYLOAD}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${PAYLOAD}
            END
            FOR    ${stick}    IN    @{ATTACHED_USB}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${PLATFORM}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get All USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
        Fail    Detection failed too many times (${failed_detection})
    END

UDT003.001 USB detection after system reboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the system reboot (reboot performing by relevant command).
    Platform Verification
    Set Local Variable    ${failed_detection}    0
    Set Local Variable    ${usb}    0
    FOR    ${index}    IN RANGE    0    ${USB_DETECTION_ITERATIONS_NUMBER}
        TRY
            ${usb}=    Evaluate    0
            Power On
            IF    '${PAYLOAD}' == 'tianocore'
                Reboot Via Ubuntu By Tianocore
            ELSE IF    '${PAYLOAD}' == 'seabios'
                Reboot Via IPXE Boot By SeaBIOS
            ELSE IF    '${PAYLOAD}' == 'petitboot'
                Reboot Via OS Boot By Petitboot
            ELSE
                FAIL    Unknown payload: ${PAYLOAD}
            END
            IF    '${PAYLOAD}' == 'tianocore'
                ${menu}=    Enter Tianocore And Return Menu
            ELSE IF    '${PAYLOAD}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${PAYLOAD}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${PAYLOAD}
            END
            FOR    ${stick}    IN    @{ATTACHED_USB}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${PLATFORM}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get All USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_FAILS_USB_DETECT}'
        Fail    Detection failed too many times (${failed_detection})
    END


*** Keywords ***
Platform Verification
    [Documentation]    Check whether according to hardware matrix, any USB
    ...    stick is connected to the platform.
    IF    '${PLATFORM}' == 'raptor-cs_talos2'    RETURN
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${result}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    not ${result}    SKIP    Platform doesn't have USB storage attached.
