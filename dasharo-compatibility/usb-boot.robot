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
UBT001.001 USB detect and boot after coldboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after coldboot (reboot
    ...    realized by power supply cutting off then cutting on).
    Skip If    ${boot_from_usb_iterations_number} == 0
    Platform verification
    Set Local Variable    ${failed_boot}    0
    FOR    ${INDEX}    IN RANGE    0    ${boot_from_usb_iterations_number}
        TRY
            Power Cycle On
            Boot from USB
            IF    '${platform}' == 'raptor-cs_talos2'
                Login to Linux
            ELSE
                Login to Linux over serial console
                ...    ${device_usb_username}
                ...    ${device_usb_password}
                ...    ${device_usb_prompt}
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${allowed_fails_usb_boot}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT002.001 USB detect and boot after warmboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after warmboot (reboot
    ...    realized by device turning off then turning on).
    Skip If    ${boot_from_usb_iterations_number} == 0
    Platform verification
    Set Local Variable    ${failed_boot}    0
    FOR    ${INDEX}    IN RANGE    0    ${boot_from_usb_iterations_number}
        TRY
            Power On
            Boot from USB
            IF    '${platform}' == 'raptor-cs_talos2'
                Login to Linux
            ELSE
                Login to Linux over serial console
                ...    ${device_usb_username}
                ...    ${device_usb_password}
                ...    ${device_usb_prompt}
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${allowed_fails_usb_boot}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT003.001 USB detect and boot after system reboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after system reboot
    ...    (reboot performing by relevant command).
    Skip If    ${boot_from_usb_iterations_number} == 0
    Platform verification
    Set Local Variable    ${failed_boot}    0
    Power On
    FOR    ${INDEX}    IN RANGE    0    ${boot_from_usb_iterations_number}
        TRY
            Boot from USB
            IF    '${platform}' != 'raptor-cs_talos2'    Reboot via Linux on USB
            IF    '${platform}' == 'raptor-cs_talos2'    Login to Linux
            IF    '${platform}' == 'raptor-cs_talos2'
                Write Into Terminal    reboot
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${allowed_fails_usb_boot}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END


*** Keywords ***
Platform verification
    [Documentation]    Check whether according to hardware matrix, any USB
    ...    stick is connected to the platform.
    IF    '${platform}' == 'raptor-cs_talos2'    RETURN
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${result}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    not ${result}
        SKIP    \nPlatform doesn't have USB storage attached.
    ELSE
        Log    Selected platform is correct.
    END
