*** Variables ***
${DUT_CONNECTION_METHOD}=                           open-bmc
${PAYLOAD}=                                         petitboot
${FLASH_SIZE}=                                      ${64*1024*1024}
${MANUFACTURER}=                                    Raptor Engineering, LLC
${CPU}=                                             IBM POWER9 v2 CPU (4-Core) CP9M31
${DEF_CORES}=                                       4
${DEF_THREADS}=                                     4
${DEF_CPU}=                                         32
${DEF_ONLINE_CPU}=                                  0-31
${DEF_SOCKETS}=                                     2
${OPEN_BMC_USERNAME}=                               root
${OPEN_BMC_PASSWORD}=                               openpower
${OPEN_BMC_ROOT_PROMPT}=                            root@talos:~#
${FLASH_VERIFY_METHOD}=                             none
${POWER_CTRL}=                                      obmcutil

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                ${EMPTY}
${LAPTOP_EC_SERIAL_WORKAROUND}=                     ${FALSE}

# Platform flashing flags

# Temporary parameter - we are not able to use the Hardware matrix
@{ATTACHED_USB}=                                    ${USB_LIVE}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${TRUE}
${TESTS_IN_HEADS_SUPPORT}=                          ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_USB_MENU_SUPPORT}=                        ${FALSE}
${DASHARO_NETWORKING_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                    ${FALSE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_PCIE_REBAR_SUPPORT}=                      ${FALSE}
${DASHARO_MEMORY_MENU_SUPPORT}=                     ${FALSE}
# Test module: dasharo-compatibility
${BASE_PORT_BOOTBLOCK_SUPPORT}=                     ${TRUE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                      ${TRUE}
${BASE_PORT_POSTCAR_SUPPORT}=                       ${FALSE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                      ${TRUE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                       ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                           ${TRUE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${FALSE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${FALSE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=             ${FALSE}
${COREBOOT_FAN_CONTROL_SUPPORT}=                    ${FALSE}
${INTERNAL_LCD_DISPLAY_SUPPORT}=                    ${FALSE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=                   ${FALSE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=                   ${FALSE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${FALSE}
${CUSTOM_LOGO_SUPPORT}=                             ${FALSE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${FALSE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${FALSE}
${USB_CAMERA_DETECTION_SUPPORT}=                    ${FALSE}
${USB_TYPE_C_DISPLAY_SUPPORT}=                      ${FALSE}
${UEFI_SHELL_SUPPORT}=                              ${FALSE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${FALSE}
${IPXE_BOOT_SUPPORT}=                               ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                       ${FALSE}
${NVME_DISK_SUPPORT}=                               ${FALSE}
${SD_CARD_READER_SUPPORT}=                          ${FALSE}
${WIRELESS_CARD_SUPPORT}=                           ${FALSE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${FALSE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${FALSE}
${MINI_PC_IE_SLOT_SUPPORT}=                         ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${FALSE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${FALSE}
${SERIAL_NUMBER_VERIFICATION}=                      ${FALSE}
${SERIAL_FROM_MAC}=                                 ${FALSE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${FALSE}
${FIRMWARE_FROM_BINARY}=                            ${FALSE}
${PRODUCT_NAME_VERIFICATION}=                       ${FALSE}
${RELEASE_DATE_VERIFICATION}=                       ${FALSE}
${MANUFACTURER_VERIFICATION}=                       ${FALSE}
${VENDOR_VERIFICATION}=                             ${FALSE}
${FAMILY_VERIFICATION}=                             ${FALSE}
${TYPE_VERIFICATION}=                               ${FALSE}
${HARDWARE_WP_SUPPORT}=                             ${FALSE}
${DOCKING_STATION_USB_SUPPORT}=                     ${FALSE}
${DOCKING_STATION_KEYBOARD_SUPPORT}=                ${FALSE}
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${FALSE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${FALSE}
${EMMC_SUPPORT}=                                    ${FALSE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${FALSE}
${CPU_TESTS_SUPPORT}=                               ${FALSE}
${DOCKING_STATION_NET_INTERFACE}=                   ${FALSE}
${DOCKING_STATION_HDMI}=                            ${FALSE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${FALSE}
${FAN_SPEED_MEASURE_SUPPORT}=                       ${FALSE}
${DEVICE_TREE_SUPPORT}=                             ${TRUE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${UPLOAD_ON_USB_SUPPORT}=                           ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${MEMORY_PROFILE_SUPPORT}=                          ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${FALSE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${FALSE}
${MEASURED_BOOT_SUPPORT}=                           ${FALSE}
${SECURE_BOOT_SUPPORT}=                             ${FALSE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled
${USB_STACK_SUPPORT}=                               ${FALSE}
${USB_MASS_STORAGE_SUPPORT}=                        ${FALSE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${FALSE}
${BIOS_LOCK_SUPPORT}=                               ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${FALSE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${FALSE}
${CAMERA_SWITCH_SUPPORT}=                           ${FALSE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                           ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${FALSE}
${CPU_FREQUENCY_MEASURE}=                           ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                         ${FALSE}
${PLATFORM_STABILITY_CHECKING}=                     ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${TRUE}

# Supported OS installation variants

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 0
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 0

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                    0
# Stability tests duration in minutes
${STABILITY_TEST_DURATION}=                         15
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=                 5
# Frequency measure test duration
${FREQUENCY_TEST_DURATION}=                         60
# Interval between the following readings in frequency measure tests
${FREQUENCY_TEST_MEASURE_INTERVAL}=                 1
# Temperature measure test duration
${TEMPERATURE_TEST_DURATION}=                       60
# Interval between the following readings in temperature measure tests
${TEMPERATURE_TEST_MEASURE_INTERVAL}=               1
# Fan control measure tests duration in minutes
# Interval between the following readings in fan control tests
# Custom fan curve tests duration in minutes
${CUSTOM_FAN_CURVE_TEST_DURATION}=                  30
# Interval between the following readings in custom fan curve tests
${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}=               1
# Maximum fails during during performing test suite usb-boot.robot
${ALLOWED_FAILS_USB_BOOT}=                          0
# Maximum fails during during performing test suite usb-detect.robot
${ALLOWED_FAILS_USB_DETECT}=                        0
# Number of Ubuntu booting iterations
# Number of Debian booting iterations
# Number of Ubuntu Server booting iterations
# Number of Proxmox VE booting iterations
# Number of pfSense (serial output) booting iterations
# Number of pfSense (VGA output) booting iterations
# Number of OPNsense (serial output) booting iterations
# Number of OPNsense (VGA output) booting iterations
# Number of FreeBSD booting iterations
# Number of Windows booting iterations
# Maximum fails during performing booting OS tests
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=           5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=          5


*** Keywords ***
Get Firmware Version From Coreboot File
    [Documentation]    Return firmware version from binary file sent via SSH to
    ...    RTE system. Takes binary file path as an argument.
    [Arguments]    ${binary_path}
    ${ecc}=    Get Binary File    ${binary_path}
    ${no_ecc}=    Evaluate    re.sub(rb'(?s)(........).', rb'\\1', $ecc)
    Create Binary File    /tmp/test.rom    ${no_ecc}
    ${output}=    Run    strings /tmp/test.rom
    Remove File    /tmp/test.rom
    ${firmware_version_file}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    RETURN    ${firmware_version_file[-1]}

Get Firmware Version From Bootlogs
    [Documentation]    Return firmware version from the platform booting logs.
    ${output}=    Read From Terminal Until    bootblock starting
    ${firmware_version_bootblock}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    ${output}=    Read From Terminal Until    romstage starting
    ${firmware_version_romstage}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    # Platform may hang if interrupted at wrong time by next test, so let it boot past Skiboot
    Read From Terminal Until    Jumping to boot code
    Read From Terminal Until    INIT: Starting kernel at
    Sleep    5s
    RETURN    ${firmware_version_bootblock[-1]}    ${firmware_version_romstage[-1]}

Set Platform Power State
    [Documentation]    Keyword allows to set platform power state. As platform
    ...    power state is understood whether the platform is connected to the
    ...    power supply. If the platform power state is off, obmc connection
    ...    will not be established.
    Sonoff API Setup    ${TALOS_SONOFF_IP}
    ${result}=    Get Sonoff State
    IF    '${result}'=='low'
        Sonoff Power On
        Sleep    120s
    END

Open OBMC Service Connection
    [Documentation]    Keyword allows to open second connection to the OBMC for
    ...    performing service procedures: power controlling and platform flashing.
    ${power_ctrl_connection}=    SSHLibrary.Open Connection    ${DEVICE_IP}    prompt=${OPEN_BMC_ROOT_PROMPT}
    SSHLibrary.Switch Connection    ${power_ctrl_connection}
    SSHLibrary.Login    ${OPEN_BMC_USERNAME}    ${OPEN_BMC_PASSWORD}
    Set DUT Response Timeout    300s

Close OBMC Service Connection
    [Documentation]    Keyword allows to close service connection used for
    ...    platform flashing and controlling platform power state.
    SSHLibrary.Close Connection
    SSHLibrary.Switch Connection    ${1}

Set Chassis Power State
    [Documentation]    Keyword allows to set chassis power state. If the
    ...    chassis power state is off, platform might stuck during the booting
    ...    process. The following solution is temporary - at this point, the
    ...    API command for changing Chassis settings is not working.
    [Arguments]    ${requested_chassis_state}
    Open OBMC Service Connection
    IF    '${requested_chassis_state}'=='off'
        Write Into Terminal    obmcutil chassisoff
        Sleep    60s
        ${chassis_state}=    Get Chassis Power State
        Should Be True    '${chassis_state}' == 'Off'
    ELSE IF    '${requested_chassis_state}'=='on'
        Write Into Terminal    obmcutil chassison
    ELSE
        FAIL    \nUnknown requested power state:${requested_chassis_state}
    END
    Close OBMC Service Connection

Power On
    [Documentation]    Keyword sets Device Under Test into Power On state using
    ...    openbmc-test-automation library and opens console client.
    ...    Implementation must be compatible with the theory of
    ...    operation of a specific platform.
    Variable Should Exist    ${OPENBMC_HOST}
    Set Global Variable    ${AUTH_URI}    https://${OPENBMC_HOST}${AUTH_SUFFIX}
    ${host_state}=    Get Host State
    IF    '${host_state}' != 'Off'    Initiate Host PowerOff
    ${host_state}=    Get Host State
    Should Be True    '${host_state}' == 'Off'
    # Flush any output from previous boot
    Read From Terminal
    Initiate Host Boot    0

Turn On Host With Obmcutil
    [Documentation]    Keyword allows to turn the host system on by using built
    ...    into OpenBMC service to control platform state.
    Write Into Terminal    obmcutil chassison
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    obmcutil poweron
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}

Turn Off Host With Obmcutil
    [Documentation]    Keyword allows to turn the host system off by using built
    ...    into OpenBMC service to control platform state.
    Write Into Terminal    obmcutil chassisoff
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    obmcutil poweroff
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}

Reset Mboxd
    [Documentation]    Keyword allows to reset mboxd service. This operation
    ...    is necessary to erase temporarily mounted images.
    Write Into Terminal    systemctl stop mboxd
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    systemctl start mboxd
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}

Read Talos2 Firmware From OpenBMC
    [Documentation]    Keyword allows to read device's current firmware. The
    ...    read firmware is placed on the OpenBMC in /tmp folder
    Write Into Terminal    pflash -P HBB -r /tmp/hbb.bin
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -P HBI -r /tmp/hbi.bin
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}

Flash Talos2 Firmware From OpenBMC
    [Documentation]    Keyword flashes the board with uploaded firmware on
    ...    OpenBMC.
    [Arguments]    ${bootblock_file}    ${coreboot_file}
    Open OBMC Service Connection
    SCP.Open Connection    ${DEVICE_IP}    username=${OPEN_BMC_USERNAME}    password=${OPEN_BMC_PASSWORD}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset Mboxd
    Write Into Terminal    pflash -f -e -P HBB -p /tmp/bootblock.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    100%
    Read From Terminal Until    Programming & Verifying..
    Read From Terminal Until    100%
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -f -e -P HBI -p /tmp/coreboot.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    100%
    Read From Terminal Until    Programming & Verifying..
    Read From Terminal Until    100%
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Close OBMC Service Connection

Flash Petitboot From OpenBMC
    [Documentation]    Keyword flashes the board with Petitboot system.
    [Arguments]    ${bootblock_file}    ${coreboot_file}    ${pnor_file}
    Open OBMC Service Connection
    SCP.Open Connection    ${DEVICE_IP}    username=${OPEN_BMC_USERNAME}    password=${OPEN_BMC_PASSWORD}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Put File    ${pnor_file}    /tmp/talos.pnor
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset Mboxd
    Write Into Terminal    pflash -f -P HBB -p /tmp/bootblock.rom -F /tmp/talos.pnor
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -f -P HBI -p /tmp/coreboot.rom -F /tmp/talos.pnor
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -f -E -p /tmp/talos.pnor
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Close OBMC Service Connection

Flash Heads From OpenBMC
    [Documentation]    Keyword flashes BOOTKERNEL partition to install Heads.
    [Arguments]    ${bootblock_file}    ${coreboot_file}    ${z_image_file}
    ${heads_already_flashed}=    Get Variable Value    ${HEADS_ALREADY_FLASHED}    ${FALSE}
    IF    ${heads_already_flashed}    RETURN
    Open OBMC Service Connection
    SCP.Open Connection    ${DEVICE_IP}    username=${OPEN_BMC_USERNAME}    password=${OPEN_BMC_PASSWORD}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Put File    ${z_image_file}    /tmp/zImage.bundled
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset Mboxd
    Write Into Terminal    pflash -f -e -P HBB -p /tmp/bootblock.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -f -e -P HBI -p /tmp/coreboot.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Write Into Terminal    pflash -f -e -P BOOTKERNEL -p /tmp/zImage.bundled
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${OPEN_BMC_ROOT_PROMPT}
    Close OBMC Service Connection
    Set Global Variable    ${HEADS_ALREADY_FLASHED}    ${TRUE}

Check TPM PCRs Correctness
    [Documentation]    Keyword allows to checking the TPM PCRs correctness.
    ...    Implementation of the keyword depends on platform specification, for
    ...    Talos 2 it is as follows:
    ...    -> PCRs 0 - 7 values should not be equal zeros,
    ...    -> PCRs 0 and 1 should have the same values. We call them
    ...    "capped values",
    ...    -> PCRs 2 and 3 values should not be the same as "capped values",
    ...    -> PCRs 4 and 5 values should not be the same as "capped values",
    ...    -> PCRs 6 and 7 values depend on current state of Heads, skip checks.
    [Arguments]    ${tpm_pcrs}
    ${number_of_pcrs}=    Get Length    ${tpm_pcrs}
    FOR    ${iteration}    IN RANGE    0    8
        TRY
            Should Be True    '${tpm_pcrs[${iteration}][8:]}'!='${TPM_PCR_ZERO_PATTERN}'
        EXCEPT
            FAIL    \n PCR-${iteration} has incorrect value: ${tpm_pcrs[${iteration}]}
        END
    END
    IF    '${tpm_pcrs[0][8:]}'!='${tpm_pcrs[1][8:]}'
        FAIL    \nValues for PCRs 0 and 1 are not the same!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[2][8:]}'
        FAIL    \nValue for PCR 2 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[3][8:]}'
        FAIL    \nValue for PCR 3 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[4][8:]}'
        FAIL    \nValue for PCR 4 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[5][8:]}'
        FAIL    \nValue for PCR 5 is the same as capped values!
    END

Check TPM PCRs Correctness Between Subsequent Boots
    [Documentation]    Keyword allows to checking the TPM PCRs correctness
    ...    between the subsequent boot procedures. Values from each PCR should
    ...    be the same across all boot types.
    [Arguments]    ${pcrs_subsequent_boots}
    ${list}=    Remove Duplicates    ${pcrs_subsequent_boots}
    ${length}=    Get Length    ${list}
    IF    ${length}!=1
        FAIL    \nPCR values have been changed between subsequent boots!
    END
