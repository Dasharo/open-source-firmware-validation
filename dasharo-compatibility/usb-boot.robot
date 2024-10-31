# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

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
...                     Skip If    ${BOOT_FROM_USB_ITERATIONS_NUMBER} == 0    USB booting tests skipped
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UBT001.001 USB detect and boot after coldboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after coldboot (reboot
    ...    realized by power supply cutting off then cutting on).
    Platform Verification
    Set Local Variable    ${failed_boot}    0
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Power Cycle On
            Boot From USB
            IF    '${PLATFORM}' == 'raptor-cs_talos2'
                Login To Linux
            ELSE
                Login To Linux Over Serial Console
                ...    ${DEVICE_USB_USERNAME}
                ...    ${DEVICE_USB_PASSWORD}
                ...    ${DEVICE_USB_PROMPT}
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${ALLOWED_FAILS_USB_BOOT}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT002.001 USB detect and boot after warmboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after warmboot (reboot
    ...    realized by device turning off then turning on).
    Platform Verification
    Set Local Variable    ${failed_boot}    0
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Power On
            Boot From USB
            IF    '${PLATFORM}' == 'raptor-cs_talos2'
                Login To Linux
            ELSE
                Login To Linux Over Serial Console
                ...    ${DEVICE_USB_USERNAME}
                ...    ${DEVICE_USB_PASSWORD}
                ...    ${DEVICE_USB_PROMPT}
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${ALLOWED_FAILS_USB_BOOT}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT003.001 USB detect and boot after system reboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after system reboot
    ...    (reboot performing by relevant command).
    Platform Verification
    Set Local Variable    ${failed_boot}    0
    Power On
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Boot From USB
            IF    '${PLATFORM}' != 'raptor-cs_talos2'    Reboot Via Linux On USB
            IF    '${PLATFORM}' == 'raptor-cs_talos2'    Login To Linux
            IF    '${PLATFORM}' == 'raptor-cs_talos2'
                Write Into Terminal    reboot
            END
        EXCEPT
            ${failed_boot}=    Evaluate    ${failed_boot} + 1
        END
    END
    IF    '${failed_boot}' > '${ALLOWED_FAILS_USB_BOOT}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END


*** Keywords ***
Platform Verification
    [Documentation]    Check whether according to hardware matrix, any USB
    ...    stick is connected to the platform.
    IF    '${PLATFORM}' == 'raptor-cs_talos2'    RETURN
    ${conf}=    Get Current CONFIG    ${CONFIG_LIST}
    ${result}=    Evaluate    "USB_Storage" in """${conf}"""
    IF    not ${result}
        SKIP    \nPlatform doesn't have USB storage attached.
    ELSE
        Log    Selected platform is correct.
    END
