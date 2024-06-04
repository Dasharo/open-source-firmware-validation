*** Settings ***
Resource    default.robot


*** Variables ***
# For the pikvm connection, we switch between pikvm/SSH when in firmware/OS.
# We need to go back to the initial method (pikvm) when switching back from
# OS to firmware (e.g. when rebooting inside a single test case).
${INITIAL_DUT_CONNECTION_METHOD}=                   SSH
${DUT_CONNECTION_METHOD}=                           ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                         tianocore
${TIANOCORE_STRING}=                                to boot directly
${BOOT_MENU_KEY}=                                   F7
${SETUP_MENU_KEY}=                                  F2
${BOOT_MENU_STRING}=                                Please select boot device:
${SETUP_MENU_STRING}=                               Select Entry
${IPXE_BOOT_ENTRY}=                                 iPXE Network Boot
${EDK2_IPXE_CHECKPOINT}=                            iPXE Shell
${MANUFACTURER}=                                    ${EMPTY}
${CPU}=                                             ${EMPTY}
${POWER_CTRL}=                                      sonoff
${FLASH_VERIFY_METHOD}=                             none
${MAX_CPU_TEMP}=                                    82
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                6

${DMIDECODE_SERIAL_NUMBER}=                         N/A
${DMIDECODE_MANUFACTURER}=                          Notebook
${DMIDECODE_VENDOR}=                                3mdeb
${DMIDECODE_FAMILY}=                                Not Applicable
${DMIDECODE_TYPE}=                                  Notebook

${OPTIONS_LIB}=                                     dcu

${DEVICE_USB_KEYBOARD}=                             Logitech, Inc. Keyboard K120
${CLEVO_USB_C_HUB}=                                 4-port
${3_MDEB_WIFI_NETWORK}=                             3mdeb_abr
# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}

${DEVICE_UBUNTU_USER_PROMPT}=                       ${UBUNTU_USER_PROMPT}
${DEVICE_UBUNTU_ROOT_PROMPT}=                       ${UBUNTU_ROOT_PROMPT}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=                   ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                        ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=                 ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${TRUE}

# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${TRUE}
${INTERNAL_LCD_DISPLAY_SUPPORT}=                    ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=                   ${TRUE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                             ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${TRUE}
${USB_CAMERA_DETECTION_SUPPORT}=                    ${TRUE}
${USB_TYPE_C_DISPLAY_SUPPORT}=                      ${TRUE}
${UEFI_SHELL_SUPPORT}=                              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${TRUE}
${IPXE_BOOT_SUPPORT}=                               ${TRUE}
${NVME_DISK_SUPPORT}=                               ${TRUE}
${SD_CARD_READER_SUPPORT}=                          ${TRUE}
${WIRELESS_CARD_SUPPORT}=                           ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_VERIFICATION}=                       ${TRUE}
${MANUFACTURER_VERIFICATION}=                       ${TRUE}
${VENDOR_VERIFICATION}=                             ${TRUE}
${FAMILY_VERIFICATION}=                             ${TRUE}
${TYPE_VERIFICATION}=                               ${TRUE}
${DOCKING_STATION_USB_SUPPORT}=                     ${TRUE}
${DOCKING_STATION_KEYBOARD_SUPPORT}=                ${TRUE}
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${TRUE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${TRUE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${TRUE}
${DOCKING_STATION_NET_INTERFACE}=                   ${TRUE}
${DOCKING_STATION_HDMI}=                            ${TRUE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                           ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=                       ${TRUE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${TRUE}
${BOOT_BLOCKING_SUPPORT}=                           ${TRUE}
${HIBERNATION_AND_RESUME_SUPPORT}=                  ${TRUE}
# It causes "Power on AC" option to reset to disable, so we can no longer Power On using Sonoff
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${TRUE}
${MEASURED_BOOT_SUPPORT}=                           ${TRUE}
${SECURE_BOOT_SUPPORT}=                             ${TRUE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled
${USB_STACK_SUPPORT}=                               ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                        ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${TRUE}
${BIOS_LOCK_SUPPORT}=                               ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${TRUE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${TRUE}
${CAMERA_SWITCH_SUPPORT}=                           ${TRUE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                           ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                         ${TRUE}
${CPU_FREQUENCY_MEASURE}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                     ${TRUE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${TRUE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${TRUE}
${NVME_DETECTION_SUPPORT}=                          ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${TRUE}
${TPM_DETECT_SUPPORT}=                              ${TRUE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=         ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears SSH buffer and sets Device Under Test
    ...    into Power On state from Mechanical Off. (coldboot) For example:
    ...    sonoff, RTE relays.
    Restore Initial DUT Connection Method
    Power Cycle On
    Sleep    2s
    RteCtrl Set OC GPIO    12    low
    Sleep    1s
    RteCtrl Set OC GPIO    12    high-z

# TODO make these generic

Configure Wake In Linux
    [Documentation]    Keyword prepares platform for wake by platform specific
    ...    wake method.
    # Enable wake by magic packet
    Detect Or Install Package    ethtool
    Execute Linux Command    ethtool -s ${WOL_INTERFACE} wol g

Wake Up
    [Documentation]    Keyword wakes up DUT from sleep states, including S5
    ...    (warmboot). For example: power button press via RTE GPIO or Wake on
    ...    LAN.
    RteCtrl Set OC GPIO    12    low
    Sleep    1s
    RteCtrl Set OC GPIO    12    high-z

Flash Device Via Internal Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using internal programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    [Arguments]    ${fw_file}
    Login To Linux
    Switch To Root User
    Put File    ${fw_file}    /tmp/coreboot.rom
    Get Flashrom From Cloud
    Write Into Terminal    flashrom -p internal -w /tmp/coreboot.rom --ifd -i bios
    ${flash_result}=    Read From Terminal Until Prompt
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Flash Device Via Internal Programmer With Fwupd
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using internal programmer with fwupd and check flashing
    ...    procedure result. Implementation must be compatible with
    ...    the theory of operation of a specific platform.
    Power On
    Login To Linux
    Switch To Root User
    Install Fwupd And Flashrom
    Get Embargo Configuration
    Execute Linux Command    fwupdmgr refresh --force
    ${output}=    Execute Linux Command    fwupdmgr update
    Should Not Contain    ${output}    No updatable devices
    Exit From Root User

Flash Device Via External Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using external programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    [Arguments]    ${fw_file}
    Set Local Variable    ${cmd}    ./flashrom -p ch341a_spi -c GD25B128B/GD25Q128B -w ${fw_file}
    # TODO:
    # - flashing via RTE does not work yet
    # ${out}=
    # Should Contain    ${out}    Erase/write done
    # Should Contain    ${out}    VERIFIED

Read Firmware Clevo
    [Documentation]    Read from the flash and save to file dump.rom
    Write Into Terminal    flashrom -p internal -r coreboot.rom
    Read From Terminal Until Prompt

Build Coreboot
    [Documentation]    Keyword builds coreboot and save the image to
    ...    `build/coreboot.rom` directory.
    Execute Linux Command    docker pull coreboot/coreboot-sdk:latest    10    300
    Execute Linux Command    git clone https://github.com/3mdeb/coreboot.git    10    60
    Execute Linux Command    cd coreboot    10    10
    Execute Linux Command
    ...    docker run --rm -it -v $PWD:/home/coreboot/coreboot -w /home/coreboot/coreboot coreboot/coreboot-sdk:latest /bin/bash
    ...    10
    ...    120
    Execute Linux Command    cp configs/config.clevo_nv41mz .config    10    10
    Execute Linux Command    make olddefconfig    10    10
    Execute Linux Command    make nconfig    10    10
    Execute Linux Command    make    10    300

Check Coreboot Components Measurement
    [Documentation]    Check whether the hashes of the coreboot components
    ...    measurements have been stored in the TPM PCR registers.
    ${out}=    Execute Linux Command    ./cbmem -c | grep -i PCR | cat
    Should Contain    ${out}    fallback/payload` to PCR 2 measured
    Should Contain    ${out}    fallback/dsdt.aml` to PCR 2 measured
    Should Contain    ${out}    vbt.bin` to PCR 2 measured
    Should Contain    ${out}    fallback/romstage` to PCR 2 measured
    Should Contain    ${out}    fspm.bin` to PCR 2 measured
    Should Contain    ${out}    fallback/postcar` to PCR 2 measured
    Should Contain    ${out}    cpu_microcode_blob.bin` to PCR 2 measured
    Should Contain    ${out}    fsps.bin` to PCR 2 measured
    Should Contain    ${out}    logo.bmp` to PCR 2 measured
    Should Contain    ${out}    fallback/ramstage` to PCR 2 measured
    Should Not Contain    ${out}    Extending hash into PCR failed
