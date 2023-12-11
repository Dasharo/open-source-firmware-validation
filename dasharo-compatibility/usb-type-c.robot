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
UTC004.001 USB Type-C Display output (semi-automatic)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${CLEVO_USB_C_HUB}
    Exit From Root User

UTC005.001 - Docking station HDMI display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC005.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check Docking Station HDMI In Linux
    Exit From Root User

UTC005.002 - Docking station HDMI display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC005.002 not supported
    Power On
    Login To Windows
    Check Docking Station HDMI Windows

UTC006.001 - Docking station DP display in OS (Ubuntu 20.04)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC006.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check Docking Station DP In Linux
    Exit From Root User

UTC006.002 - Docking station DP display in OS (Windows 11)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC006.002 not supported
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.002 not supported
    Power On
    Login To Windows
    Check Docking Station DP Windows

UTC008.001 Docking station detection after coldboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.001 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC008.002 Docking station detection after coldboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.002 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC008.003 Docking station detection after coldboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC008.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC008.003 not supported
    Docking Station Detection After Coldboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC009.001 Docking station detection after warmboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.001 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC009.002 Docking station detection after warmboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.002 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC009.003 Docking station detection after warmboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC009.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC009.003 not supported
    Docking Station Detection After Warmboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC010.001 Docking station detection after reboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.001 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.E

UTC010.002 Docking station detection after reboot (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.002 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UMD05 Pro Rev.C1

UTC010.003 Docking station detection after reboot (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC010.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC010.003 not supported
    Docking Station Detection After Reboot (Ubuntu 22.04)    WL-UG69PD2 Rev.A1

UTC011.001 Docking station detection after suspend (Ubuntu 22.04) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.001 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.001 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    ${EMPTY}    WL-UMD05 Pro Rev.E

UTC011.002 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.002 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.002 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    S0ix    WL-UMD05 Pro Rev.E

UTC011.003 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.003 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.003 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    S3    WL-UMD05 Pro Rev.E

UTC011.004 Docking station detection after suspend (Ubuntu 22.04) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.004 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.004 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.004 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    ${EMPTY}    WL-UMD05 Pro Rev.C1

UTC011.005 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.005 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.005 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    S0ix    WL-UMD05 Pro Rev.C1

UTC011.006 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.006 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.006 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.006 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    S3    WL-UMD05 Pro Rev.C1

UTC011.007 Docking station detection after suspend (Ubuntu 22.04) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.007 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.007 not supported
    Docking Station Detection After Suspend (Ubuntu 22.04)    ${EMPTY}    WL-UG69PD2 Rev.A1

UTC011.008 Docking station detection after suspend (Ubuntu 22.04) (S0ix) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.008 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.008 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.008 not supported
    Set Platform Sleep Type    S0ix
    Docking Station Detection After Suspend (Ubuntu 22.04)    S0ix    WL-UG69PD2 Rev.A1

UTC011.009 Docking station detection after suspend (Ubuntu 22.04) (S3) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC011.009 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC011.009 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC011.009 not supported
    Set Platform Sleep Type    S3
    Docking Station Detection After Suspend (Ubuntu 22.04)    S3    WL-UG69PD2 Rev.A1

UTC012.002 USB devices recognition (Ubuntu 22.04)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Linux OS.
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC012.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC001.012 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    SanDisk
    Exit From Root User

UTC012.003 USB devices recognition (Windows 11)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Windows OS.
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC012.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC012.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    Should Contain    ${out}    OK${SPACE*9}DiskDrive${SPACE*8}USB${SPACE*2}SanDisk

UTC013.002 USB keyboard detection (Ubuntu 22.04)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Linux OS.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC013.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC013.002 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${DEVICE_USB_KEYBOARD}
    Exit From Root User

UTC013.003 USB keyboard detection (Windows 11)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Windows OS.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC013.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC013.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    Should Contain    ${out}    Description${SPACE*17}: USB Input Device    strip_spaces=True

UTC014.001 Ethernet connection (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    Ubuntu 22.04.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC014.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC014.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Internet Connection On Linux
    Exit From Root User

UTC014.001 Ethernet connection (Windows 11)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    Windows 11.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC014.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC014.002 not supported
    Power On
    Login To Windows
    Check Internet Connection On Windows

UTC015.001 Audio recognition (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into the
    ...    docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC015.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC015.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${EXTERNAL_HEADSET}
    Exit From Root User

UTC18.001 Docking Station SD Card reader detection (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC18.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC18.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    pattern=*SD*
    Exit From Root User

UTC018.002 Docking Station SD Card reader detection (Windows 11)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC018.001 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC018.001 not supported
    Power On
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

UTC019.001 Docking Station SD Card read/write (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC019.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC019.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${path}=    Identify Path To SD Card In Linux
    FOR    ${disk}    IN    @{path}
        Check Read Write To External Drive In Linux    ${disk}
    END
    Exit From Root User

UTC019.002 Docking Station SD Card read/write (Windows 11)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC019.001 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC019.001 not supported
    Power On
    Login To Windows
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}

UTC021.001 USB Type-C laptop charging (Ubuntu 22.04)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port.
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC021.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC021.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    Check Charging State In Linux
    Exit From Root User

UTC021.002 USB Type-C laptop charging (Windows 11)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port.
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC021.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC021.002 not supported
    Power On
    Login To Windows
    Check Charging State In Windows


*** Keywords ***
Docking Station Detection After Coldboot (Ubuntu 22.04)
    # [Arguments]    ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux (WL-UMD05 Pro)
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_COLDBOOT_ITERATIONS}
        TRY
            Log To Console    Coldboot the DUT manually
            # coldboot - msi ./sonoff, protectli RteCtrl -rel, novacustom ???
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    60s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux (WL-UMD05 Pro)
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Warmboot (Ubuntu 22.04)
    # [Arguments]    ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux (WL-UMD05 Pro)
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_WARMBOOT_ITERATIONS}
        TRY
            Log To Console    Warmboot the DUT manually
            # warmboot - msi rte, protectli novacustom ???
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    60s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux (WL-UMD05 Pro)
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Reboot (Ubuntu 22.04)
    # [Arguments]    ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Docking Station In Linux (WL-UMD05 Pro)
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        TRY
            Write Into Terminal    reboot
            IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    Sleep    45s
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux (WL-UMD05 Pro)
            Exit From Root User
        EXCEPT
            ${failed_detection}=    Evaluate    ${FAILED_DETECTION} + 1
            Power On
            Login To Linux
            Switch To Root User
            Detect Docking Station In Linux (WL-UMD05 Pro)
        END
    END
    IF    '${failed_detection}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${failed_detection} iterations failed.
    END
    Log To Console    \nAll iterations passed.

Docking Station Detection After Suspend (Ubuntu 22.04)
    [Arguments]    ${platform_sleep_type}=${EMPTY}    # ${docking_station_model}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    Switch To Root User
    Detect Or Install FWTS
    Detect Docking Station In Linux (WL-UMD05 Pro)
    Set Global Variable    ${FAILED_DETECTION}    0
    FOR    ${iteration}    IN RANGE    0    ${STABILITY_DETECTION_SUSPEND_ITERATIONS}
        Perform Suspend Test Using FWTS
        TRY
            Detect Docking Station In Linux (WL-UMD05 Pro)
        EXCEPT    message
            Evaluate    ${FAILED_DETECTION}=    ${FAILED_DETECTION}+1
        END
    END
    IF    '${FAILED_DETECTION}' > '${ALLOWED_DOCKING_STATION_DETECT_FAILS}'
        FAIL    \n ${FAILED_DETECTION} iterations failed.
    END
    Log To Console    \nAll iterations passed.
