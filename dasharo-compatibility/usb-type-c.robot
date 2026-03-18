*** Comments ***
# robocop:off too-many-test-cases
# robocop:off file-too-long


*** Settings ***
Resource            ../keywords.robot
Resource            ../lib/utc.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
...                     AND
...                     Prepare UTC Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
UTC001.001 USB Type-A charging capability
    [Documentation]    This test verifies that the USB-A ports are able to provide
    ...    charging to a connected smartphone.
    [Tags]    semiauto
    Skip
    ...    UTC001.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC003.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Enabled)
    [Documentation]    This test verifies that the Thunderbolt 4 port is able
    ...    to provide charging to a USB Type-C accessory.
    [Tags]    semiauto
    Skip
    ...    UTC003.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC033.201 USB Type-C PD current limiting (Ubuntu) (ME: Enabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC033.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC033.201 not supported
    Skip
    ...    UTC033.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC033.202 USB Type-C PD current limiting (Fedora) (ME: Enabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC033.202 not supported
    Skip
    ...    UTC033.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC033.301 USB Type-C PD current limiting (Windows) (ME: Enabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC033.301 not supported
    Skip
    ...    UTC033.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC033.203 USB Type-C PD current limiting (Qubes OS) (ME: Enabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC033.203 not supported
    Usb Type-C Pd Current Limiting    ${ENV_ID_QUBES}    Enabled    none

UTC002.001 USB Type-A charging capability (Firmware) (ME: Disabled)
    [Documentation]    This test verifies that the USB-A ports are able to provide
    ...    charging to a connected smartphone.
    [Tags]    semiauto
    Skip
    ...    UTC002.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC004.001 Thunderbolt 4 USB Type-C power output (Firmware) (ME: Disabled)
    [Documentation]    This test verifies that the Thunderbolt 4 port is able
    ...    to provide charging to a USB Type-C accessory.
    [Tags]    semiauto
    Skip
    ...    UTC004.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC034.201 USB Type-C PD current limiting (Ubuntu) (ME: Disabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC034.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC034.201 not supported
    Skip
    ...    UTC034.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC034.202 USB Type-C PD current limiting (Fedora) (ME: Disabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC034.202 not supported
    Skip
    ...    UTC034.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC034.301 USB Type-C PD current limiting (Windows) (ME: Disabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC034.301 not supported
    Skip
    ...    UTC034.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC034.203 USB Type-C PD current limiting (Qubes OS) (ME: Disabled)
    [Documentation]    This test aims to verify that the power draw from a USB-C PD
    ...    power supply does not exceed the limits of the power supply's
    ...    specifications.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC034.203 not supported
    Usb Type-C Pd Current Limiting    ${ENV_ID_QUBES}    Disabled    none

UTC115.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.001 not supported
    Skip
    ...    UTC115.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC117.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.001 not supported
    Skip
    ...    UTC117.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC105.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC105.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC105.201 not supported
    Skip
    ...    UTC105.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC113.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC113.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC113.201 not supported
    Skip
    ...    UTC113.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC119.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC119.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC119.201 not supported
    Skip
    ...    UTC119.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC125.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC125.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC125.201 not supported
    Skip
    ...    UTC125.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC127.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC127.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC127.201 not supported
    Skip
    ...    UTC127.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC135.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC135.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC135.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC135.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC137.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC137.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC147.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC147.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC147.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC149.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC149.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC149.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC149.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC151.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC151.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC151.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC153.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC153.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC153.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC155.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC155.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC155.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC157.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC157.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC157.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.E

UTC105.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC105.202 not supported
    Skip
    ...    UTC105.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC113.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC113.202 not supported
    Skip
    ...    UTC113.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC119.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC119.202 not supported
    Skip
    ...    UTC119.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC125.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC125.202 not supported
    Skip
    ...    UTC125.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC127.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC127.202 not supported
    Skip
    ...    UTC127.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC135.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC135.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC135.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC137.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC137.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC147.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC147.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC149.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC149.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC149.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC151.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC151.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC153.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC153.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC155.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC155.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC157.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC157.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.E

UTC105.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC105.301 not supported
    Skip
    ...    UTC105.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC107.301 USB Type-C Display output (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC107.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC107.301 not supported
    Skip
    ...    UTC107.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC113.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC113.301 not supported
    Skip
    ...    UTC113.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC119.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC119.301 not supported
    Skip
    ...    UTC119.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC121.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC121.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC121.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.E

UTC123.301 USB Type-C docking station audio recognition (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC123.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC123.301 not supported
    Skip
    ...    UTC123.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC125.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC125.301 not supported
    Skip
    ...    UTC125.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC127.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC127.301 not supported
    Skip
    ...    UTC127.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC135.301 Docking station detection after coldboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC135.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC135.301 not supported
    Skip
    ...    UTC135.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC137.301 Docking station detection after warmboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC137.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC137.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC137.301 not supported
    Skip
    ...    UTC137.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC139.301 Docking station detection after reboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC139.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC139.301 not supported
    Skip
    ...    UTC139.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC141.301 Docking station detection after suspend (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC141.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC141.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC141.301 not supported
    Skip
    ...    UTC141.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC143.301 Docking station detection after suspend (S0ix) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC143.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC143.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC143.301 not supported
    Skip
    ...    UTC143.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC145.301 Docking station detection after suspend (S3) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC145.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC145.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC145.301 not supported
    Skip
    ...    UTC145.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC147.301 Docking station detection after coldboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC147.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC147.301 not supported
    Skip
    ...    UTC147.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC149.301 Docking station detection after warmboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC149.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC149.301 not supported
    Skip
    ...    UTC149.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC151.301 Docking station detection after reboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC151.301 not supported
    Skip
    ...    UTC151.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC153.301 Docking station detection after suspend then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC153.301 not supported
    Skip
    ...    UTC153.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC155.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC155.301 not supported
    Skip
    ...    UTC155.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC157.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC157.301 not supported
    Skip
    ...    UTC157.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC105.203 USB Type-C PD power input (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC105.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC105.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC107.203 USB Type-C Display output (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC107.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC107.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC109.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC109.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC109.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC111.203 USB Type-C docking station DP display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC111.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC111.203 not supported
    Skip
    ...    UTC111.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC113.203 USB Type-C docking station Triple display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC113.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC115.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC115.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC115.203 not supported
    Skip
    ...    UTC115.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC117.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC117.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC117.203 not supported
    Skip
    ...    UTC117.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC119.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC119.203 not supported
    Skip
    ...    UTC119.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC121.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC121.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC121.203 not supported
    Skip
    ...    UTC121.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC123.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC123.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC123.203 not supported
    Skip
    ...    UTC123.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC125.203 USB Type-C docking station audio playback (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC125.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC125.203 not supported
    Skip
    ...    UTC125.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC127.203 USB Type-C docking station audio capture (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC127.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC127.203 not supported
    Skip
    ...    UTC127.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC129.203 USB Type-C docking station SD Card reader detection (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC129.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC129.203 not supported
    Skip
    ...    UTC129.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC131.203 USB Type-C docking station SD Card read/write (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC131.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC131.203 not supported
    Skip
    ...    UTC131.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC135.203 Docking station detection after coldboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC135.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC135.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC135.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC137.203 Docking station detection after warmboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC137.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC137.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC137.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC139.203 Docking station detection after reboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC139.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC139.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.E

UTC141.203 Docking station detection after suspend (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC141.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC141.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC141.203 not supported
    Skip
    ...    UTC141.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC143.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC143.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC143.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC143.203 not supported
    Skip
    ...    UTC143.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC145.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC145.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC145.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC145.203 not supported
    Skip
    ...    UTC145.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC147.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC147.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC147.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC147.203 not supported
    Skip
    ...    UTC147.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC149.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC149.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC149.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC149.203 not supported
    Skip
    ...    UTC149.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC151.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC151.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC151.203 not supported
    Skip
    ...    UTC151.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC153.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC153.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC153.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC153.203 not supported
    Skip
    ...    UTC153.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC155.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC155.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC155.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC155.203 not supported
    Skip
    ...    UTC155.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC157.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC157.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC157.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC157.203 not supported
    Skip
    ...    UTC157.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC116.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.001 not supported
    Skip
    ...    UTC116.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC118.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.001 not supported
    Skip
    ...    UTC118.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC106.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC106.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC106.201 not supported
    Skip
    ...    UTC106.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC114.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC114.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC114.201 not supported
    Skip
    ...    UTC114.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC120.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC120.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC120.201 not supported
    Skip
    ...    UTC120.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC126.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC126.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC126.201 not supported
    Skip
    ...    UTC126.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC128.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC128.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC128.201 not supported
    Skip
    ...    UTC128.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC136.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC136.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC136.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC136.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC138.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC138.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC148.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC148.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC148.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC150.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC150.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC150.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC150.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC152.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC152.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC152.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC154.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC154.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC154.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC156.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC156.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC156.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC158.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC158.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC158.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.E

UTC106.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC106.202 not supported
    Skip
    ...    UTC106.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC114.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC114.202 not supported
    Skip
    ...    UTC114.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC120.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC120.202 not supported
    Skip
    ...    UTC120.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC126.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC126.202 not supported
    Skip
    ...    UTC126.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC128.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC128.202 not supported
    Skip
    ...    UTC128.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC136.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC136.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC136.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC138.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC138.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC148.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC148.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC150.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC150.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC150.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC152.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC152.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC154.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC154.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC156.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC156.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC158.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC158.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.E

UTC106.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC106.301 not supported
    Skip
    ...    UTC106.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC108.301 USB Type-C Display output (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC108.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC108.301 not supported
    Skip
    ...    UTC108.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC114.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC114.301 not supported
    Skip
    ...    UTC114.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC120.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC120.301 not supported
    Skip
    ...    UTC120.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC122.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC122.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC122.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.E

UTC124.301 USB Type-C docking station audio recognition (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC124.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC124.301 not supported
    Skip
    ...    UTC124.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC126.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC126.301 not supported
    Skip
    ...    UTC126.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC128.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC128.301 not supported
    Skip
    ...    UTC128.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC136.301 Docking station detection after coldboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC136.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC136.301 not supported
    Skip
    ...    UTC136.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC138.301 Docking station detection after warmboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC138.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC138.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC138.301 not supported
    Skip
    ...    UTC138.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC140.301 Docking station detection after reboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC140.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC140.301 not supported
    Skip
    ...    UTC140.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC142.301 Docking station detection after suspend (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC142.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC142.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC142.301 not supported
    Skip
    ...    UTC142.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC144.301 Docking station detection after suspend (S0ix) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC144.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC144.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC144.301 not supported
    Skip
    ...    UTC144.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC146.301 Docking station detection after suspend (S3) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC146.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC146.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC146.301 not supported
    Skip
    ...    UTC146.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC148.301 Docking station detection after coldboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC148.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC148.301 not supported
    Skip
    ...    UTC148.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC150.301 Docking station detection after warmboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC150.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC150.301 not supported
    Skip
    ...    UTC150.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC152.301 Docking station detection after reboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC152.301 not supported
    Skip
    ...    UTC152.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC154.301 Docking station detection after suspend then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC154.301 not supported
    Skip
    ...    UTC154.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC156.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC156.301 not supported
    Skip
    ...    UTC156.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC158.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC158.301 not supported
    Skip
    ...    UTC158.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC106.203 USB Type-C PD power input (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC106.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC106.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC108.203 USB Type-C Display output (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC108.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC108.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC110.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC110.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC110.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC112.203 USB Type-C docking station DP display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC112.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC112.203 not supported
    Skip
    ...    UTC112.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC114.203 USB Type-C docking station Triple display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC114.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC116.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC116.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC116.203 not supported
    Skip
    ...    UTC116.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC118.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC118.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC118.203 not supported
    Skip
    ...    UTC118.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC120.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC120.203 not supported
    Skip
    ...    UTC120.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC122.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC122.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC122.203 not supported
    Skip
    ...    UTC122.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC124.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC124.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC124.203 not supported
    Skip
    ...    UTC124.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC126.203 USB Type-C docking station audio playback (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC126.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC126.203 not supported
    Skip
    ...    UTC126.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC128.203 USB Type-C docking station audio capture (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC128.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC128.203 not supported
    Skip
    ...    UTC128.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC130.203 USB Type-C docking station SD Card reader detection (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC130.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC130.203 not supported
    Skip
    ...    UTC130.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC132.203 USB Type-C docking station SD Card read/write (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC132.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC132.203 not supported
    Skip
    ...    UTC132.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC136.203 Docking station detection after coldboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC136.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC136.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC136.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC138.203 Docking station detection after warmboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC138.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC138.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC138.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC140.203 Docking station detection after reboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC140.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC140.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.E

UTC142.203 Docking station detection after suspend (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC142.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC142.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC142.203 not supported
    Skip
    ...    UTC142.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC144.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC144.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC144.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC144.203 not supported
    Skip
    ...    UTC144.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC146.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC146.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC146.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC146.203 not supported
    Skip
    ...    UTC146.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC148.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC148.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC148.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC148.203 not supported
    Skip
    ...    UTC148.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC150.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC150.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC150.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC150.203 not supported
    Skip
    ...    UTC150.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC152.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC152.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC152.203 not supported
    Skip
    ...    UTC152.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC154.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC154.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC154.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC154.203 not supported
    Skip
    ...    UTC154.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC156.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC156.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC156.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC156.203 not supported
    Skip
    ...    UTC156.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC158.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.E)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC158.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC158.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC158.203 not supported
    Skip
    ...    UTC158.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC215.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.001 not supported
    Skip
    ...    UTC215.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC217.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.001 not supported
    Skip
    ...    UTC217.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC205.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC205.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC205.201 not supported
    Skip
    ...    UTC205.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC213.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC213.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC213.201 not supported
    Skip
    ...    UTC213.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC219.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC219.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC219.201 not supported
    Skip
    ...    UTC219.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC225.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC225.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC225.201 not supported
    Skip
    ...    UTC225.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC227.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC227.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC227.201 not supported
    Skip
    ...    UTC227.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC235.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC235.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC235.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC235.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC237.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC237.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC247.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC247.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC247.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC249.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC249.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC249.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC249.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC251.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC251.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC251.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC253.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC253.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC253.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC255.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC255.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC255.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC257.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC257.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC257.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UMD05 Pro Rev.C1

UTC205.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC205.202 not supported
    Skip
    ...    UTC205.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC213.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC213.202 not supported
    Skip
    ...    UTC213.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC219.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC219.202 not supported
    Skip
    ...    UTC219.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC225.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC225.202 not supported
    Skip
    ...    UTC225.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC227.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC227.202 not supported
    Skip
    ...    UTC227.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC235.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC235.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC235.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC237.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC237.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC247.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC247.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC249.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC249.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC249.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC251.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC251.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC253.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC253.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC255.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC255.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC257.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC257.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UMD05 Pro Rev.C1

UTC205.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC205.301 not supported
    Skip
    ...    UTC205.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC207.301 USB Type-C Display output (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC207.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC207.301 not supported
    Skip
    ...    UTC207.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC213.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC213.301 not supported
    Skip
    ...    UTC213.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC219.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC219.301 not supported
    Skip
    ...    UTC219.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC221.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC221.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC221.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UMD05 Pro Rev.C1

UTC223.301 USB Type-C docking station audio recognition (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC223.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC223.301 not supported
    Skip
    ...    UTC223.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC225.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC225.301 not supported
    Skip
    ...    UTC225.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC227.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC227.301 not supported
    Skip
    ...    UTC227.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC235.301 Docking station detection after coldboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC235.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC235.301 not supported
    Skip
    ...    UTC235.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC237.301 Docking station detection after warmboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC237.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC237.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC237.301 not supported
    Skip
    ...    UTC237.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC239.301 Docking station detection after reboot (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC239.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC239.301 not supported
    Skip
    ...    UTC239.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC241.301 Docking station detection after suspend (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC241.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC241.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC241.301 not supported
    Skip
    ...    UTC241.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC243.301 Docking station detection after suspend (S0ix) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC243.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC243.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC243.301 not supported
    Skip
    ...    UTC243.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC245.301 Docking station detection after suspend (S3) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC245.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC245.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC245.301 not supported
    Skip
    ...    UTC245.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC247.301 Docking station detection after coldboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC247.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC247.301 not supported
    Skip
    ...    UTC247.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC249.301 Docking station detection after warmboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC249.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC249.301 not supported
    Skip
    ...    UTC249.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC251.301 Docking station detection after reboot then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC251.301 not supported
    Skip
    ...    UTC251.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC253.301 Docking station detection after suspend then hotplug (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC253.301 not supported
    Skip
    ...    UTC253.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC255.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC255.301 not supported
    Skip
    ...    UTC255.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC257.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC257.301 not supported
    Skip
    ...    UTC257.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC205.203 USB Type-C PD power input (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC205.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC205.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC207.203 USB Type-C Display output (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC207.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC207.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC209.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC209.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC209.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC211.203 USB Type-C docking station DP display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC211.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC211.203 not supported
    Skip
    ...    UTC211.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC213.203 USB Type-C docking station Triple display (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC213.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC215.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC215.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC215.203 not supported
    Skip
    ...    UTC215.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC217.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC217.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC217.203 not supported
    Skip
    ...    UTC217.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC219.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC219.203 not supported
    Skip
    ...    UTC219.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC221.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC221.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC221.203 not supported
    Skip
    ...    UTC221.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC223.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC223.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC223.203 not supported
    Skip
    ...    UTC223.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC225.203 USB Type-C docking station audio playback (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC225.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC225.203 not supported
    Skip
    ...    UTC225.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC227.203 USB Type-C docking station audio capture (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC227.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC227.203 not supported
    Skip
    ...    UTC227.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC229.203 USB Type-C docking station SD Card reader detection (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC229.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC229.203 not supported
    Skip
    ...    UTC229.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC231.203 USB Type-C docking station SD Card read/write (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC231.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC231.203 not supported
    Skip
    ...    UTC231.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC235.203 Docking station detection after coldboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC235.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC235.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC235.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC237.203 Docking station detection after warmboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC237.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC237.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC237.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC239.203 Docking station detection after reboot (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC239.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC239.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Enabled    WL-UMD05 Pro Rev.C1

UTC241.203 Docking station detection after suspend (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC241.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC241.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC241.203 not supported
    Skip
    ...    UTC241.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC243.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC243.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC243.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC243.203 not supported
    Skip
    ...    UTC243.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC245.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC245.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC245.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC245.203 not supported
    Skip
    ...    UTC245.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC247.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC247.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC247.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC247.203 not supported
    Skip
    ...    UTC247.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC249.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC249.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC249.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC249.203 not supported
    Skip
    ...    UTC249.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC251.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC251.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC251.203 not supported
    Skip
    ...    UTC251.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC253.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC253.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC253.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC253.203 not supported
    Skip
    ...    UTC253.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC255.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC255.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC255.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC255.203 not supported
    Skip
    ...    UTC255.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC257.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Enabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC257.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC257.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC257.203 not supported
    Skip
    ...    UTC257.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC216.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.001 not supported
    Skip
    ...    UTC216.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC218.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.001 not supported
    Skip
    ...    UTC218.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC206.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC206.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC206.201 not supported
    Skip
    ...    UTC206.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC214.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC214.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC214.201 not supported
    Skip
    ...    UTC214.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC220.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC220.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC220.201 not supported
    Skip
    ...    UTC220.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC226.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC226.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC226.201 not supported
    Skip
    ...    UTC226.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC228.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC228.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC228.201 not supported
    Skip
    ...    UTC228.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC236.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC236.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC236.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC236.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC238.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC238.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC248.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC248.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC248.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC250.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC250.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC250.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC250.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC252.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC252.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC252.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC254.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC254.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC254.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC256.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC256.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC256.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC258.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC258.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC258.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UMD05 Pro Rev.C1

UTC206.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC206.202 not supported
    Skip
    ...    UTC206.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC214.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC214.202 not supported
    Skip
    ...    UTC214.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC220.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC220.202 not supported
    Skip
    ...    UTC220.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC226.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC226.202 not supported
    Skip
    ...    UTC226.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC228.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC228.202 not supported
    Skip
    ...    UTC228.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC236.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC236.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC236.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC238.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC238.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC248.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC248.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC250.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC250.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC250.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC252.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC252.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC254.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC254.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC256.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC256.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC258.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC258.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UMD05 Pro Rev.C1

UTC206.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC206.301 not supported
    Skip
    ...    UTC206.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC208.301 USB Type-C Display output (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC208.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC208.301 not supported
    Skip
    ...    UTC208.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC214.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC214.301 not supported
    Skip
    ...    UTC214.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC220.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC220.301 not supported
    Skip
    ...    UTC220.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC222.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC222.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC222.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UMD05 Pro Rev.C1

UTC224.301 USB Type-C docking station audio recognition (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC224.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC224.301 not supported
    Skip
    ...    UTC224.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC226.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC226.301 not supported
    Skip
    ...    UTC226.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC228.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC228.301 not supported
    Skip
    ...    UTC228.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC236.301 Docking station detection after coldboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC236.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC236.301 not supported
    Skip
    ...    UTC236.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC238.301 Docking station detection after warmboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC238.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC238.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC238.301 not supported
    Skip
    ...    UTC238.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC240.301 Docking station detection after reboot (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC240.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC240.301 not supported
    Skip
    ...    UTC240.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC242.301 Docking station detection after suspend (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC242.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC242.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC242.301 not supported
    Skip
    ...    UTC242.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC244.301 Docking station detection after suspend (S0ix) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC244.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC244.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC244.301 not supported
    Skip
    ...    UTC244.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC246.301 Docking station detection after suspend (S3) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC246.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC246.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC246.301 not supported
    Skip
    ...    UTC246.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC248.301 Docking station detection after coldboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC248.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC248.301 not supported
    Skip
    ...    UTC248.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC250.301 Docking station detection after warmboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC250.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC250.301 not supported
    Skip
    ...    UTC250.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC252.301 Docking station detection after reboot then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC252.301 not supported
    Skip
    ...    UTC252.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC254.301 Docking station detection after suspend then hotplug (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC254.301 not supported
    Skip
    ...    UTC254.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC256.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC256.301 not supported
    Skip
    ...    UTC256.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC258.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC258.301 not supported
    Skip
    ...    UTC258.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC206.203 USB Type-C PD power input (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC206.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC206.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC208.203 USB Type-C Display output (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC208.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC208.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC210.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC210.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC210.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC212.203 USB Type-C docking station DP display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC212.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC212.203 not supported
    Skip
    ...    UTC212.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC214.203 USB Type-C docking station Triple display (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC214.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC216.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC216.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC216.203 not supported
    Skip
    ...    UTC216.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC218.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC218.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC218.203 not supported
    Skip
    ...    UTC218.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC220.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC220.203 not supported
    Skip
    ...    UTC220.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC222.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC222.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC222.203 not supported
    Skip
    ...    UTC222.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC224.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC224.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC224.203 not supported
    Skip
    ...    UTC224.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC226.203 USB Type-C docking station audio playback (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC226.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC226.203 not supported
    Skip
    ...    UTC226.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC228.203 USB Type-C docking station audio capture (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC228.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC228.203 not supported
    Skip
    ...    UTC228.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC230.203 USB Type-C docking station SD Card reader detection (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC230.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC230.203 not supported
    Skip
    ...    UTC230.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC232.203 USB Type-C docking station SD Card read/write (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    UTC232.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC232.203 not supported
    Skip
    ...    UTC232.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC236.203 Docking station detection after coldboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC236.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC236.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC236.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC238.203 Docking station detection after warmboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC238.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC238.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC238.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC240.203 Docking station detection after reboot (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC240.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC240.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Disabled    WL-UMD05 Pro Rev.C1

UTC242.203 Docking station detection after suspend (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC242.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC242.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC242.203 not supported
    Skip
    ...    UTC242.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC244.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC244.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC244.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC244.203 not supported
    Skip
    ...    UTC244.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC246.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC246.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC246.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC246.203 not supported
    Skip
    ...    UTC246.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC248.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC248.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC248.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC248.203 not supported
    Skip
    ...    UTC248.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC250.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC250.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC250.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC250.203 not supported
    Skip
    ...    UTC250.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC252.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC252.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC252.203 not supported
    Skip
    ...    UTC252.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC254.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC254.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC254.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC254.203 not supported
    Skip
    ...    UTC254.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC256.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC256.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC256.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC256.203 not supported
    Skip
    ...    UTC256.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC258.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Disabled) (WL-UMD05 Pro Rev.C1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC258.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC258.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC258.203 not supported
    Skip
    ...    UTC258.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC315.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.001 not supported
    Skip
    ...    UTC315.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC317.001 USB Type-C docking station USB keyboard (Firmware) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.001 not supported
    Skip
    ...    UTC317.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC305.201 USB Type-C PD power input (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC305.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC305.201 not supported
    Skip
    ...    UTC305.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC313.201 USB Type-C docking station Triple display (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC313.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC313.201 not supported
    Skip
    ...    UTC313.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC319.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC319.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC319.201 not supported
    Skip
    ...    UTC319.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC325.201 USB Type-C docking station audio playback (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC325.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC325.201 not supported
    Skip
    ...    UTC325.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC327.201 USB Type-C docking station audio capture (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC327.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC327.201 not supported
    Skip
    ...    UTC327.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC335.201 Docking station detection after coldboot (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC335.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC335.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC335.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC337.201 Docking station detection after warmboot (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC337.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC347.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC347.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC347.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC349.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC349.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC349.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC349.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC351.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC351.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC351.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC353.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC353.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC353.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC355.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC355.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC355.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC357.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC357.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC357.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Enabled    WL-UG69PD2 Rev.A1

UTC305.202 USB Type-C PD power input (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC305.202 not supported
    Skip
    ...    UTC305.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC313.202 USB Type-C docking station Triple display (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC313.202 not supported
    Skip
    ...    UTC313.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC319.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC319.202 not supported
    Skip
    ...    UTC319.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC325.202 USB Type-C docking station audio playback (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC325.202 not supported
    Skip
    ...    UTC325.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC327.202 USB Type-C docking station audio capture (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC327.202 not supported
    Skip
    ...    UTC327.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC335.202 Docking station detection after coldboot (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC335.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC335.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC337.202 Docking station detection after warmboot (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC337.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC347.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC347.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC349.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC349.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC349.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC351.202 Docking station detection after reboot then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC351.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC353.202 Docking station detection after suspend then hotplug (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC353.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC355.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC355.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC357.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC357.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Enabled    WL-UG69PD2 Rev.A1

UTC305.301 USB Type-C PD power input (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC305.301 not supported
    Skip
    ...    UTC305.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC307.301 USB Type-C Display output (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC307.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC307.301 not supported
    Skip
    ...    UTC307.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC313.301 USB Type-C docking station Triple display (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC313.301 not supported
    Skip
    ...    UTC313.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC319.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC319.301 not supported
    Skip
    ...    UTC319.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC321.301 USB Type-C docking station Ethernet connection (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC321.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC321.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Enabled    WL-UG69PD2 Rev.A1

UTC323.301 USB Type-C docking station audio recognition (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC323.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC323.301 not supported
    Skip
    ...    UTC323.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC325.301 USB Type-C docking station audio playback (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC325.301 not supported
    Skip
    ...    UTC325.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC327.301 USB Type-C docking station audio capture (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC327.301 not supported
    Skip
    ...    UTC327.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC335.301 Docking station detection after coldboot (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC335.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC335.301 not supported
    Skip
    ...    UTC335.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC337.301 Docking station detection after warmboot (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC337.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC337.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC337.301 not supported
    Skip
    ...    UTC337.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC339.301 Docking station detection after reboot (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC339.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC339.301 not supported
    Skip
    ...    UTC339.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC341.301 Docking station detection after suspend (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC341.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC341.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC341.301 not supported
    Skip
    ...    UTC341.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC343.301 Docking station detection after suspend (S0ix) (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC343.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC343.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC343.301 not supported
    Skip
    ...    UTC343.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC345.301 Docking station detection after suspend (S3) (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC345.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC345.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC345.301 not supported
    Skip
    ...    UTC345.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC347.301 Docking station detection after coldboot then hotplug (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC347.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC347.301 not supported
    Skip
    ...    UTC347.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC349.301 Docking station detection after warmboot then hotplug (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC349.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC349.301 not supported
    Skip
    ...    UTC349.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC351.301 Docking station detection after reboot then hotplug (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC351.301 not supported
    Skip
    ...    UTC351.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC353.301 Docking station detection after suspend then hotplug (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC353.301 not supported
    Skip
    ...    UTC353.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC355.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC355.301 not supported
    Skip
    ...    UTC355.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC357.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC357.301 not supported
    Skip
    ...    UTC357.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC305.203 USB Type-C PD power input (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC305.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC305.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC307.203 USB Type-C Display output (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC307.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC307.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC309.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC309.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC309.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC311.203 USB Type-C docking station DP display (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC311.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC311.203 not supported
    Skip
    ...    UTC311.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC313.203 USB Type-C docking station Triple display (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC313.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC315.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC315.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC315.203 not supported
    Skip
    ...    UTC315.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC317.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC317.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC317.203 not supported
    Skip
    ...    UTC317.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC319.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC319.203 not supported
    Skip
    ...    UTC319.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC321.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC321.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC321.203 not supported
    Skip
    ...    UTC321.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC323.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC323.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC323.203 not supported
    Skip
    ...    UTC323.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC325.203 USB Type-C docking station audio playback (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC325.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC325.203 not supported
    Skip
    ...    UTC325.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC327.203 USB Type-C docking station audio capture (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC327.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC327.203 not supported
    Skip
    ...    UTC327.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC335.203 Docking station detection after coldboot (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC335.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC335.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC335.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC337.203 Docking station detection after warmboot (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC337.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC337.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC337.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC339.203 Docking station detection after reboot (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC339.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC339.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Enabled    WL-UG69PD2 Rev.A1

UTC341.203 Docking station detection after suspend (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC341.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC341.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC341.203 not supported
    Skip
    ...    UTC341.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC343.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC343.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC343.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC343.203 not supported
    Skip
    ...    UTC343.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC345.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC345.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC345.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC345.203 not supported
    Skip
    ...    UTC345.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC347.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC347.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC347.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC347.203 not supported
    Skip
    ...    UTC347.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC349.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC349.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC349.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC349.203 not supported
    Skip
    ...    UTC349.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC351.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC351.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC351.203 not supported
    Skip
    ...    UTC351.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC353.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC353.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC353.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC353.203 not supported
    Skip
    ...    UTC353.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC355.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC355.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC355.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC355.203 not supported
    Skip
    ...    UTC355.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC357.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Enabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC357.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC357.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC357.203 not supported
    Skip
    ...    UTC357.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC316.001 USB Type-C docking station USB devices recognition (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.001 not supported
    Skip
    ...    UTC316.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC318.001 USB Type-C docking station USB keyboard (Firmware) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.001 not supported
    Skip
    ...    UTC318.001 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC306.201 USB Type-C PD power input (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC306.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC306.201 not supported
    Skip
    ...    UTC306.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC314.201 USB Type-C docking station Triple display (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC314.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC314.201 not supported
    Skip
    ...    UTC314.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC320.201 USB Type-C docking station upload 1GB file on USB storage (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC320.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC320.201 not supported
    Skip
    ...    UTC320.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC326.201 USB Type-C docking station audio playback (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC326.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC326.201 not supported
    Skip
    ...    UTC326.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC328.201 USB Type-C docking station audio capture (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC328.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC328.201 not supported
    Skip
    ...    UTC328.201 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC336.201 Docking station detection after coldboot (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC336.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC336.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC336.201 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC338.201 Docking station detection after warmboot (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC338.201 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC348.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC348.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC348.201 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC350.201 Docking station detection after warmboot then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC350.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC350.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC350.201 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC352.201 Docking station detection after reboot then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC352.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC352.201 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC354.201 Docking station detection after suspend then hotplug (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC354.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC354.201 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC356.201 Docking station detection after suspend then hotplug (S0ix) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC356.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC356.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC358.201 Docking station detection after suspend then hotplug (S3) (Ubuntu) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.201 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UTC358.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTC358.201 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_UBUNTU}    Disabled    WL-UG69PD2 Rev.A1

UTC306.202 USB Type-C PD power input (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC306.202 not supported
    Skip
    ...    UTC306.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC314.202 USB Type-C docking station Triple display (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC314.202 not supported
    Skip
    ...    UTC314.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC320.202 USB Type-C docking station upload 1GB file on USB storage (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC320.202 not supported
    Skip
    ...    UTC320.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC326.202 USB Type-C docking station audio playback (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC326.202 not supported
    Skip
    ...    UTC326.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC328.202 USB Type-C docking station audio capture (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC328.202 not supported
    Skip
    ...    UTC328.202 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC336.202 Docking station detection after coldboot (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC336.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC336.202 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC338.202 Docking station detection after warmboot (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC338.202 not supported
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
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC348.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC348.202 not supported
    Docking Station Detection After Coldboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC350.202 Docking station detection after warmboot then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    automated    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC350.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC350.202 not supported
    Docking Station Detection After Warmboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC352.202 Docking station detection after reboot then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC352.202 not supported
    Docking Station Detection After Reboot Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC354.202 Docking station detection after suspend then hotplug (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC354.202 not supported
    Docking Station Detection After Suspend Then Hotplug    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC356.202 Docking station detection after suspend then hotplug (S0ix) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC356.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S0Ix)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC358.202 Docking station detection after suspend then hotplug (S3) (Fedora) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.202 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    UTC358.202 not supported
    Docking Station Detection After Suspend Then Hotplug (S3)    ${ENV_ID_FEDORA}    Disabled    WL-UG69PD2 Rev.A1

UTC306.301 USB Type-C PD power input (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC306.301 not supported
    Skip
    ...    UTC306.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC308.301 USB Type-C Display output (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC308.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC308.301 not supported
    Skip
    ...    UTC308.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC314.301 USB Type-C docking station Triple display (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC314.301 not supported
    Skip
    ...    UTC314.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

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

UTC320.301 USB Type-C docking station upload 1GB file on USB storage (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC320.301 not supported
    Skip
    ...    UTC320.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC322.301 USB Type-C docking station Ethernet connection (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC322.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC322.301 not supported
    Usb Type-C Docking Station Ethernet Connection    ${ENV_ID_WINDOWS}    Disabled    WL-UG69PD2 Rev.A1

UTC324.301 USB Type-C docking station audio recognition (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC324.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC324.301 not supported
    Skip
    ...    UTC324.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC326.301 USB Type-C docking station audio playback (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC326.301 not supported
    Skip
    ...    UTC326.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC328.301 USB Type-C docking station audio capture (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC328.301 not supported
    Skip
    ...    UTC328.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC336.301 Docking station detection after coldboot (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC336.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC336.301 not supported
    Skip
    ...    UTC336.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC338.301 Docking station detection after warmboot (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC338.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC338.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC338.301 not supported
    Skip
    ...    UTC338.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC340.301 Docking station detection after reboot (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC340.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC340.301 not supported
    Skip
    ...    UTC340.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC342.301 Docking station detection after suspend (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC342.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC342.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC342.301 not supported
    Skip
    ...    UTC342.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC344.301 Docking station detection after suspend (S0ix) (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC344.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC344.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC344.301 not supported
    Skip
    ...    UTC344.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC346.301 Docking station detection after suspend (S3) (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC346.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC346.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC346.301 not supported
    Skip
    ...    UTC346.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC348.301 Docking station detection after coldboot then hotplug (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC348.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC348.301 not supported
    Skip
    ...    UTC348.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC350.301 Docking station detection after warmboot then hotplug (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC350.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC350.301 not supported
    Skip
    ...    UTC350.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC352.301 Docking station detection after reboot then hotplug (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC352.301 not supported
    Skip
    ...    UTC352.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC354.301 Docking station detection after suspend then hotplug (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC354.301 not supported
    Skip
    ...    UTC354.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC356.301 Docking station detection after suspend then hotplug (S0ix) (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC356.301 not supported
    Skip
    ...    UTC356.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC358.301 Docking station detection after suspend then hotplug (S3) (Windows) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.301 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    UTC358.301 not supported
    Skip
    ...    UTC358.301 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC306.203 USB Type-C PD power input (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can be charged using a
    ...    PD power supply connected to the docking station, which
    ...    is connected to the USB Type-C port
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_C_CHARGING_SUPPORT}    UTC306.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC306.203 not supported
    Usb Type-C Pd Power Input    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC308.203 USB Type-C Display output (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT can detect the USB Type-C hub.
    [Tags]    semiauto
    Skip If    not ${USB_TYPE_C_DISPLAY_SUPPORT}    UTC308.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC308.203 not supported
    Usb Type-C Display Output    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC310.203 USB Type-C docking station HDMI display (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_HDMI}    UTC310.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC310.203 not supported
    Usb Type-C Docking Station Hdmi Display    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC312.203 USB Type-C docking station DP display (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the display connected with
    ...    the HDMI cable to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DISPLAY_PORT}    UTC312.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC312.203 not supported
    Skip
    ...    UTC312.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC314.203 USB Type-C docking station Triple display (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the three display
    ...    simultaneously connected to the docking station is correctly
    ...    recognized by the OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC314.203 not supported
    Usb Type-C Docking Station Triple Display    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC316.203 USB Type-C docking station USB devices recognition (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB devices connected to the
    ...    docking station are detected correctly
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_USB_SUPPORT}    UTC316.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC316.203 not supported
    Skip
    ...    UTC316.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC318.203 USB Type-C docking station USB keyboard (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the external USB keyboard connected to the
    ...    docking station is detected correctly.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_KEYBOARD_SUPPORT}    UTC318.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC318.203 not supported
    Skip
    ...    UTC318.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC320.203 USB Type-C docking station upload 1GB file on USB storage (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the 1GB file can be
    ...    transferred from the OPERATING_SYSTEM to the USB storage
    ...    connected to the docking station.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC320.203 not supported
    Skip
    ...    UTC320.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC322.203 USB Type-C docking station Ethernet connection (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the connection to internet
    ...    via docking station's Ethernet port can be obtained on
    ...    OPERATING_SYSTEM.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_NET_INTERFACE}    UTC322.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC322.203 not supported
    Skip
    ...    UTC322.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC324.203 USB Type-C docking station audio recognition (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the external headset is
    ...    properly recognized after plugging in the 3.5 mm jack into
    ...    the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC324.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC324.203 not supported
    Skip
    ...    UTC324.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC326.203 USB Type-C docking station audio playback (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to playback audio recordings by using the external headset
    ...    speakers connected to the docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC326.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC326.203 not supported
    Skip
    ...    UTC326.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC328.203 USB Type-C docking station audio capture (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    This test aims to verify that the audio subsystem is able
    ...    to capture audio from external headset connected to the
    ...    docking station.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_AUDIO_SUPPORT}    UTC328.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC328.203 not supported
    Skip
    ...    UTC328.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC336.203 Docking station detection after coldboot (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after coldboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC336.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC336.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC336.203 not supported
    Docking Station Detection After Coldboot    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC338.203 Docking station detection after warmboot (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether he DUT properly detects the docking station
    ...    after warmboot.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC338.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC338.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC338.203 not supported
    Docking Station Detection After Warmboot    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC340.203 Docking station detection after reboot (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC340.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC340.203 not supported
    Docking Station Detection After Reboot    ${ENV_ID_QUBES}    Disabled    WL-UG69PD2 Rev.A1

UTC342.203 Docking station detection after suspend (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC342.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC342.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC342.203 not supported
    Skip
    ...    UTC342.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC344.203 Docking station detection after suspend (S0ix) (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend '${POWER_CTRL}' == 'none'(S0ix).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC344.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC344.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC344.203 not supported
    Skip
    ...    UTC344.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC346.203 Docking station detection after suspend (S3) (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3).
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC346.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC346.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC346.203 not supported
    Skip
    ...    UTC346.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC348.203 Docking station detection after coldboot then hotplug (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after coldboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC348.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC348.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC348.203 not supported
    Skip
    ...    UTC348.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC350.203 Docking station detection after warmboot then hotplug (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after warmboot then hotplug.
    [Tags]    semiauto
    Skip If    '${POWER_CTRL}' == 'none' and 'semiauto' not in ${INCLUDE_TAGS}    UTC350.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC350.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC350.203 not supported
    Skip
    ...    UTC350.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC352.203 Docking station detection after reboot then hotplug (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after reboot then hotplug.
    [Tags]    semiauto
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC352.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC352.203 not supported
    Skip
    ...    UTC352.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC354.203 Docking station detection after suspend then hotplug (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend then hotplug.
    [Tags]    semiauto
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC354.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC354.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC354.203 not supported
    Skip
    ...    UTC354.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC356.203 Docking station detection after suspend then hotplug (S0ix) (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S0ix) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC356.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC356.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC356.203 not supported
    Skip
    ...    UTC356.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/

UTC358.203 Docking station detection after suspend then hotplug (S3) (Qubes OS) (ME: Disabled) (WL-UG69PD2 Rev.A1)
    [Documentation]    Check whether the DUT properly detects the docking station
    ...    after suspend (S3) then hotplug.
    [Tags]    semiauto
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    UTC358.203 not supported
    Skip If    not ${DOCKING_STATION_DETECT_SUPPORT}    UTC358.203 not supported
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    UTC358.203 not supported
    Skip
    ...    UTC358.203 not implemented in OSFV. Refer to the documentation at https://docs.dasharo.com/unified-test-documentation/dasharo-compatibility/31H-usb-type-c/
