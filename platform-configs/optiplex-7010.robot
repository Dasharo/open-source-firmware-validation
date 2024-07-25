*** Settings ***
Resource    include/default.robot


*** Variables ***
${MANUFACTURER}=                                Dell
${DRAM_SIZE}=                                   ${16384}
${DEF_CORES}=                                   2
${DEF_THREADS}=                                 1
${DEF_CPU}=                                     2
${FLASH_VERIFY_METHOD}=                         tianocore-shell
${FLASH_VERIFY_OPTION}=                         UEFI Shell    # Selected One Time Boot option
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            ${EMPTY}

# Platform flashing flags
${FLASHING_METHOD}=                             external

${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                     tianocore
${RTE_S2_N_PORT}=                               13541
${FLASH_SIZE}=                                  ${4*1024*1024}
${FLASH_LENGTH}=                                ${EMPTY}
${TIANOCORE_STRING}=                            to boot directly
${BOOT_MENU_KEY}=                               ${F7}
${SETUP_MENU_KEY}=                              ${F2}
${BOOT_MENU_STRING}=                            Please select boot device:
${SETUP_MENU_STRING}=                           Select Entry
${IPXE_BOOT_ENTRY}=                             Network Boot and Utilities
${EDK2_IPXE_CHECKPOINT}=                        iPXE Shell
${POWER_CTRL}=                                  sonoff
${WIFI_CARD}=                                   ${EMPTY}
${MAX_CPU_TEMP}=                                80

${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FAMILY}=                            N/A
${DMIDECODE_TYPE}=                              Desktop

${DEVICE_USB_KEYBOARD}=                         SiGma Micro Keyboard TRACER Gamma Ivory
${DEVICE_NVME_DISK}=                            ${EMPTY}
${USB_MODEL}=                                   Kingston
${USB_DEVICE}=                                  Multifunction Composite Gadget

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${FALSE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${FALSE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=                 ${TRUE}
# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${UEFI_SHELL_SUPPORT}=                          ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${IPXE_BOOT_SUPPORT}=                           ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${SD_CARD_READER_SUPPORT}=                      ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=                    ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                  ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                   ${TRUE}
${RELEASE_DATE_VERIFICATION}=                   ${TRUE}
${MANUFACTURER_VERIFICATION}=                   ${TRUE}
${VENDOR_VERIFICATION}=                         ${TRUE}
${TYPE_VERIFICATION}=                           ${TRUE}
${DTS_SUPPORT}=                                 ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                       ${TRUE}
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${L2_CACHE_SUPPORT}=                            ${TRUE}
${L3_CACHE_SUPPORT}=                            ${TRUE}
${MEMORY_PROFILE_SUPPORT}=                      ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${FALSE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                 ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${FALSE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                 ${FALSE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=              ${TRUE}
${BIOS_LOCK_SUPPORT}=                           ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${FALSE}
${EARLY_BOOT_DMA_SUPPORT}=                      ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${NVME_DETECTION_SUPPORT}=                      ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=     ${TRUE}

${APU_CONFIGURATION_MENU_SUPPORT}=              ${FALSE}
${LAPTOP_EC_SERIAL_WORKAROUND}=                 ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${BOOT_BLOCKING_SUPPORT}=                       ${FALSE}
${BASE_PORT_BOOTBLOCK_SUPPORT}=                 ${FALSE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                  ${TRUE}
${BASE_PORT_POSTCAR_SUPPORT}=                   ${TRUE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                  ${TRUE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=              ${TRUE}
${COREBOOT_FAN_CONTROL_SUPPORT}=                ${FALSE}
${FAN_SPEED_MEASURE_SUPPORT}=                   ${FALSE}
${OPTIONS_LIB}=                                 uefi-setup-menu
${INTERNAL_LCD_DISPLAY_SUPPORT}=                ${FALSE}
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
${FAMILY_VERIFICATION}=                         ${TRUE}
${EC_AND_SUPER_IO_SUPPORT}=                     ${FALSE}
${EMMC_SUPPORT}=                                ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                       ${FALSE}
${MINI_PC_IE_SLOT_SUPPORT}=                     ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                   ${TRUE}
${ETH_PERF_PAIR_2_G}=                           ${FALSE}
${ETH_PERF_PAIR_10_G}=                          ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                   ${FALSE}
${HIBERNATION_AND_RESUME_SUPPORT}=              ${TRUE}
${PLATFORM_CPU_SPEED}=                          3.20
${PLATFORM_RAM_SIZE}=                           16384
${DOCKING_STATION_DETECT_SUPPORT}=              ${FALSE}
${WATCHDOG_SUPPORT}=                            ${FALSE}
${WIRELESS_CARD_SUPPORT}=                       ${FALSE}

# Auto

${INITIAL_CPU_FREQUENCY}=                       1600
${CPU_MIN_FREQUENCY}=                           300
${CPU_MAX_FREQUENCY}=                           3600
${PLATFORM_RAM_SPEED}=                          800
${CPU}=                                         Intel(R) Core(TM) i5-3470 CPU @ 3.20GHz
${DMIDECODE_MANUFACTURER}=                      Dell Inc.
${DMIDECODE_SERIAL_NUMBER}=                     123456789
${DMIDECODE_PRODUCT_NAME}=                      OptiPlex 9010
${DEF_THREADS_TOTAL}=                           4
${DEF_THREADS_PER_CORE}=                        1
${DEF_CORES_PER_SOCKET}=                        4
${DEF_SOCKETS}=                                 1
${DEF_ONLINE_CPU}=                              0-3
${DEVICE_AUDIO1}=                               DA Intel PCH


*** Keywords ***
Power On
    Sonoff Power Cycle On
    Sleep    2s
    Rte Power On

Flash Firmware Optiplex
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to OFF state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sonoff Power Off
    Sleep    2s
    RteCtrl Set OC GPIO    2    low
    RteCtrl Set OC GPIO    3    low
    RteCtrl Set OC GPIO    1    low
    # Currently the device is connected with only one of two spi-flash chips.
    # 8MB of memory on spi-flash chip 2 is unused, so only 4MB is used. Here
    # we use `dd` to recover the 4MB part suited for SPI_1
    SSHLibrary.Execute Command
    ...    dd if=/tmp/coreboot.rom of=/tmp/coreboot_spi1.rom skip=8388608 count=4194304 bs=1
    SSHLibrary.Execute Command    cat /sys/class/gpio/gpio40{4,5,6}/value
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=1600 -w /tmp/coreboot_spi1.rom 2>&1
    ...    return_rc=True
    RteCtrl Set OC GPIO    2    high-z
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    SSHLibrary.Execute Command    cat /sys/class/gpio/gpio40{4,5,6}/value

    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
    Power Cycle Off

Read Firmware Optiplex
    [Documentation]    Read Device Under Test firmware and set RTE relay to OFF
    ...    state. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    Sonoff Power Off
    Sleep    2s
    RteCtrl Set OC GPIO    2    low
    RteCtrl Set OC GPIO    3    low
    RteCtrl Set OC GPIO    1    low
    # Currently the device is connected with only one of two spi-flash chips.
    # 8MB of memory on spi-flash chip 2 is unused, so only 4MB is used. Only
    # content of the SPI_1 chip will be read
    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -r /tmp/coreboot.rom
    RteCtrl Set OC GPIO    2    high-z
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    Power Cycle Off
