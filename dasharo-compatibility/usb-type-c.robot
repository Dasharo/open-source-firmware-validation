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
Resource            ../lib/me.robot
Resource            ../lib/docks.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
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

UTC004.005 USB Type-C Display output With Me Disabled(semi-automatic)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub
    ...    when Intel ME is disabled
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC004.002 not supported
    Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    Dasharo Intel ME menu not supported
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Not Be Equal As Strings    ${result}    Enabled
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${CLEVO_USB_C_HUB}
    Exit From Root User

UTC004.006 USB Type-C Display output With Me Enabled (semi-automatic)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub
    ...    when Intel ME is enabled
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    TMD004.003 not supported
    Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    Dasharo Intel ME menu not supported
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled
    ${out}=    List Devices In Linux    usb
    Should Contain    ${out}    ${CLEVO_USB_C_HUB}
    Exit From Root User

UTC005.001 - Docking station HDMI display in OS (DP Alt mode) (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC005.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check PCON On MST Hub In Linux
    Exit From Root User

UTC005.002 - Docking station HDMI display in OS (DP Alt mode) (Windows)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC005.002 not supported
    Power On
    Login To Windows
    Check Docking Station HDMI Windows

UTC005.003 - Docking station HDMI display in OS (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC005.003 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check Display Port On Hub In Linux    HDMI
    Exit From Root User

UTC005.005 Docking station HDMI display in OS with Me Disabled (Alt Mode) (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC005.005 not supported
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Not Be Equal As Strings    ${result}    Enabled
    Check Display Port On Hub In Linux    HDMI
    Exit From Root User

UTC005.007 Docking station HDMI display in OS with Me Enabled (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC005.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC005.007 not supported
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled
    Check Display Port On Hub In Linux    HDMI
    Exit From Root User

UTC006.001 - Docking station DP display in OS (DP Alt mode) (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC006.001 not supported
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check DP Port On MST Hub In Linux
    Exit From Root User

UTC006.002 - Docking station DP display in OS (DP Alt mode) (Windows)
    [Documentation]    This test aims to verify that the display connected with
    ...    the DisplayPort cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC006.002 not supported
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.002 not supported
    Power On
    Login To Windows
    Check Docking Station DP Windows

UTC006.003 - Docking station DP display in OS (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.003 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC006.003 not supported
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check Display Port On Hub In Linux    DP
    Exit From Root User

UTC006.005 Docking station DP display in OS with Me Disabled (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.005 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC006.005 not supported
    Set UEFI Option    MeMode    Disabled (HAP)
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Not Be Equal As Strings    ${result}    Enabled
    Check Display Port On Hub In Linux    DP
    Exit From Root User

UTC006.007 Docking station DP display in OS with Me Enabled (Ubuntu)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC006.007 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC006.007 not supported
    Set UEFI Option    MeMode    Enabled
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${result}=    Check ME Out
    Should Be Equal As Strings    ${result}    Enabled
    Check Display Port On Hub In Linux    DP
    Exit From Root User

UTC012.002 USB devices recognition (Ubuntu)
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

UTC012.003 USB devices recognition (Windows)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly in Windows OS.
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC012.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC012.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
    Should Contain    ${out}    OK${SPACE*9}DiskDrive${SPACE*8}USB${SPACE*2}SanDisk

UTC013.002 USB keyboard detection (Ubuntu)
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

UTC013.003 USB keyboard detection (Windows)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly by the Windows OS.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC013.003 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC013.003 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-CimInstance win32_KEYBOARD
    Should Contain    ${out}    Description${SPACE*17}: USB Input Device    strip_spaces=True

UTC014.001 Ethernet connection (Ubuntu)
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

UTC014.002 Ethernet connection (Windows)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    Windows 11.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC014.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC014.002 not supported
    Power On
    Login To Windows
    Check Internet Connection On Windows

UTC015.001 Audio recognition (Ubuntu)
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

UTC18.001 Docking Station SD Card reader detection (Ubuntu)
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

UTC018.002 Docking Station SD Card reader detection (Windows)
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

UTC019.001 Docking Station SD Card read/write (Ubuntu)
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

UTC019.002 Docking Station SD Card read/write (Windows)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC019.001 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC019.001 not supported
    Power On
    Login To Windows
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}

UTC021.001 USB Type-C laptop charging (Ubuntu)
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

UTC021.002 USB Type-C laptop charging (Windows)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port.
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC021.002 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC021.002 not supported
    Power On
    Login To Windows
    Check Charging State In Windows
