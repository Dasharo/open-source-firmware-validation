*** Comments ***
# robocop: disable=unused-argument


*** Settings ***
Library     Collections
Library     OperatingSystem
Library     Process
Library     String
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     SSHLibrary    timeout=90 seconds
Library     RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot
Resource    ../lib/me.robot
Resource    ../lib/docks.robot
Resource    options/options-lib_dcu.robot


*** Keywords ***
Prepare UTC Test Suite
    VAR    ${UTC_CURRENT_ME_STATE}=    unknown    scope=GLOBAL

Ensure ME State
    [Arguments]    ${me_state}
    IF    '${me_state}' not in '${UTC_CURRENT_ME_STATE}'
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        Login To Linux
        Switch To Root User
        ${actual_me_state}=    Check ME Out
        VAR    ${UTC_CURRENT_ME_STATE}=    ${actual_me_state}    scope=GLOBAL
        IF    '${me_state}' not in '${UTC_CURRENT_ME_STATE}'
            IF    '${me_state}' == 'Enabled'
                Set UEFI Option    MeMode    Enabled
            ELSE
                Set UEFI Option    MeMode    Disabled (HAP)
            END
            Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
            Login To Linux
            Switch To Root User
            ${actual_me_state}=    Check ME Out
            Should Contain    ${actual_me_state}    ${me_state}
            VAR    ${UTC_CURRENT_ME_STATE}=    ${me_state}    scope=GLOBAL
            Exit From Root User
        END
    END

# Not automated
# Usb Type-A Charging Capability
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

# Not automated
# Thunderbolt 4 Usb Type-C Power Output
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

Usb Type-C Pd Power Input
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    ${env_id} != ${ENV_ID_QUBES}
        Ensure ME State    ${me_state}
        Power On
    END
    IF    '${env_id}'.startswith('2')    # Linux
        IF    ${env_id} == ${ENV_ID_QUBES}
            Pause Execution In Console    Qubes detected — switching to manual PD power input test
            Execute Manual Step
            ...    [1/10] Enter BIOS/UEFI and set Intel ME to adequate state (test specific). Save & reboot DUT. (Skip if on Heads)
            Execute Manual Step
            ...    [2/10] Boot into dom0. Ensure AC adapter is unplugged.
            ...    Verify battery is discharging normally.
            Execute Manual Step
            ...    [3/10] Connect the docking station to AC power only.
            Execute Manual Step
            ...    [4/10] Plug the dock into the DUT’s USB-C port.
            Execute Manual Step
            ...    [5/10] Run in dom0:
            ...    watch -n1 cat /sys/class/power_supply/BAT0/status
            Execute Manual Step
            ...    [6/10] Verify PD contract and power draw.
            Execute Manual Step
            ...    [7/10] Observe charging LED.
            Execute Manual Step
            ...    [8/10] Attach high-load USB-C device.
            Execute Manual Step
            ...    [9/10] Disconnect dock AC.
            Execute Manual Step
            ...    [10/10] Reconnect dock AC.
        ELSE
            Boot System Or From Connected Disk    ${env_id}
            Login To Linux
            Switch To Root User
            Check Charging State In Linux
            Exit From Root User
        END
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        Check Charging State In Windows
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Display Output
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    ${CLEVO_USB_C_HUB}
        Exit From Root User
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Docking Station Hdmi Display
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        IF    '${dock_name}' == 'WL-UMD05 Pro Rev.E'
            # dp alt mode
            Check PCON On MST Hub In Linux
        ELSE    # Exact models not specified right now, add more branches later
            # Thunderbolt
            Check Display Port On Hub In Linux    HDMI
        END
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        Check Docking Station HDMI Windows
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Docking Station Dp Display
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        IF    '${dock_name}' == 'WL-UMD05 Pro Rev.E'
            # dp alt mode
            Check DP Port On MST Hub In Linux
        ELSE    # Exact models not specified right now, add more branches later
            # Thunderbolt
            Check Display Port On Hub In Linux    DP
        END
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        Check Docking Station DP Windows
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

# Not automated
# Usb Type-C Docking Station Triple Display
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

Usb Type-C Docking Station Usb Devices Recognition
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    SanDisk
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        ${out}=    Execute Command In Terminal
        ...    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
        Should Contain    ${out}    OK${SPACE*9}DiskDrive${SPACE*8}USB${SPACE*2}SanDisk
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Docking Station Usb Keyboard
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
        Should Contain    ${out}    Description${SPACE*17}: USB Input Device    strip_spaces=True
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

# Not automated
# Usb Type-C Docking Station Upload 1Gb File On Usb Storage
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

Usb Type-C Docking Station Ethernet Connection
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        Check Internet Connection On Linux
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        Check Internet Connection On Windows
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Docking Station Audio Recognition
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out}=    List Devices In Linux    usb
        Should Contain Any    ${out}    @{EXTERNAL_HEADSETS}
        Exit From Root User
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

# Not automated
# Usb Type-C Docking Station Audio Playback
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

# Not automated
# Usb Type-C Docking Station Audio Capture
#    [Arguments]    ${env_id}    ${me_state}    ${dock_name}

Usb Type-C Docking Station Sd Card Reader Detection
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${disks}=    Identify Disks In Linux
        Should Match    str(${disks})    pattern=*SD*
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        ${out}=    Execute Command In Terminal
        ...    Get-PnpDevice -Status "OK" -Class "DiskDrive" | ForEach-Object { $_.FriendlyName }
        @{lines}=    Split To Lines    ${out}
        FOR    ${disk}    IN    @{lines}
            ${disk}=    Replace String Using Regexp    ${disk}    ${SPACE}+    ${SPACE}
            TRY
                Should Contain Any    ${disk}    ${DOCKING_STATION_MODEL_1}    ${DOCKING_STATION_MODEL_2}
            EXCEPT
                Log    ${disk} is not SD Card
            END
        END
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Docking Station Sd Card Read/Write
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Ensure ME State    ${me_state}
    Power On
    IF    '${env_id}'.startswith('2')    # Linux
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${path}=    Identify Path To SD Card In Linux
        FOR    ${disk}    IN    @{path}
            Check Read Write To External Drive In Linux    ${disk}
        END
        Exit From Root User
    ELSE IF    '${env_id}'.startswith('3')    # Windows
        Login To Windows
        ${drive_letter}=    Identify Path To SD Card In Windows
        Check Read Write To External Drive In Windows    ${drive_letter}
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Usb Type-C Pd Current Limiting
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    ${env_id} != ${ENV_ID_QUBES}
        Ensure ME State    ${me_state}
        Power On
    END
    IF    '${env_id}'.startswith('2')    # Linux
        IF    ${env_id} == ${ENV_ID_QUBES}
            Execute Manual Step    [1/8] Enter BIOS/UEFI and set Intel ME to Disabled . Save & reboot DUT.
            Execute Manual Step    [2/8] Prepare USB-C PD meter.
            Execute Manual Step    [3/8] Ensure no other USB devices are connected.
            Execute Manual Step    [4/8] Connect charger/dock to PD meter. Verify PD profile is negotiated correctly.
            Execute Manual Step    [5/8] Connect PD meter to DUT. Observe initial power draw.
            Execute Manual Step    [6/8] After QubesOS boots, record idle power draw.
            Execute Manual Step    [7/8] Start CPU stress load in a test VM (e.g. stress-ng). Observe the power draw.
            Execute Manual Step    [8/8] Verify DUT does not exceed charger PD limits (voltage/current/wattage).
            Log To Console    USB-C PD current limiting test completed
        ELSE
            Fail    Not implemented on ENV_ID ${env_id}
        END
    ELSE
        Fail    Not implemented on ENV_ID ${env_id}
    END

Docking Station Detection After Coldboot
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        Log To Console    Cold boot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            ${out_before_reboot}=    Execute Linux Command    uptime --since
            WHILE    '${out_before_reboot}' == '${out_after_reboot}'
                Power Cycle On
                Login To Linux
                Switch To Root User
                ${out_after_reboot}=    Execute Linux Command    uptime --since
                Detect Docking Station In Linux    ${dock_name}
            END
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Warmboot
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    Skip If
    ...    not ${RTC_BOOT_SUPPORT} and ${INCLUDE_TAGS} is not ${None} and 'semiauto' not in ${INCLUDE_TAGS}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Log To Console    Warm boot iteration ${iteration+1}/${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        TRY
            ${out_before_reboot}=    Execute Linux Command    uptime --since
            WHILE    '${out_before_reboot}' == '${out_after_reboot}'
                Perform Warmboot Using Rtcwake
                Login To Linux
                Switch To Root User
                ${out_after_reboot}=    Execute Linux Command    uptime --since
                Detect Docking Station In Linux    ${dock_name}
            END
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Reboot
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Log To Console    Reboot iteration ${iteration+1}/${STABILITY_DETECTION_REBOOT_ITERATIONS}
        TRY
            Execute Reboot Command
            Boot System Or From Connected Disk    ${env_id}
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}    ${platform_sleep_type}=${EMPTY}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Log To Console
        ...    Suspend ${platform_sleep_type} iteration ${iteration+1}/${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Perform Suspend Test Using FWTS
        TRY
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT    message
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION}+1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend (S0Ix)
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Docking Station Detection After Suspend    ${env_id}    ${me_state}    ${dock_name}    S0Ix

Docking Station Detection After Suspend (S3)
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Docking Station Detection After Suspend    ${env_id}    ${me_state}    ${dock_name}    S3

Docking Station Detection After Coldboot Then Hotplug
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    ${out_before_reboot}=    Execute Linux Command    uptime --since
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    WHILE    '${out_before_reboot}' == '${out_after_reboot}'
        Log To Console    Coldboot the DUT manually
        # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
        Pause Execution In Console    Do power cut-off, power the device back up and press ENTER.
        Power On
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out_after_reboot}=    Execute Linux Command    uptime --since
        Run Keyword And Expect Error
        ...    * does not contain *
        ...    Detect Docking Station In Linux
        ...    ${dock_name}
    END
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        Log To Console    Hotplug after Cold boot iteration ${iteration+1}/${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Disconnect docking station ${dock_name} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${dock_name}
            Pause Execution In Console    Connect docking station ${dock_name} and press ENTER.
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Warmboot Then Hotplug
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    ${out_after_reboot}=    Execute Linux Command    uptime --since
    ${out_before_reboot}=    Execute Linux Command    uptime --since
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    WHILE    '${out_before_reboot}' == '${out_after_reboot}'
        Perform Warmboot Using Rtcwake
        Pause Execution In Console    Press power button on platform and press ENTER.
        Power On
        Boot System Or From Connected Disk    ${env_id}
        Login To Linux
        Switch To Root User
        ${out_after_reboot}=    Execute Linux Command    uptime --since
        Run Keyword And Expect Error
        ...    * does not contain *
        ...    Detect Docking Station In Linux
        ...    ${dock_name}
    END
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        Log To Console    Hotplug after Warm boot iteration ${iteration+1}/${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Disconnect docking station ${dock_name} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${dock_name}
            Pause Execution In Console    Connect docking station ${dock_name} and press ENTER.
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Reboot Then Hotplug
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    Execute Reboot Command
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Log To Console    Hotplug after Reboot iteration ${iteration+1}/${STABILITY_DETECTION_REBOOT_ITERATIONS}
        TRY
            Pause Execution In Console    Disconnect docking station ${dock_name} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${dock_name}
            Pause Execution In Console    Connect docking station ${dock_name} and press ENTER.
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend Then Hotplug
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}    ${platform_sleep_type}=${EMPTY}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Pause Execution In Console    Please make sure the docking station is disconnected and press ENTER
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Run Keyword And Expect Error    * does not contain *    Detect Docking Station In Linux    ${dock_name}
    VAR    ${FAILED_DETECTION}=    0    scope=GLOBAL
    Perform Suspend Test Using FWTS
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Log To Console
        ...    Hotplug after Suspend ${platform_sleep_type} iteration ${iteration+1}/${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        TRY
            Pause Execution In Console    Disconnect docking station ${dock_name} and press ENTER.
            Run Keyword And Expect Error
            ...    * does not contain *
            ...    Detect Docking Station In Linux
            ...    ${dock_name}
            Pause Execution In Console    Connect docking station ${dock_name} and press ENTER.
            Detect Docking Station In Linux    ${dock_name}
        EXCEPT    message
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION}+1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend Then Hotplug (S0Ix)
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Docking Station Detection After Suspend    ${env_id}    ${me_state}    ${dock_name}    S0Ix

Docking Station Detection After Suspend Then Hotplug (S3)
    [Arguments]    ${env_id}    ${me_state}    ${dock_name}
    IF    not '${env_id}'.startswith('2')
        Fail    Not implemented on ENV_ID ${env_id}
    END
    Ensure ME State    ${me_state}
    Docking Station Detection After Suspend    ${env_id}    ${me_state}    ${dock_name}    S3

Pause Execution In Console
    [Documentation]    Pauses execution until user press ENTER.
    [Arguments]    ${message}= Press ENTER to continue...
    Run    notify-send "Please execute Manual Step in ${TEST_NAME}"    # GUI message
    Run    echo -ne '\007'    # ASCII BEL (\007)
    Log To Console    ${message}
    Run    read ignore
    Log To Console    Manual step confirmed
