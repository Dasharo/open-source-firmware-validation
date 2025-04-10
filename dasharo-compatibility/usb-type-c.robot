*** Comments ***
# robocop: disable=too-many-test-cases


*** Settings ***
Resource            ../keywords.robot
Resource            ../lib/utc.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
...                     AND
...                     Prepare UTC Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
# Not automated
# UTC101.001 USB Type-A charging capability (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC103.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC115.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC117.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC105.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC105.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC105.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC107.201 USB Type-C Display output (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC107.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC107.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC107.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC109.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC109.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC109.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC109.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC111.201 USB Type-C docking station DP display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC111.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC111.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC111.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC113.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC113.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC113.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC115.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC115.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC115.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC117.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC117.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC117.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC119.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC119.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC119.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC121.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC121.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC121.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC121.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC123.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC123.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC123.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC123.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC125.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC125.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC125.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC127.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC127.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC127.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC129.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC129.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC129.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC129.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC131.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC131.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC131.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC131.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC133.201 USB Type-C PD current limiting (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC133.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC133.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC135.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC135.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC135.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC135.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC137.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC137.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC137.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC137.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC139.201 Docking station detection after reboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC139.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC139.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC139.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC141.201 Docking station detection after suspend (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC141.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC141.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC141.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC141.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC143.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC143.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC143.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC143.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC143.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC145.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC145.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC145.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC145.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC145.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC147.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC147.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC147.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC147.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC149.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC149.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC149.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC151.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC151.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC151.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC153.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC153.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC153.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC155.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC155.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC155.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC157.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC157.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC157.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC105.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC105.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC107.202 USB Type-C Display output (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC107.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC107.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC109.202 USB Type-C docking station HDMI display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC109.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC109.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC111.202 USB Type-C docking station DP display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC111.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC111.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC113.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC113.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC115.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC115.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC117.202 USB Type-C docking station USB keyboard (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC117.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC119.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC119.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC121.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC121.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC121.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC123.202 USB Type-C docking station audio recognition (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC123.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC123.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC125.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC125.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC127.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC127.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC129.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC129.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC129.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC131.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC131.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC131.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC133.202 USB Type-C PD current limiting (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC133.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC135.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC135.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC135.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC137.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC137.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC137.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC139.202 Docking station detection after reboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC139.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC139.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC141.202 Docking station detection after suspend (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC141.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC141.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC141.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC143.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC143.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC143.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC143.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC145.202 Docking station detection after suspend (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC145.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC145.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC145.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC147.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC147.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC147.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC149.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC149.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC151.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC151.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC153.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC153.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC155.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC155.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC157.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC157.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC105.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC105.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC109.301 USB Type-C docking station HDMI display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC109.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC109.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC111.301 USB Type-C docking station DP display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC111.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC111.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC113.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC113.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC115.301 USB Type-C docking station USB devices recognition (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC115.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC117.301 USB Type-C docking station USB keyboard (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC117.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC119.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC119.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC121.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC121.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC121.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC125.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC125.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC127.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC127.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC129.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC129.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC129.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC131.301 USB Type-C docking station SD Card read/write (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC131.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC131.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC133.301 USB Type-C PD current limiting (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC133.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC102.001 USB Type-A charging capability (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC104.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC116.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC118.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC106.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC106.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC106.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC108.201 USB Type-C Display output (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC108.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC108.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC108.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC110.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC110.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC110.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC110.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC112.201 USB Type-C docking station DP display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC112.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC112.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC112.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC114.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC114.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC114.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC116.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC116.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC116.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC118.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC118.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC118.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC120.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC120.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC120.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC122.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC122.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC122.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC122.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC124.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC124.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC124.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC124.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC126.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC126.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC126.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC128.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC128.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC128.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC130.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC130.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC130.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC130.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC132.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC132.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC132.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC132.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC134.201 USB Type-C PD current limiting (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC134.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC134.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC136.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC136.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC136.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC136.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC138.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC138.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC138.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC138.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC140.201 Docking station detection after reboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC140.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC140.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC140.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC142.201 Docking station detection after suspend (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC142.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC142.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC142.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC142.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC144.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC144.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC144.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC144.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC144.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC146.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC146.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC146.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC146.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC146.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC148.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC148.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC148.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC148.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC150.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC150.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC150.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC152.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC152.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC152.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC154.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC154.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC154.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC156.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC156.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC156.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC158.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC158.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC158.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC106.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC106.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC108.202 USB Type-C Display output (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC108.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC108.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC110.202 USB Type-C docking station HDMI display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC110.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC110.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC112.202 USB Type-C docking station DP display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC112.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC112.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC114.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC114.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC116.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC116.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC118.202 USB Type-C docking station USB keyboard (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC118.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC120.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC120.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC122.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC122.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC122.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC124.202 USB Type-C docking station audio recognition (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC124.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC124.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC126.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC126.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC128.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC128.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC130.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC130.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC130.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC132.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC132.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC132.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC134.202 USB Type-C PD current limiting (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC134.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC136.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC136.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC136.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC138.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC138.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC138.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC140.202 Docking station detection after reboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC140.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC140.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC142.202 Docking station detection after suspend (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC142.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC142.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC142.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC144.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC144.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC144.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC144.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC146.202 Docking station detection after suspend (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC146.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC146.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC146.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC148.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC148.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC148.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC150.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC150.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC152.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC152.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC154.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC154.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC156.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC156.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC158.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC158.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC106.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC106.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC110.301 USB Type-C docking station HDMI display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC110.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC110.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC112.301 USB Type-C docking station DP display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC112.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC112.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC114.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC114.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC116.301 USB Type-C docking station USB devices recognition (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC116.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC118.301 USB Type-C docking station USB keyboard (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC118.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC120.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC120.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC122.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC122.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC122.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC126.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC126.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC128.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC128.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC130.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC130.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC130.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC132.301 USB Type-C docking station SD Card read/write (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC132.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC132.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC134.301 USB Type-C PD current limiting (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC134.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

# Not automated
# UTC201.001 USB Type-A charging capability (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC203.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC215.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC217.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC205.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC205.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC205.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC207.201 USB Type-C Display output (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC207.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC207.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC207.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC209.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC209.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC209.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC209.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC211.201 USB Type-C docking station DP display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC211.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC211.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC211.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC213.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC213.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC213.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC215.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC215.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC215.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC217.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC217.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC217.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC219.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC219.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC219.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC221.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC221.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC221.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC221.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC223.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC223.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC223.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC223.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC225.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC225.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC225.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC227.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC227.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC227.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC229.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC229.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC229.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC229.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC231.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC231.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC231.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC231.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC233.201 USB Type-C PD current limiting (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC233.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC233.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC235.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC235.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC235.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC235.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC237.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC237.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC237.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC237.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC239.201 Docking station detection after reboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC239.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC239.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC239.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC241.201 Docking station detection after suspend (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC241.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC241.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC241.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC241.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC243.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC243.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC243.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC243.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC243.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC245.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC245.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC245.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC245.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC245.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC247.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC247.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC247.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC247.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC249.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC249.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC249.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC251.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC251.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC251.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC253.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC253.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC253.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC255.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC255.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC255.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC257.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC257.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC257.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC205.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC205.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC207.202 USB Type-C Display output (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC207.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC207.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC209.202 USB Type-C docking station HDMI display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC209.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC209.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC211.202 USB Type-C docking station DP display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC211.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC211.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC213.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC213.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC215.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC215.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC217.202 USB Type-C docking station USB keyboard (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC217.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC219.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC219.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC221.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC221.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC221.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC223.202 USB Type-C docking station audio recognition (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC223.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC223.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC225.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC225.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC227.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC227.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC229.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC229.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC229.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC231.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC231.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC231.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC233.202 USB Type-C PD current limiting (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC233.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC235.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC235.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC235.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC237.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC237.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC237.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC239.202 Docking station detection after reboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC239.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC239.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC241.202 Docking station detection after suspend (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC241.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC241.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC241.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC243.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC243.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC243.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC243.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC245.202 Docking station detection after suspend (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC245.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC245.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC245.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC247.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC247.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC247.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC249.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC249.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC251.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC251.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC253.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC253.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC255.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC255.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC257.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC257.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC205.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC205.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC209.301 USB Type-C docking station HDMI display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC209.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC209.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC211.301 USB Type-C docking station DP display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC211.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC211.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC213.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC213.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC215.301 USB Type-C docking station USB devices recognition (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC215.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC217.301 USB Type-C docking station USB keyboard (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC217.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC219.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC219.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC221.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC221.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC221.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC225.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC225.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC227.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC227.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC229.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC229.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC229.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC231.301 USB Type-C docking station SD Card read/write (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC231.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC231.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC233.301 USB Type-C PD current limiting (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC233.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC202.001 USB Type-A charging capability (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC204.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC216.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC218.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC206.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC206.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC206.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC208.201 USB Type-C Display output (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC208.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC208.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC208.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC210.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC210.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC210.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC210.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC212.201 USB Type-C docking station DP display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC212.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC212.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC212.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC214.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC214.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC214.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC216.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC216.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC216.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC218.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC218.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC218.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC220.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC220.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC220.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC222.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC222.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC222.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC222.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC224.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC224.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC224.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC224.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC226.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC226.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC226.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC228.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC228.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC228.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC230.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC230.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC230.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC230.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC232.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC232.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC232.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC232.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC234.201 USB Type-C PD current limiting (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC234.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC234.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC236.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC236.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC236.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC236.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC238.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC238.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC238.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC238.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC240.201 Docking station detection after reboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC240.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC240.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC240.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC242.201 Docking station detection after suspend (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC242.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC242.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC242.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC242.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC244.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC244.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC244.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC244.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC244.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC246.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC246.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC246.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC246.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC246.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC248.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC248.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC248.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC248.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC250.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC250.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC250.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC252.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC252.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC252.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC254.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC254.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC254.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC256.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC256.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC256.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC258.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC258.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC258.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC206.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC206.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC208.202 USB Type-C Display output (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC208.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC208.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC210.202 USB Type-C docking station HDMI display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC210.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC210.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC212.202 USB Type-C docking station DP display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC212.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC212.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC214.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC214.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC216.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC216.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC218.202 USB Type-C docking station USB keyboard (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC218.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC220.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC220.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC222.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC222.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC222.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC224.202 USB Type-C docking station audio recognition (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC224.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC224.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC226.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC226.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC228.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC228.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC230.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC230.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC230.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC232.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC232.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC232.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC234.202 USB Type-C PD current limiting (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC234.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC236.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC236.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC236.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC238.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC238.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC238.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC240.202 Docking station detection after reboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC240.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC240.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC242.202 Docking station detection after suspend (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC242.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC242.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC242.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC244.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC244.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC244.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC244.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC246.202 Docking station detection after suspend (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC246.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC246.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC246.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC248.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC248.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC248.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC250.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC250.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC252.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC252.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC254.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC254.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC256.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC256.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC258.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC258.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC206.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC206.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC210.301 USB Type-C docking station HDMI display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC210.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC210.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC212.301 USB Type-C docking station DP display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC212.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC212.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC214.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC214.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC216.301 USB Type-C docking station USB devices recognition (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC216.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC218.301 USB Type-C docking station USB keyboard (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC218.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC220.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC220.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC222.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC222.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC222.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC226.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC226.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC228.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC228.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC230.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC230.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC230.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC232.301 USB Type-C docking station SD Card read/write (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC232.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC232.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC234.301 USB Type-C PD current limiting (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC234.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

# Not automated
# UTC301.001 USB Type-A charging capability (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC303.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC315.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC317.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC305.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC305.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC305.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC307.201 USB Type-C Display output (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC307.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC307.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC307.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC309.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC309.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC309.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC309.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC311.201 USB Type-C docking station DP display (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC311.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC311.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC311.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC313.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC313.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC313.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC315.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC315.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC315.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC317.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC317.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC317.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC319.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC319.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC319.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC321.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC321.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC321.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC321.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC323.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC323.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC323.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC323.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC325.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC325.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC325.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC327.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC327.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC327.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC329.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC329.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC329.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC329.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC331.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC331.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC331.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC331.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC333.201 USB Type-C PD current limiting (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC333.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC333.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC335.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC335.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC335.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC335.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC337.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC337.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC337.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC337.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC339.201 Docking station detection after reboot (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC339.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC339.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC339.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC341.201 Docking station detection after suspend (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC341.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC341.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC341.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC341.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC343.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC343.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC343.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC343.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC343.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC345.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC345.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC345.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC345.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC345.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC347.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC347.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC347.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC347.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC349.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC349.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC349.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC351.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC351.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC351.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC353.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC353.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC353.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC355.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC355.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC355.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC357.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC357.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC357.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC305.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC305.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC307.202 USB Type-C Display output (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC307.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC307.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC309.202 USB Type-C docking station HDMI display (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC309.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC309.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC311.202 USB Type-C docking station DP display (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC311.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC311.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC313.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC313.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC315.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC315.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC317.202 USB Type-C docking station USB keyboard (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC317.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC319.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC319.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC321.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC321.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC321.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC323.202 USB Type-C docking station audio recognition (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC323.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC323.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC325.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC325.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC327.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC327.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC329.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC329.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC329.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC331.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC331.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC331.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC333.202 USB Type-C PD current limiting (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC333.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC335.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC335.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC335.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC337.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC337.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC337.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC339.202 Docking station detection after reboot (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC339.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC339.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC341.202 Docking station detection after suspend (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC341.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC341.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC341.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC343.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC343.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC343.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC343.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC345.202 Docking station detection after suspend (S3) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC345.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC345.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC345.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC347.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC347.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC347.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC349.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC349.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC351.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC351.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC353.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC353.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC355.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC355.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC357.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC357.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC305.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC305.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC309.301 USB Type-C docking station HDMI display (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC309.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC309.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC311.301 USB Type-C docking station DP display (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC311.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC311.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC313.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC313.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC315.301 USB Type-C docking station USB devices recognition (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC315.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC317.301 USB Type-C docking station USB keyboard (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC317.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC319.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC319.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC321.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC321.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC321.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC325.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC325.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC327.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC327.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC329.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC329.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC329.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC331.301 USB Type-C docking station SD Card read/write (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC331.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC331.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC333.301 USB Type-C PD current limiting (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC333.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC302.001 USB Type-A charging capability (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test verifies that the USB-A ports are able to provide
#    ...    charging to a connected smartphone.
#    Usb Type-A Charging Capability    001    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC304.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test verifies that the Thunderbolt 4 port is able
#    ...    to provide charging to a USB Type-C accessory.
#    Thunderbolt 4 Usb Type-C Power Output    001    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC316.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the external USB devices connected to the
#    ...    docking station are detected correctly
#    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.001 not supported
#    Usb Type-C Docking Station Usb Devices Recognition    001    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC318.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the external USB keyboard connected to the
#    ...    docking station is detected correctly.
#    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.001 not supported
#    Usb Type-C Docking Station Usb Keyboard    001    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC306.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC306.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC306.201 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC308.201 USB Type-C Display output (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC308.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC308.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC308.201 not supported
    Usb Type-C Display Output    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC310.201 USB Type-C docking station HDMI display (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC310.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC310.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC310.201 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC312.201 USB Type-C docking station DP display (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC312.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC312.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC312.201 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC314.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC314.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC314.201 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC316.201 USB Type-C docking station USB devices recognition (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC316.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC316.201 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC318.201 USB Type-C docking station USB keyboard (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC318.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC318.201 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC320.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC320.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC320.201 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC322.201 USB Type-C docking station Ethernet connection (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC322.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC322.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC322.201 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC324.201 USB Type-C docking station audio recognition (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC324.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC324.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC324.201 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC326.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC326.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC326.201 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC328.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.201 not supported
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC328.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC328.201 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC330.201 USB Type-C docking station SD Card reader detection (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC330.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC330.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC330.201 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC332.201 USB Type-C docking station SD Card read/write (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC332.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC332.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC332.201 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC334.201 USB Type-C PD current limiting (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC334.201 not supported
#    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC334.201 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC336.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC336.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC336.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC336.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC338.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC338.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC338.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC338.201 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC340.201 Docking station detection after reboot (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC340.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC340.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC340.201 not supported
    Docking Station Detection After Reboot    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC342.201 Docking station detection after suspend (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC342.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC342.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC342.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC342.201 not supported
    Docking Station Detection After Suspend    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC344.201 Docking station detection after suspend (S0ix) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC344.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC344.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC344.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC344.201 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC346.201 Docking station detection after suspend (S3) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC346.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC346.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC346.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC346.201 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC348.201 Docking station detection after coldboot then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC348.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC348.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC348.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC350.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC350.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC350.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC352.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC352.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC352.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC354.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC354.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC354.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC356.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC356.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC356.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC358.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC358.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC358.201 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC306.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC306.202 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC308.202 USB Type-C Display output (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC308.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC308.202 not supported
    Usb Type-C Display Output    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC310.202 USB Type-C docking station HDMI display (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC310.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC310.202 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC312.202 USB Type-C docking station DP display (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC312.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC312.202 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC314.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC314.202 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC316.202 USB Type-C docking station USB devices recognition (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC316.202 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC318.202 USB Type-C docking station USB keyboard (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC318.202 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC320.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC320.202 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC322.202 USB Type-C docking station Ethernet connection (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC322.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC322.202 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC324.202 USB Type-C docking station audio recognition (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC324.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC324.202 not supported
    Usb Type-C Docking Station Audio Recognition    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC326.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC326.202 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC328.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.202 not supported
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC328.202 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC330.202 USB Type-C docking station SD Card reader detection (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC330.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC330.202 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC332.202 USB Type-C docking station SD Card read/write (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC332.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC332.202 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC334.202 USB Type-C PD current limiting (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC334.202 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC336.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none'    UTC336.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC336.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC338.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC338.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC338.202 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC340.202 Docking station detection after reboot (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC340.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC340.202 not supported
    Docking Station Detection After Reboot    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC342.202 Docking station detection after suspend (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC342.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC342.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC342.202 not supported
    Docking Station Detection After Suspend    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC344.202 Docking station detection after suspend (S0ix) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC344.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC344.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC344.202 not supported
    Docking Station Detection After Suspend (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC346.202 Docking station detection after suspend (S3) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC346.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC346.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC346.202 not supported
    Docking Station Detection After Suspend (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC348.202 Docking station detection after coldboot then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none'    UTC348.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC348.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC350.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC350.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC352.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC352.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC354.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC354.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC356.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC356.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC358.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC358.202 not supported
    Skip If    not ${SEMI_AUTO}    semi auto test skipped: SEMI_AUTO==${SEMI_AUTO}
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC306.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    Check whether the DUT can be charged using a
#    ...    PD power supply connected to the docking station, which
#    ...    is connected to the USB Type-C port
#    ...    Previous IDs: UTC021.001 USB Type-C laptop charging (Ubuntu)
#    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC306.301 not supported
#    Usb Type-C Pd Power Input    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC310.301 USB Type-C docking station HDMI display (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_HDMI}    UTC310.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC310.301 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC312.301 USB Type-C docking station DP display (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC312.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC312.301 not supported
    Usb Type-C Docking Station Dp Display    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC314.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the three display
#    ...    simultaneously connected to the docking station is correctly
#    ...    recognized by the OPERATING_SYSTEM.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC314.301 not supported
#    Usb Type-C Docking Station Triple Display    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC316.301 USB Type-C docking station USB devices recognition (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC316.301 not supported
    Usb Type-C Docking Station Usb Devices Recognition    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC318.301 USB Type-C docking station USB keyboard (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC318.301 not supported
    Usb Type-C Docking Station Usb Keyboard    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC320.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the 1GB file can be
#    ...    transferred from the OPERATING_SYSTEM to the USB storage
#    ...    connected to the docking station.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC320.301 not supported
#    Usb Type-C Docking Station Upload 1Gb File On Usb Storage    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC322.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC322.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC322.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC326.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to playback audio recordings by using the external headset
#    ...    speakers connected to the docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC326.301 not supported
#    Usb Type-C Docking Station Audio Playback    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC328.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the audio subsystem is able
#    ...    to capture audio from external headset connected to the
#    ...    docking station.
#    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.301 not supported
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC328.301 not supported
#    Usb Type-C Docking Station Audio Capture    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC330.301 USB Type-C docking station SD Card reader detection (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC330.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC330.301 not supported
    Usb Type-C Docking Station Sd Card Reader Detection    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC332.301 USB Type-C docking station SD Card read/write (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC332.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC332.301 not supported
    Usb Type-C Docking Station Sd Card Read/Write    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

# Not automated
# UTC334.301 USB Type-C PD current limiting (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
#    [Documentation]    This test aims to verify that the power draw from a USB-C PD
#    ...    power supply does not exceed the limits of the power supply's
#    ...    specifications.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC334.301 not supported
#    Usb Type-C Pd Current Limiting    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1
