*** Settings ***
Resource    ../os/ubuntu_2204_credentials.robot
Resource    ../lib/bios/menus-dasharo.robot
Resource    ../lib/secure-boot-lib-dasharo.robot


*** Variables ***
${DUT_CONNECTION_METHOD}=                           SSH
${PAYLOAD}=                                         tianocore
${RTE_S2_N_PORT}=                                   ${EMPTY}
${FLASH_SIZE}=                                      ${16*1024*1024}
${TIANOCORE_KEY}=                                   ${F2}
${TIANOCORE_STRING}=                                ENTER
${TIANOCORE_BOOT_MENU_KEY}=                         ${F7}
${SETUP_MENU_KEY}=                                  ${EMPTY}
${MANUFACTURER}=                                    ${EMPTY}
${CPU}=                                             Intel(R) Core(TM) i7-1165G7 CPU
${INITIAL_CPU_FREQUENCY}=                           2800
${DRAM_SIZE}=                                       ${8192}
${DEF_CORES}=                                       4
${DEF_THREADS}=                                     2
${DEF_CPU}=                                         8
${DEF_ONLINE_CPU}=                                  0-7
${DEF_SOCKETS}=                                     2
${IPXE_BOOT_ENTRY}=                                 iPXE Network boot
${IPXE_STRING}=                                     Network Boot Firmware
${MAX_CPU_TEMP}=                                    77
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                ${EMPTY}

# Platform flashing flags
${FLASHING_BASIC_METHOD}=                           fwupd

# These were added    for clevo tests
${DEVICE_UBUNTU_USERNAME}=                          ${UBUNTU_USERNAME}
${DEVICE_WINDOWS_USERNAME}=                         user
${DEVICE_UBUNTU_PASSWORD}=                          ${UBUNTU_PASSWORD}
${DEVICE_WINDOWS_PASSWORD}=                         windows
${DEVICE_UBUNTU_HOSTNAME}=                          ${UBUNTU_HOSTNAME}
${CLEVO_BATTERY_CAPACITY}=                          3200*1000
# ${clevo_brightness_delta}    2376 - unfortunately it's not constant
${DEVICE_NVME_DISK}=                                Non-Volatile memory controller
${CLEVO_DISK}=                                      Samsung SSD 980 PRO
${DEVICE_USB_KEYBOARD}=                             Logitech, Inc. Keyboard K120
${USB_STICK}=                                       USB SanDisk 3.2Gen1
${WIN_USB_STICK}=                                   ${SPACE*1}USB${SPACE*2}SanDisk 3.2Gen1
${CLEVO_USB_C_HUB}=                                 4-port
${DEVICE_AUDIO1}=                                   ALC293
${DEVICE_AUDIO2}=                                   Tigerlake HDMI
${DEVICE_AUDIO1_WIN}=                               Realtek High Definition Audio
${3_MDEB_WIFI_NETWORK}=                             3mdeb_abr
${WIFI_CARD}=                                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                                Intel Corporation Wi-Fi 6 AX201 (rev 20)
${BLUETOOTH_CARD_UBUNTU}=                           Intel Corp. AX201 Bluetooth
${SD_CARD_VENDOR}=                                  TS-RDF5A
${SD_CARD_MODEL}=                                   Transcend
${INITIAL_FAN_RPM}=                                 6995
${ACCEPTED_%_NEAR_INITIAL_RPM}=                     20
${USB_MODEL}=                                       USB Flash Memory
${EXTERNAL_HEADSET}=                                USB PnP Audio Device

${DMIDECODE_SERIAL_NUMBER}=                         N/A
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.4.0
${DMIDECODE_PRODUCT_NAME}=                          NV4XMB,ME,MZ
${DMIDECODE_RELEASE_DATE}=                          N/A
${DMIDECODE_MANUFACTURER}=                          Notebook
${DMIDECODE_VENDOR}=                                3mdeb
${DMIDECODE_FAMILY}=                                Not Applicable
${DMIDECODE_TYPE}=                                  Notebook

# battery capacity (in mAh) should be given a little higher than actually is
# and converted to uAh
# regexp for prompt
# prompt contains path - it can be either ~ when in home directory, or it can
# be a full path
${DEVICE_UBUNTU_USER_PROMPT}=                       ${UBUNTU_USER_PROMPT}
${DEVICE_UBUNTU_ROOT_PROMPT}=                       ${UBUNTU_ROOT_PROMPT}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}
${TESTS_IN_UBUNTU_SERVER_SUPPORT}=                  ${FALSE}
${TESTS_IN_PROXMOX_VE_SUPPORT}=                     ${FALSE}
${TESTS_IN_PFSENSE_SERIAL_SUPPORT}=                 ${FALSE}
${TESTS_IN_PFSENSE_VGA_SUPPORT}=                    ${FALSE}
${TESTS_IN_OPNSENSE_SERIAL_SUPPORT}=                ${FALSE}
${TESTS_IN_OPNSENSE_VGA_SUPPORT}=                   ${FALSE}
${TESTS_IN_FREEBSD_SUPPORT}=                        ${FALSE}

# Regression test flags
# Test module: dasharo-compatibility
${BASE_PORT_BOOTBLOCK_SUPPORT}=                     ${FALSE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_POSTCAR_SUPPORT}=                       ${FALSE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                       ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                           ${FALSE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${FALSE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=             ${FALSE}
${COREBOOT_FAN_CONTROL_SUPPORT}=                    ${FALSE}
${DEVICE_TREE_SUPPORT}=                             ${FALSE}
${INTERNAL_LCD_DISPLAY_SUPPORT}=                    ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=                   ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=                   ${FALSE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                             ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${TRUE}
${USB_CAMERA_DETECTION_SUPPORT}=                    ${TRUE}
${USB_TYPE_C_DISPLAY_SUPPORT}=                      ${TRUE}
${UEFI_SHELL_SUPPORT}=                              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${TRUE}
${IPXE_BOOT_SUPPORT}=                               ${TRUE}
${NETBOOT_UTILITIES_SUPPORT}=                       ${FALSE}
${NVME_DISK_SUPPORT}=                               ${TRUE}
${SD_CARD_READER_SUPPORT}=                          ${TRUE}
${WIRELESS_CARD_SUPPORT}=                           ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${TRUE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${TRUE}
${USB_C_CHARGING_SUPPORT}=                          ${TRUE}
${THUNDERBOLT_CHARGING_SUPPORT}=                    ${TRUE}
${USB_C_DISPLAY_SUPPORT}=                           ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                      ${FALSE}
${SERIAL_FROM_MAC}=                                 ${FALSE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${TRUE}
${FIRMWARE_FROM_BINARY}=                            ${FALSE}
${PRODUCT_NAME_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_VERIFICATION}=                       ${FALSE}
${RELEASE_DATE_FROM_SOL}=                           ${FALSE}
${MANUFACTURER_VERIFICATION}=                       ${TRUE}
${VENDOR_VERIFICATION}=                             ${TRUE}
${FAMILY_VERIFICATION}=                             ${TRUE}
${TYPE_VERIFICATION}=                               ${TRUE}
${HARDWARE_WP_SUPPORT}=                             ${FALSE}
${CPU_TESTS_SUPPORT}=                               ${FALSE}
${L2_CACHE_SUPPORT}=                                ${FALSE}
${L3_CACHE_SUPPORT}=                                ${FALSE}
${L4_CACHE_SUPPORT}=                                ${FALSE}
${DOCKING_STATION_USB_SUPPORT}=                     ${TRUE}
${DOCKING_STATION_KEYBOARD_SUPPORT}=                ${TRUE}
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${TRUE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${TRUE}
${EMMC_SUPPORT}=                                    ${FALSE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${TRUE}
${DOCKING_STATION_NET_INTERFACE}=                   ${TRUE}
${DOCKING_STATION_HDMI}=                            ${TRUE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                           ${TRUE}
${DOCKING_STATION_UPLOAD_SUPPORT}=                  ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=                       ${TRUE}
${THUNDERBOLT_DOCKING_STATION_SUPPORT}=             ${TRUE}
${THUNDERBOLT_DOCKING_STATION_USB_SUPPORT}=         ${TRUE}
${THUNDERBOLT_DOCKING_STATION_KEYBOARD_SUPPORT}=    ${TRUE}
${THUNDERBOLT_DOCKING_STATION_UPLOAD_SUPPORT}=      ${TRUE}
${THUNDERBOLT_DOCKING_STATION_NET_INTERFACE}=       ${TRUE}
${THUNDERBOLT_DOCKING_STATION_HDMI}=                ${TRUE}
${THUNDERBOLT_DOCKING_STATION_DISPLAY_PORT}=        ${TRUE}
${THUNDERBOLT_DOCKING_STATION_AUDIO_SUPPORT}=       ${TRUE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${TRUE}
${BOOT_BLOCKING_SUPPORT}=                           ${TRUE}
${HIBERNATION_AND_RESUME_SUPPORT}=                  ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${FALSE}
${MEMORY_PROFILE_SUPPORT}=                          ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VBOOT_KEYS_GENERATING_SUPPORT}=                   ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${FALSE}
${MEASURED_BOOT_SUPPORT}=                           ${TRUE}
${SECURE_BOOT_SUPPORT}=                             ${FALSE}
${USB_STACK_SUPPORT}=                               ${FALSE}
${USB_MASS_STORAGE_SUPPORT}=                        ${FALSE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${FALSE}
${BIOS_LOCK_SUPPORT}=                               ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${FALSE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${TRUE}
${CAMERA_SWITCH_SUPPORT}=                           ${TRUE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                           ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${FALSE}
${DEVICE_BOOT_MEASURE_SUPPORT}=                     ${FALSE}
${CPU_TEMPERATURE_MEASURE}=                         ${TRUE}
${CPU_FREQUENCY_MEASURE}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                     ${TRUE}
${TEST_FAN_SPEED}=                                  ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}
${UBUNTU_BOOTING}=                                  ${FALSE}
${DEBIAN_BOOTING}=                                  ${FALSE}
${UBUNTU_SERVER_BOOTING}=                           ${FALSE}
${PROXMOX_VE_BOOTING}=                              ${FALSE}
${PFSENSE_SERIAL_BOOTING}=                          ${FALSE}
${PFSENSE_VGA_BOOTING}=                             ${FALSE}
${OPNSENSE_SERIAL_BOOTING}=                         ${FALSE}
${OPNSENSE_VGA_BOOTING}=                            ${FALSE}
${FREEBSD_BOOTING}=                                 ${FALSE}
${WINDOWS_BOOTING}=                                 ${FALSE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${TRUE}
${NVME_DETECTION_SUPPORT}=                          ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${TRUE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=         ${TRUE}

# Supported OS installation variants
${INSTALL_DEBIAN_USB_SUPPORT}=                      ${FALSE}
${INSTALL_UBUNTU_USB_SUPPORT}=                      ${FALSE}

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
${FAN_CONTROL_TEST_DURATION}=                       30
# Interval between the following readings in fan control tests
${FAN_CONTROL_MEASURE_INTERVAL}=                    3
# Custom fan curve tests duration in minutes
${CUSTOM_FAN_CURVE_TEST_DURATION}=                  30
# Interval between the following readings in custom fan curve tests
${CUSTOM_FAN_CURVE_MEASURE_INTERVAL}=               1
# Maximum fails during during performing test suite usb-boot.robot
${ALLOWED_FAILS_USB_BOOT}=                          0
# Maximum fails during during performing test suite usb-detect.robot
${ALLOWED_FAILS_USB_DETECT}=                        0
# Number of suspend and resume cycles performed during suspend test
${SUSPEND_ITERATIONS_NUMBER}=                       15
# Maximum number of fails during performing suspend and resume cycles
${SUSPEND_ALLOWED_FAILS}=                           0
# Number of Ubuntu booting iterations
${UBUNTU_BOOTING_ITERATIONS}=                       5
# Number of Debian booting iterations
${DEBIAN_BOOTING_ITERATIONS}=                       5
# Number of Ubuntu Server booting iterations
${UBUNTU_SERVER_BOOTING_ITERATIONS}=                5
# Number of Proxmox VE booting iterations
${PROXMOX_VE_BOOTING_ITERATIONS}=                   5
# Number of pfSense (serial output) booting iterations
${PFSENSE_SERIAL_BOOTING_ITERATIONS}=               5
# Number of pfSense (VGA output) booting iterations
${PFSENSE_VGA_BOOTING_ITERATIONS}=                  5
# Number of OPNsense (serial output) booting iterations
${OPNSENSE_SERIAL_BOOTING_ITERATIONS}=              5
# Number of OPNsense (VGA output) booting iterations
${OPNSENSE_VGA_BOOTING_ITERATIONS}=                 5
# Number of FreeBSD booting iterations
${FREEBSD_BOOTING_ITERATIONS}=                      5
# Number of Windows booting iterations
${WINDOWS_BOOTING_ITERATIONS}=                      5
# Maximum fails during performing booting OS tests
${ALLOWED_BOOTING_FAILS}=                           0
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=           5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=          5


*** Keywords ***
Power On
    [Documentation]    Keyword clears SSH buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    1s
    RteCtrl Power Off
    Sleep    7s
    # read the old output
    SSH.Read
    RteCtrl Power On

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
    Set Local Variable    ${CMD}    ./flashrom -p ch341a_spi -c GD25B128B/GD25Q128B -w ${fw_file}
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
    Should Contain    ${out}    FMAP` to PCR 2 measured
    Should Contain    ${out}    fallback/romstage` to PCR 2 measured
    Should Contain    ${out}    fspm.bin` to PCR 2 measured
    Should Contain    ${out}    fallback/postcar` to PCR 2 measured
    Should Contain    ${out}    cpu_microcode_blob.bin` to PCR 2 measured
    Should Contain    ${out}    fsps.bin` to PCR 2 measured
    Should Not Contain    ${out}    Extending hash into PCR failed
