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
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
UDT001.001 USB detection after coldboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the coldboot (reboot realized by power supply cutting off
    ...    then cutting on).
    Skip If    ${usb_detection_iterations_number} == 0
    Platform verification
    Set Global Variable    ${failed_detection}    0
    Set Local Variable    ${usb}    0
    FOR    ${INDEX}    IN RANGE    0    ${usb_detection_iterations_number}
        TRY
            ${usb}=    Evaluate    0
            Power Cycle On
            IF    '${payload}' == 'tianocore'
                ${menu}=    Enter Tianocore And Return Menu
            ELSE IF    '${payload}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${payload}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${payload}
            END
            FOR    ${stick}    IN    @{attached_usb}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${platform}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get all USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${allowed_fails_usb_detect}'
        Fail    Detection failed too many times (${failed_detection})
    END

UDT002.001 USB detection after warmboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the warmboot (reboot realized by device turning off then
    ...    turning on).
    Skip If    ${usb_detection_iterations_number} == 0
    Platform verification
    Set Global Variable    ${failed_detection}    0
    Set Local Variable    ${usb}    0
    FOR    ${INDEX}    IN RANGE    0    ${usb_detection_iterations_number}
        TRY
            ${usb}=    Evaluate    0
            Power On
            IF    '${payload}' == 'tianocore'
                ${menu}=    Enter Tianocore And Return Menu
            ELSE IF    '${payload}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${payload}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${payload}
            END
            FOR    ${stick}    IN    @{attached_usb}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${platform}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get all USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${allowed_fails_usb_detect}'
        Fail    Detection failed too many times (${failed_detection})
    END

UDT003.001 USB detection after system reboot
    [Documentation]    Check whether the DUT detects properly USB device after
    ...    the system reboot (reboot performing by relevant command).
    Skip If    ${usb_detection_iterations_number} == 0
    Platform verification
    Set Local Variable    ${failed_detection}    0
    Set Local Variable    ${usb}    0
    FOR    ${INDEX}    IN RANGE    0    ${usb_detection_iterations_number}
        TRY
            ${usb}=    Evaluate    0
            Power On
            IF    '${payload}' == 'tianocore'
                Reboot via Ubuntu by Tianocore
            ELSE IF    '${payload}' == 'seabios'
                Reboot via iPXE boot by SeaBIOS
            ELSE IF    '${payload}' == 'petitboot'
                Reboot via OS boot by Petitboot
            ELSE
                FAIL    Unknown payload: ${payload}
            END
            IF    '${payload}' == 'tianocore'
                ${menu}=    Enter Tianocore And Return Menu
            ELSE IF    '${payload}' == 'seabios'
                ${menu}=    Enter SeaBIOS And Return Menu
            ELSE IF    '${payload}' == 'petitboot'
                ${menu}=    Enter Petitboot And Return Menu
            ELSE
                ${menu}=    FAIL    Unknown payload: ${payload}
            END
            FOR    ${stick}    IN    @{attached_usb}
                ${usb_tmp}=    Get Count    ${menu}    ${stick}
                ${usb}=    Evaluate    ${usb} + ${usb_tmp}
            END
            IF    '${platform}' in ['apu1', 'apu5']
                ${usb}=    Evaluate
                ...    ${usb} - sum([1 for line in """${menu}""".splitlines() if 'Multiple Card' in line])
            ELSE
                ${usb}=    Evaluate    '${usb}'
            END
            ${usb_count}=    Get all USB
            Should Be Equal As Integers    ${usb}    ${usb_count}
        EXCEPT
            ${failed_detection}=    Evaluate    ${failed_detection} + 1
        END
    END
    IF    '${failed_detection}' > '${allowed_fails_usb_detect}'
        Fail    Detection failed too many times (${failed_detection})
    END


*** Keywords ***
Platform verification
    [Documentation]    Check whether according to hardware matrix, any USB
    ...    stick is connected to the platform.
    IF    '${platform}' == 'raptor-cs_talos2'    RETURN
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${result}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    not ${result}    SKIP    Platform doesn't have USB storage attached.
