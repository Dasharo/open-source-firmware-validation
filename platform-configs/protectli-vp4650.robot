*** Settings ***
Resource    ../os-config/ubuntu-credentials.robot


*** Variables ***
${DUT_CONNECTION_METHOD}=                           Telnet
${PAYLOAD}=                                         tianocore
${RTE_S2_N_PORT}=                                   13541
${FLASH_SIZE}=                                      ${16*1024*1024}
${FLASH_LENGTH}=                                    ${EMPTY}
${TIANOCORE_STRING}=                                to boot directly
${BOOT_MENU_KEY}=                                   ${F11}
${SETUP_MENU_KEY}=                                  ${DELETE}
${BOOT_MENU_STRING}=                                Please select boot device
${SETUP_MENU_STRING}=                               Select Entry
${PAYLOAD_STRING}=                                  ${EMPTY}
${IPXE_BOOT_ENTRY}=                                 Network Boot and Utilities
${EDK2_IPXE_CHECKPOINT}=                            Advanced
${EDK2_IPXE_START_POS}=                             2
${IPXE_STRING}=                                     ${EMPTY}
${SOL_STRING}=                                      ${EMPTY}
${SN_PATTERN}=                                      ${EMPTY}
${MANUFACTURER}=                                    ${EMPTY}
${CPU}=                                             ${EMPTY}
${POWER_CTRL}=                                      RteCtrl
${FLASH_VERIFY_METHOD}=                             none
${INCORRECT_SIGNATURES_FIRMWARE}=                   ${EMPTY}
${WIFI_CARD_UBUNTU}=                                Qualcomm Atheros QCA6174
${LTE_CARD}=                                        ${EMPTY}
${USB_MODEL}=                                       SanDisk
# ${ecc_string}    Single-bit ECC
# ${IOMMU_string}    (XEN) AMD-Vi: IOMMU 0 Enable
# ${dram_size}    ${4096}
# ${def_cores}    4
# ${def_threads}    1
# ${def_cpu}    4
# ${def_online_cpu}    0-3
# ${def_sockets}    1
# ${wol_interface}    enp3s0
# ${SD_DEV_LINUX}    /dev/mmcblk0
# ${nic_number}    ${4}
${DEVICE_USB_KEYBOARD}=                             ${EMPTY}
${DEVICE_NVME_DISK}=                                ${EMPTY}
${DEVICE_AUDIO1}=                                   ${EMPTY}
${DEVICE_AUDIO2}=                                   ${EMPTY}
${DEVICE_AUDIO1_WIN}=                               ${EMPTY}
${INITIAL_CPU_FREQUENCY}=                           ${EMPTY}
${WIN_USB_STICK}=                                   ${EMPTY}
${USB_SHORT_NAME}=                                  ${EMPTY}
${INITIAL_FAN_RPM}=                                 ${EMPTY}
${ACCEPTED_%_NEAR_INITIAL_RPM}=                     ${EMPTY}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                6
${LAPTOP_EC_SERIAL_WORKAROUND}=                     ${FALSE}

# eMMC driver support
${E_MMC_NAME}=                                      AJTD4R

# Platform flashing flags
${FLASHING_BASIC_METHOD}=                           external

${USB_LIVE}=                                        USB SanDisk 3.2Gen1
${DEVICE_USB_USERNAME}=                             user
${DEVICE_USB_PASSWORD}=                             ubuntu
${DEVICE_USB_PROMPT}=                               user@user-VP4650:~$
${DEVICE_USB_ROOT_PROMPT}=                          root@user-VP4650:/home/user#
@{ATTACHED_USB}=                                    ${USB_LIVE}

${DEVICE_WINDOWS_USERNAME}=                         user
${DEVICE_WINDOWS_PASSWORD}=                         windows
${DEVICE_WINDOWS_USER_PROMPT}=                      PS C:\Users\user>
${DEVICE_UBUNTU_USERNAME}=                          ${UBUNTU_USERNAME}
${DEVICE_UBUNTU_PASSWORD}=                          ${UBUNTU_PASSWORD}
${DEVICE_UBUNTU_USER_PROMPT}=                       ${UBUNTU_USER_PROMPT}
${DEVICE_UBUNTU_ROOT_PROMPT}=                       ${UBUNTU_ROOT_PROMPT}
${3_MDEB_WIFI_NETWORK}=                             3mdeb_abr

${DMIDECODE_SERIAL_NUMBER}=                         N/A
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.0.19
${DMIDECODE_PRODUCT_NAME}=                          VP4650
${DMIDECODE_RELEASE_DATE}=                          12/08/2022
${DMIDECODE_MANUFACTURER}=                          Protectli
${DMIDECODE_VENDOR}=                                3mdeb
${DMIDECODE_FAMILY}=                                N/A
${DMIDECODE_TYPE}=                                  N/A

${FLASHING_VBOOT_BADKEYS}=                          ${FALSE}

${ME_INTERFACE}=                                    Intel Corporation Comet Lake Management Engine Interface

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}
${TESTS_IN_UBUNTU_SERVER_SUPPORT}=                  ${TRUE}
${TESTS_IN_PROXMOX_VE_SUPPORT}=                     ${TRUE}
${TESTS_IN_PFSENSE_SERIAL_SUPPORT}=                 ${TRUE}
${TESTS_IN_PFSENSE_VGA_SUPPORT}=                    ${TRUE}
${TESTS_IN_OPNSENSE_SERIAL_SUPPORT}=                ${TRUE}
${TESTS_IN_OPNSENSE_VGA_SUPPORT}=                   ${TRUE}
${TESTS_IN_FREEBSD_SUPPORT}=                        ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=                   ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                        ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                    ${FALSE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${FALSE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=                   ${FALSE}
${DASHARO_PCIE_REBAR_SUPPORT}=                      ${FALSE}
${DASHARO_MEMORY_MENU_SUPPORT}=                     ${FALSE}
${DASHARO_SERIAL_PORT_MENU_SUPPORT}=                ${TRUE}
# Test module: dasharo-compatibility
${BASE_PORT_BOOTBLOCK_SUPPORT}=                     ${FALSE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_POSTCAR_SUPPORT}=                       ${FALSE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                      ${FALSE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=                  ${FALSE}
${PETITBOOT_PAYLOAD_SUPPORT}=                       ${FALSE}
${HEADS_PAYLOAD_SUPPORT}=                           ${FALSE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                    ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=                   ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=             ${TRUE}
${COREBOOT_FAN_CONTROL_SUPPORT}=                    ${FALSE}
${INTERNAL_LCD_DISPLAY_SUPPORT}=                    ${FALSE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=                   ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=                   ${TRUE}
${EC_AND_SUPER_IO_SUPPORT}=                         ${FALSE}
${CUSTOM_LOGO_SUPPORT}=                             ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                     ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${TRUE}
${USB_CAMERA_DETECTION_SUPPORT}=                    ${FALSE}
${USB_TYPE_C_DISPLAY_SUPPORT}=                      ${FALSE}
${UEFI_SHELL_SUPPORT}=                              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=               ${TRUE}
${IPXE_BOOT_SUPPORT}=                               ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                       ${TRUE}
${NVME_DISK_SUPPORT}=                               ${TRUE}
${SD_CARD_READER_SUPPORT}=                          ${FALSE}
${WIRELESS_CARD_SUPPORT}=                           ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=                      ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=                 ${TRUE}
${MINI_PC_IE_SLOT_SUPPORT}=                         ${FALSE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${FALSE}
${USB_C_CHARGING_SUPPORT}=                          ${FALSE}
${THUNDERBOLT_CHARGING_SUPPORT}=                    ${FALSE}
${USB_C_DISPLAY_SUPPORT}=                           ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                         ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                      ${FALSE}
${SERIAL_NUMBER_VERIFICATION}=                      ${FALSE}
${SERIAL_FROM_MAC}=                                 ${FALSE}
${FIRMWARE_NUMBER_VERIFICATION}=                    ${TRUE}
${FIRMWARE_FROM_BINARY}=                            ${FALSE}
${PRODUCT_NAME_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_VERIFICATION}=                       ${TRUE}
${RELEASE_DATE_FROM_SOL}=                           ${FALSE}
${MANUFACTURER_VERIFICATION}=                       ${TRUE}
${VENDOR_VERIFICATION}=                             ${TRUE}
${FAMILY_VERIFICATION}=                             ${FALSE}
${TYPE_VERIFICATION}=                               ${FALSE}
${HARDWARE_WP_SUPPORT}=                             ${FALSE}
${DOCKING_STATION_USB_SUPPORT}=                     ${FALSE}
${DOCKING_STATION_KEYBOARD_SUPPORT}=                ${FALSE}
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${FALSE}
${DOCKING_STATION_DETECT_SUPPORT}=                  ${FALSE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${FALSE}
${EMMC_SUPPORT}=                                    ${TRUE}
${DTS_SUPPORT}=                                     ${FALSE}
${FIRMWARE_BUILDING_SUPPORT}=                       ${FALSE}
${DEVICE_TREE_SUPPORT}=                             ${FALSE}
${DOCKING_STATION_NET_INTERFACE}=                   ${FALSE}
${DOCKING_STATION_HDMI}=                            ${FALSE}
${DOCKING_STATION_DISPLAY_PORT}=                    ${FALSE}
${UPLOAD_ON_USB_SUPPORT}=                           ${TRUE}
${DOCKING_STATION_UPLOAD_SUPPORT}=                  ${FALSE}
${THUNDERBOLT_DOCKING_STATION_SUPPORT}=             ${FALSE}
${THUNDERBOLT_DOCKING_STATION_USB_SUPPORT}=         ${FALSE}
${THUNDERBOLT_DOCKING_STATION_KEYBOARD_SUPPORT}=    ${FALSE}
${THUNDERBOLT_DOCKING_STATION_UPLOAD_SUPPORT}=      ${FALSE}
${THUNDERBOLT_DOCKING_STATION_NET_INTERFACE}=       ${FALSE}
${THUNDERBOLT_DOCKING_STATION_HDMI}=                ${FALSE}
${THUNDERBOLT_DOCKING_STATION_DISPLAY_PORT}=        ${FALSE}
${THUNDERBOLT_DOCKING_STATION_AUDIO_SUPPORT}=       ${FALSE}
${DOCKING_STATION_SD_CARD_READER_SUPPORT}=          ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                       ${TRUE}
${MEMORY_PROFILE_SUPPORT}=                          ${FALSE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VBOOT_KEYS_GENERATING_SUPPORT}=                   ${FALSE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${TRUE}
${MEASURED_BOOT_SUPPORT}=                           ${TRUE}
${SECURE_BOOT_SUPPORT}=                             ${TRUE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled
${USB_STACK_SUPPORT}=                               ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                        ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${FALSE}
${BIOS_LOCK_SUPPORT}=                               ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${FALSE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${FALSE}
${CAMERA_SWITCH_SUPPORT}=                           ${FALSE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                           ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${FALSE}
${DEVICE_BOOT_MEASURE_SUPPORT}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                           ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                         ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                     ${TRUE}
${TEST_FAN_SPEED}=                                  ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}
${UBUNTU_BOOTING}=                                  ${TRUE}
${DEBIAN_BOOTING}=                                  ${TRUE}
${UBUNTU_SERVER_BOOTING}=                           ${TRUE}
${PROXMOX_VE_BOOTING}=                              ${TRUE}
${PFSENSE_SERIAL_BOOTING}=                          ${TRUE}
${PFSENSE_VGA_BOOTING}=                             ${TRUE}
${OPNSENSE_SERIAL_BOOTING}=                         ${TRUE}
${OPNSENSE_VGA_BOOTING}=                            ${TRUE}
${FREEBSD_BOOTING}=                                 ${TRUE}
${WINDOWS_BOOTING}=                                 ${TRUE}

# Test module: dasharo-stability
${M2_WIFI_SUPPORT}=                                 ${FALSE}
${NVME_DETECTION_SUPPORT}=                          ${FALSE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=            ${FALSE}
${TPM_DETECT_SUPPORT}=                              ${FALSE}

# Supported OS installation variants
${INSTALL_DEBIAN_USB_SUPPORT}=                      ${FALSE}
${INSTALL_UBUNTU_USB_SUPPORT}=                      ${FALSE}

# Test cases iterations number
# Booting OS from USB stick test cases
${BOOT_FROM_USB_ITERATIONS_NUMBER}=                 5
# Sticks detection test cases
${USB_DETECTION_ITERATIONS_NUMBER}=                 5
# Platform boot measure test cases
${DEVICE_BOOT_MEASURE_ITTERATIONS}=                 3

# Other platform flags and counters
# Cooling procedure iterations
${COOLING_PROCEDURE_ITERATIONS}=                    0
# Stability tests duration in minutes
${STABILITY_TEST_DURATION}=                         300
# Interval between the following readings in stability tests
${STABILITY_TEST_MEASURE_INTERVAL}=                 10
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
# Number of iterations in stability detection tests
${STABILITY_DETECTION_COLDBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_WARMBOOT_ITERATIONS}=         2
${STABILITY_DETECTION_REBOOT_ITERATIONS}=           5
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=          5
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off
    Sleep    5s
    Telnet.Read
    RteCtrl Power On

Flash Protectli VP4650 External
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to ON state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sonoff Power On
    Sleep    5s
    RteCtrl Power Off
    Sleep    8s
    RteCtrl Set OC GPIO    2    low
    Sleep    2s
    RteCtrl Set OC GPIO    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    1    low
    Sleep    2s
    Sonoff Power Off
    Sleep    2s
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom -c "MX25L12835F/MX25L12845E/MX25L12865E" 2>&1
    ...    return_rc=True
    Sleep    2s
    RteCtrl Set OC GPIO    1    high-z
    RteCtrl Set OC GPIO    3    high-z
    # CMOS reset
    RteCtrl Set OC GPIO    1    low
    Sleep    10s
    RteCtrl Set OC GPIO    1    high-z
    Sleep    2s
    Sonoff Power On
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Check Coreboot Components Measurement
    [Documentation]    Check whether the hashes of the coreboot components
    ...    measurements have been stored in the TPM PCR registers.
    ${out}=    Execute Linux Command    ./cbmem -c | grep -i PCR | cat
    Should Contain    ${out}    fallback/payload` to PCR 2 measured
    Should Contain    ${out}    fallback/dsdt.aml` to PCR 2 measured
    Should Contain    ${out}    vbt.bin` to PCR 2 measured
    Should Not Contain    ${out}    Extending hash into PCR failed
