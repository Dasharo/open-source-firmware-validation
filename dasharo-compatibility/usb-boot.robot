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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UBT001.001 USB detect and boot after coldboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after coldboot (reboot
    ...    realized by power supply cutting off then cutting on).
    Skip If    ${BOOT_FROM_USB_ITERATIONS_NUMBER} == 0
    Platform Verification
    Set Local Variable    ${FAILED_BOOT}    0
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Power Cycle On
            Boot System Or From Connected Disk    ${USB_LIVE}
            Login To Linux
        EXCEPT
            ${failed_boot}=    Evaluate    ${FAILED_BOOT} + 1
        END
    END
    IF    ${index} > 1    LOG    Boot from USB failed ${index} times.    WARN
    IF    '${failed_boot}' > '${ALLOWED_FAILS_USB_BOOT}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT002.001 USB detect and boot after warmboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after warmboot (reboot
    ...    realized by device turning off then turning on).
    Skip If    ${BOOT_FROM_USB_ITERATIONS_NUMBER} == 0
    Platform Verification
    Set Local Variable    ${FAILED_BOOT}    0
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Power On
            Boot System Or From Connected Disk    ${USB_LIVE}
            Login To Linux
        EXCEPT
            ${failed_boot}=    Evaluate    ${FAILED_BOOT} + 1
        END
    END
    IF    ${index} > 1    LOG    Boot from USB failed ${index} times.    WARN
    IF    '${failed_boot}' > '${ALLOWED_FAILS_USB_BOOT}'
        Fail    Boot from USB failed too many times (${failed_boot})
    END

UBT003.001 USB detect and boot after system reboot
    [Documentation]    Check whether the DUT properly detects USB device and
    ...    boots into the operating system after system reboot
    ...    (reboot performing by relevant command).
    Skip If    ${BOOT_FROM_USB_ITERATIONS_NUMBER} == 0
    Platform Verification
    Set Local Variable    ${FAILED_BOOT}    0
    Power On
    FOR    ${index}    IN RANGE    0    ${BOOT_FROM_USB_ITERATIONS_NUMBER}
        TRY
            Boot System Or From Connected Disk    ${USB_LIVE}
            Login To Linux    ${DEVICE_USB_USERNAME}    ${DEVICE_USB_PASSWORD}    ${DEVICE_USB_PROMPT}
            Switch To Root User    prompt=DEVICE_USB_ROOT_PROMPT
            Write Into Terminal    reboot
        EXCEPT
            ${failed_boot}=    Evaluate    ${FAILED_BOOT} + 1
        END
    END
    IF    ${index} > 1    LOG    Boot from USB failed ${index} times.    WARN
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
