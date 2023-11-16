*** Settings ***
Library     ../lib/QemuMonitor.py    /tmp/qmp-socket
Resource    ../os-config/ubuntu-credentials.robot


*** Variables ***
${DUT_CONNECTION_METHOD}=                           Telnet
${PAYLOAD}=                                         tianocore
${RTE_S2_N_PORT}=                                   1234
${FLASH_SIZE}=                                      ${16*1024*1024}
${FLASH_LENGTH}=                                    ${EMPTY}
${TIANOCORE_STRING}=                                to boot directly
${BOOT_MENU_KEY}=                                   ${ESC}
${SETUP_MENU_KEY}=                                  ${F2}
${BOOT_MENU_STRING}=                                Please select boot device
${SETUP_MENU_STRING}=                               Select Entry
${PAYLOAD_STRING}=                                  ${EMPTY}
${IPXE_STRING}=                                     ${EMPTY}
${IPXE_BOOT_ENTRY}=                                 iPXE
${EDK2_IPXE_CHECKPOINT}=                            iPXE Shell
${EDK2_IPXE_START_POS}=                             2
${SOL_STRING}=                                      ${EMPTY}
${SN_PATTERN}=                                      ${EMPTY}
${MANUFACTURER}=                                    QEMU
${CPU}=                                             ${EMPTY}
${POWER_CTRL}=                                      RteCtrl
${FLASH_VERIFY_METHOD}=                             ${EMPTY}
${INCORRECT_SIGNATURES_FIRMWARE}=                   ${EMPTY}
${WIFI_CARD_UBUNTU}=                                Intel(R) Wi-Fi 6 AX200
${LTE_CARD}=                                        ME906s LTE
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
${DEVICE_USB_KEYBOARD}=                             Dell Computer Corp. KB216
${DEVICE_NVME_DISK}=                                Samsung Electronics Co Ltd NVMe
${DEVICE_AUDIO1}=                                   ALC897
${DEVICE_AUDIO2}=                                   Kabylake HDMI
${DEVICE_AUDIO1_WIN}=                               High Definition Audio Device
${INITIAL_CPU_FREQUENCY}=                           2600
${WIN_USB_STICK}=                                   Kingston DataTraveler
${USB_SHORT_NAME}=                                  USB
${ME_INTERFACE}=                                    Intel Corporation Comet Lake Management Engine Interface
${INITIAL_FAN_RPM}=                                 6995
${ACCEPTED_%_NEAR_INITIAL_RPM}=                     20

# eMMC driver support
${E_MMC_NAME}=                                      MMC AJTD4R
${E_MMC_PARTITION_TABLE}=                           gpt

# Platform flashing flags
${FLASHING_BASIC_METHOD}=                           external

${USB_LIVE}=                                        USB SanDisk 3.2Gen1
${DEVICE_USB_USERNAME}=                             user
${DEVICE_USB_PASSWORD}=                             ubuntu
${DEVICE_USB_PROMPT}=                               user@user-VP4630:~$
${DEVICE_USB_ROOT_PROMPT}=                          root@user-VP4630:/home/user#
@{ATTACHED_USB}=                                    ${USB_LIVE}

${DEVICE_WINDOWS_USERNAME}=                         user
${DEVICE_WINDOWS_PASSWORD}=                         windows
${DEVICE_UBUNTU_USERNAME}=                          ${UBUNTU_USERNAME}
${DEVICE_UBUNTU_PASSWORD}=                          ${UBUNTU_PASSWORD}
${DEVICE_UBUNTU_USER_PROMPT}=                       ${UBUNTU_USER_PROMPT}
${DEVICE_UBUNTU_ROOT_PROMPT}=                       ${UBUNTU_ROOT_PROMPT}
${3_MDEB_WIFI_NETWORK}=                             3mdeb_abr

${DMIDECODE_SERIAL_NUMBER}=                         N/A
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.0.19
${DMIDECODE_PRODUCT_NAME}=                          VP4630
${DMIDECODE_RELEASE_DATE}=                          12/08/2022
${DMIDECODE_MANUFACTURER}=                          Protectli
${DMIDECODE_VENDOR}=                                3mdeb
${DMIDECODE_FAMILY}=                                N/A
${DMIDECODE_TYPE}=                                  N/A

${FLASHING_VBOOT_BADKEYS}=                          ${FALSE}
${SECURE_BOOT_DEFAULT_STATE}=                       Disabled

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}
${TESTS_IN_DEBIAN_SUPPORT}=                         ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${FALSE}
${TESTS_IN_UBUNTU_SERVER_SUPPORT}=                  ${TRUE}
${TESTS_IN_PROXMOX_VE_SUPPORT}=                     ${TRUE}
${TESTS_IN_PFSENSE_SERIAL_SUPPORT}=                 ${TRUE}
${TESTS_IN_PFSENSE_VGA_SUPPORT}=                    ${TRUE}
${TESTS_IN_OPNSENSE_SERIAL_SUPPORT}=                ${TRUE}
${TESTS_IN_OPNSENSE_VGA_SUPPORT}=                   ${TRUE}
${TESTS_IN_FREEBSD_SUPPORT}=                        ${TRUE}

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
${IPXE_BOOT_SUPPORT}=                               ${TRUE}
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
${MEMORY_PROFILE_SUPPORT}=                          ${TRUE}
${DEFAULT_POWER_STATE_AFTER_FAIL}=                  Powered Off
${ESP_SCANNING_SUPPORT}=                            ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                     ${TRUE}
${VBOOT_KEYS_GENERATING_SUPPORT}=                   ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                     ${TRUE}
${MEASURED_BOOT_SUPPORT}=                           ${TRUE}
${SECURE_BOOT_SUPPORT}=                             ${TRUE}
${ME_NEUTER_SUPPORT}=                               ${TRUE}
${USB_STACK_SUPPORT}=                               ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                        ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=                  ${FALSE}
${BIOS_LOCK_SUPPORT}=                               ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                    ${FALSE}
${WIFI_BLUETOOTH_CARD_SWITCH_SUPPORT}=              ${FALSE}
${CAMERA_SWITCH_SUPPORT}=                           ${FALSE}
${EARLY_BOOT_DMA_SUPPORT}=                          ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                           ${FALSE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                             ${TRUE}
${DEVICE_BOOT_MEASURE_SUPPORT}=                     ${FALSE}
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
# Number of docking station detection iterations after reboot
${DOCKING_STATION_REBOOT_ITERATIONS}=               2
# Number of docking station detection iterations after warmboot
${DOCKING_STATION_WARMBOOT_ITERATIONS}=             2
# Number of docking station detection iterations after coldboot
${DOCKING_STATION_COLDBOOT_ITERATIONS}=             2
# Maximum fails during performing docking station detect tests
${ALLOWED_DOCKING_STATION_DETECT_FAILS}=            0
# Number of M.2 Wi-fi card checking iterations after suspension
${M2_WIFI_ITERATIONS}=                              5
# Number of NVMe disk detection iterations after suspension
${NVME_DETECTION_ITERATIONS}=                       5
# Number of USB Type-A devices detection iterations after suspension
${USB_TYPE-A_DEVICES_DETECTION_ITERATIONS}=         5

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=                0


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Read From Terminal
    Qemu Monitor.System Reset
