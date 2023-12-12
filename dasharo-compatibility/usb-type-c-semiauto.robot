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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UTC008.001 Docking station detection after coldboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.001 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC009.001 Docking station detection after warmboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.001 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC010.001 Docking station detection after reboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.001 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC011.001 Docking station detection after suspend (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.001 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC011.002 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.002 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.E    S0ix

UTC011.003 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.003 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.E    S3

UTC008.002 Docking station detection after coldboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.002 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC009.002 Docking station detection after warmboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.002 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC010.002 Docking station detection after reboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.002 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC011.004 Docking station detection after suspend (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.004 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.004 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC011.005 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.005 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.005 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1    S0ix

UTC011.006 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.006 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.006 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.006 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1    S3

UTC008.003 Docking station detection after coldboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.003 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC009.003 Docking station detection after warmboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.003 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC010.003 Docking station detection after reboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.003 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC011.007 Docking station detection after suspend (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.007 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.007 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC011.008 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.008 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.008 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.008 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UG69PD2 Rev.A1    S0ix

UTC011.009 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.009 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.009 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.009 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    WL-UG69PD2 Rev.A1    S3


*** Keywords ***
Docking Station Detection After Coldboot (Ubuntu 22.04)
    [Arguments]    ${docking_station_model}
    Pause Execution In Console    Please make sure the docking station connected is ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        Log To Console    Cold boot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            ${out_before_reboot}=    Execute Linux Command    uptime --since
            WHILE    '${out_before_reboot}' == '${out_after_reboot}'
                Log To Console    Coldboot the DUT manually
                # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
                Pause Execution In Console    Do power cut-off, reconnect and press ENTER.
                Login To Linux
                Switch To Root User
                ${out_after_reboot}=    Execute Linux Command    uptime --since
                Detect Docking Station In Linux    ${docking_station_model}
            END
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Warmboot (Ubuntu 22.04)
    [Arguments]    ${docking_station_model}
    Pause Execution In Console    Please make sure the docking station connected is ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Log To Console    Warm boot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            ${out_before_reboot}=    Execute Linux Command    uptime --since
            WHILE    '${out_before_reboot}' == '${out_after_reboot}'
                Write Into Terminal    poweroff
                Log To Console    Warmboot the DUT manually
                # warmboot - msi rte, protectli novacustom ???
                Pause Execution In Console    Press power button on platform and press ENTER.
                Login To Linux
                Switch To Root User
                ${out_after_reboot}=    Execute Linux Command    uptime --since
                Detect Docking Station In Linux    ${docking_station_model}
            END
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Reboot (Ubuntu 22.04)
    [Arguments]    ${docking_station_model}
    Pause Execution In Console    Please make sure the docking station connected is ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Log To Console    Reboot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            Write Into Terminal    reboot
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    45s
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux    ${docking_station_model}
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
            Power On
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux    ${docking_station_model}
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend (Ubuntu 22.04)
    [Arguments]    ${docking_station_model}    ${platform_sleep_type}=${EMPTY}
    Pause Execution In Console    Please make sure the docking station connected is ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Or Install FWTS
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Log To Console
        ...    Suspend ${platform_sleep_type} iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        Perform Suspend Test Using FWTS
        TRY
            Detect Docking Station In Linux    ${docking_station_model}
        EXCEPT    message
            Evaluate    ${FAILED_DETECTION}=    ${FAILED_DETECTION}+1
        END
    END
    IF    '${FAILED_DETECTION}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${FAILED_DETECTION} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Pause Execution In Console
    [Documentation]    Pauses execution until user press ENTER.
    [Arguments]    ${message}= Press ENTER to continue...
    Run    notify-send "Please execute Manual Step in ${TEST_NAME}"    # GUI message
    Run    echo -ne '\007'    # ASCII BEL (\007)
    Log To Console    ${message}
    Run    read ignore
