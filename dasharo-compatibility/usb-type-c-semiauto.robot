*** Settings ***
Library             Collections
Library             Dialogs
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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    Docking station detect tests not supported
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UTC008.001 Docking station detection after coldboot (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.001 not supported
    Docking Station Detection After Coldboot (Ubuntu)    WL-UMD05 Pro Rev.E

UTC009.001 Docking station detection after warmboot (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.001 not supported
    Docking Station Detection After Warmboot (Ubuntu)    WL-UMD05 Pro Rev.E

UTC010.001 Docking station detection after reboot (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.001 not supported
    Docking Station Detection After Reboot (Ubuntu)    WL-UMD05 Pro Rev.E

UTC011.001 Docking station detection after suspend (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.001 not supported
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.E

UTC011.002 Docking station detection after suspend (Ubuntu) (S0ix) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.002 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.E    S0ix

UTC011.003 Docking station detection after suspend (Ubuntu) (S3) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.003 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.E    S3

UTC008.002 Docking station detection after coldboot (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC008.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.002 not supported
    Docking Station Detection After Coldboot (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC009.002 Docking station detection after warmboot (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.002 not supported
    Docking Station Detection After Warmboot (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC010.002 Docking station detection after reboot (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.002 not supported
    Docking Station Detection After Reboot (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC011.004 Docking station detection after suspend (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.004 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.004 not supported
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC011.005 Docking station detection after suspend (Ubuntu) (S0ix) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.005 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.005 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.C1    S0ix

UTC011.006 Docking station detection after suspend (Ubuntu) (S3) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.006 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.006 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu)    WL-UMD05 Pro Rev.C1    S3

UTC008.003 Docking station detection after coldboot (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC008.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.003 not supported
    Docking Station Detection After Coldboot (Ubuntu)    WL-UG69PD2 Rev.A1

UTC009.003 Docking station detection after warmboot (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.003 not supported
    Docking Station Detection After Warmboot (Ubuntu)    WL-UG69PD2 Rev.A1

UTC010.003 Docking station detection after reboot (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.003 not supported
    Docking Station Detection After Reboot (Ubuntu)    WL-UG69PD2 Rev.A1

UTC011.007 Docking station detection after suspend (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.007 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.007 not supported
    Docking Station Detection After Suspend (Ubuntu)    WL-UG69PD2 Rev.A1

UTC011.008 Docking station detection after suspend (Ubuntu) (S0ix) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.008 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.008 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu)    WL-UG69PD2 Rev.A1    S0ix

UTC011.009 Docking station detection after suspend (Ubuntu) (S3) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.009 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.009 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu)    WL-UG69PD2 Rev.A1    S3

UTC022.001 Docking station detection after coldboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC022.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC022.001 not supported
    Docking Station Detection After Coldboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E

UTC023.001 Docking station detection after warmboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC023.001 not supported
    Docking Station Detection After Warmboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E

UTC024.001 Docking station detection after reboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC023.001 not supported
    Docking Station Detection After Reboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E

UTC025.001 Docking station detection after suspend then hotplug (Ubuntu) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC025.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC025.001 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E

UTC025.002 Docking station detection after suspend then hotplug (Ubuntu) (S0ix) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.002 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E    S0ix

UTC025.003 Docking station detection after suspend then hotplug (Ubuntu) (S3) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.003 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.E    S3

UTC022.002 Docking station detection after coldboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.002 not supported
    Docking Station Detection After Coldboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC023.002 Docking station detection after warmboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.002 not supported
    Docking Station Detection After Warmboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC024.002 Docking station detection after reboot then hotplug (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.002 not supported
    Docking Station Detection After Reboot Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC025.004 Docking station detection after suspend then hotplug (Ubuntu) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.004 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.004 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1

UTC025.005 Docking station detection after suspend then hotplug (Ubuntu) (S0ix) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.005 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.005 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1    S0ix

UTC025.006 Docking station detection after suspend then hotplug (Ubuntu) (S3) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.006 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.006 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UMD05 Pro Rev.C1    S3

UTC022.003 Docking station detection after coldboot then hotplug (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.003 not supported
    Docking Station Detection After Coldboot Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1

UTC023.003 Docking station detection after warmboot then hotplug (Ubunt) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.003 not supported
    Docking Station Detection After Warmboot Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1

UTC024.003 Docking station detection after reboot then hotplug (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.003 not supported
    Docking Station Detection After Reboot Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1

UTC025.007 Docking station detection after suspend then hotplug (Ubuntu) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.007 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.007 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1

UTC025.008 Docking station detection after suspend then hotplug (Ubuntu) (S0ix) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.008 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.008 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1    S0ix

UTC025.009 Docking station detection after suspend then hotplug (Ubuntu) (S3) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.009 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.009 not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend Then Hotplug (Ubuntu)    WL-UG69PD2 Rev.A1    S3


*** Keywords ***
Docking Station Detection After Coldboot (Ubuntu)
    [Arguments]    ${docking_station_model}
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    Pause Execution In Console
    ...    Please make sure the docking station connected is ${docking_station_model} and press ENTER
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
                Power Cycle On
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

Docking Station Detection After Warmboot (Ubuntu)
    [Arguments]    ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Log To Console    Warm boot iteration ${iteration+1}/${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        TRY
            ${out_before_reboot}=    Execute Linux Command    uptime --since
            WHILE    '${out_before_reboot}' == '${out_after_reboot}'
                Perform Warmboot Using Rtcwake
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

Docking Station Detection After Reboot (Ubuntu)
    [Arguments]    ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Log To Console    Reboot iteration ${iteration+1}/${STABILITY_DETECTION_REBOOT_ITERATIONS}
        TRY
            Execute Reboot Command
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux    ${docking_station_model}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend (Ubuntu)
    [Arguments]    ${docking_station_model}    ${platform_sleep_type}=${EMPTY}
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
        ...    Suspend ${platform_sleep_type} iteration ${iteration+1}/${STABILITY_DETECTION_SUSPEND_ITERATIONS}
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
    Log To Console    Manual step confirmed

Docking Station Detection After Coldboot Then Hotplug (Ubuntu)
    [Arguments]    ${docking_station_model}
    Skip If    '${POWER_CTRL}' == 'none'    Coldboot automatic tests not supported
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    ${out_before_reboot}=    Execute Linux Command    uptime --since
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    WHILE    '${out_before_reboot}' == '${out_after_reboot}'
        Log To Console    Coldboot the DUT manually
        # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
        Pause Execution In Console    Do power cut-off, reconnect and press ENTER.
        Login To Linux
        Switch To Root User
        ${out_after_reboot}=    Execute Linux Command    uptime --since
        Run Keyword And Expect Error
        ...    * does not contain *
        ...    Detect Docking Station In Linux
        ...    ${docking_station_model}
    END
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        Log To Console    Hotplug after Cold boot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Connect docking station ${docking_station_model} and press ENTER.
            Detect Docking Station In Linux    ${docking_station_model}
            Pause Execution In Console    Disconnect docking station ${docking_station_model} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${docking_station_model}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Warmboot Then Hotplug (Ubuntu)
    [Arguments]    ${docking_station_model}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    ${out_before_reboot}=    Execute Linux Command    uptime --since
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    WHILE    '${out_before_reboot}' == '${out_after_reboot}'
        Perform Warmboot Using Rtcwake
        Pause Execution In Console    Press power button on platform and press ENTER.
        Login To Linux
        Switch To Root User
        ${out_after_reboot}=    Execute Linux Command    uptime --since
        Run Keyword And Expect Error
        ...    * does not contain *
        ...    Detect Docking Station In Linux
        ...    ${docking_station_model}
    END
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Log To Console    Hotplug after Warm boot iteration ${iteration+1}/${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Connect docking station ${docking_station_model} and press ENTER.
            Detect Docking Station In Linux    ${docking_station_model}
            Pause Execution In Console    Disconnect docking station ${docking_station_model} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${docking_station_model}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Reboot Then Hotplug (Ubuntu)
    [Arguments]    ${docking_station_model}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    Execute Reboot Command
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Log To Console    Hotplug after Reboot iteration ${iteration+1}/${STABILITY_DETECTION_REBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Connect docking station ${docking_station_model} and press ENTER.
            Detect Docking Station In Linux    ${docking_station_model}
            Pause Execution In Console    Disconnect docking station ${docking_station_model} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${docking_station_model}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend Then Hotplug (Ubuntu)
    [Arguments]    ${docking_station_model}    ${platform_sleep_type}=${EMPTY}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Or Install FWTS
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${docking_station_model}
    Set Global Variable    ${FAILED_DETECTION}    0
    Perform Suspend Test Using FWTS
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Log To Console
        ...    Hotplug after Suspend ${platform_sleep_type} iteration ${iteration+1}/${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        TRY
            Pause Execution In Console    Connect docking station ${docking_station_model} and press ENTER.
            Detect Docking Station In Linux    ${docking_station_model}
            Pause Execution In Console    Disconnect docking station ${docking_station_model} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${docking_station_model}
        EXCEPT    message
            Evaluate    ${FAILED_DETECTION}=    ${FAILED_DETECTION}+1
        END
    END
    IF    '${FAILED_DETECTION}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${FAILED_DETECTION} iterations failed.
    END
    Log To Console    \nAll iterations passed.
