*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       Telnet
${POWER_CTRL}=                                  sonoff
${FLASH_SIZE}=                                  ${64*1024*1024}

${INITIAL_CPU_FREQUENCY}=                       2000
${FLASHING_METHOD}=                             external

# dmidecode.robot
${MANUFACTURER}=                                ASROCK
${DMIDECODE_MANUFACTURER}=                      ${MANUFACTURER}
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_SERIAL_NUMBER}=                     123456789
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.0-rc4
${DMIDECODE_PRODUCT_NAME}=                      SPC741D8-2L2T/BCM
${DMIDECODE_RELEASE_DATE}=                      09/17/2025
${DMIDECODE_TYPE}=                              Desktop
${DMIDECODE_FAMILY}=                            Not Specified
${CHECK_POWER_LED_SUPPORT}=                     ${FALSE}
${FLASH_VERIFY_METHOD}=                         iPXE-boot
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller

${DEFAULT_BOOT_OS_ID}=                          ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                             ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}

# CPF
${CPU_MAX_FREQUENCY}=                           3999
${CPU_MIN_FREQUENCY}=                           700
${MAX_CPU_TEMP}=                                80

${WATCHDOG_SUPPORT}=                            ${FALSE}

${DEF_THREADS_TOTAL}=                           24
${DEF_THREADS_PER_CORE}=                        2
${DEF_CORES_PER_SOCKET}=                        12
${DEF_SOCKETS}=                                 1
${DEF_ONLINE_CPU}=                              0-23

# get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_CPU_SPEED}=                          2.0
${PLATFORM_RAM_SPEED}=                          4000
${PLATFORM_RAM_SIZE}=                           16384
${MAX_CPU_TEMP_THRESHOLD}=                      93
${CPU}=                                         Intel(R) Xeon(R) Silver 4410Y

${USB_MODEL}=                                   SanDisk
${USB_DEVICE}=                                  SanDisk
@{ATTACHED_USB}=                                SanDisk

${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${FALSE}
${PLATFORM_SLEEP_TYPE_SELECTABLE}=              ${FALSE}
${DASHARO_MEMORY_MENU_SUPPORT}=                 ${TRUE}
# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${IPXE_BOOT_SUPPORT}=                           ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
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
${INTEL_HYBRID_ARCH_SUPPORT}=                   ${TRUE}
${HYPER_THREADING_SUPPORT}=                     ${TRUE}
${MEMORY_PROFILE_SUPPORT}=                      ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${SATA_SUPPORT}=                                ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            2

# Test module: dasharo-security
${TPM_SUPPORTED_VERSION}=                       2
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                 ${TRUE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=              ${TRUE}
${BIOS_LOCK_SUPPORT}=                           ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${NVME_DETECTION_SUPPORT}=                      ${TRUE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=     ${TRUE}
${CAPSULE_UPDATE_SUPPORT}=                      ${TRUE}
${ROMHOLE_SUPPORT}=                             ${TRUE}
${USB_DETECTION_ITERATIONS_NUMBER}=             5
${BOOT_FROM_USB_ITERATIONS_NUMBER}=             5

${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}

${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}
${HDMI_AUDIO_SUPPORT}=                          ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
${FAMILY_VERIFICATION}=                         ${TRUE}
${ME_STATICALLY_DISABLED}=                      ${TRUE}
${TPM_EXPECTED_CHIP}=                           ${TBD}    # Can't read it as TPM doesn't work as of today
${USB_STACK_SUPPORT}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}
${FAST_AND_QUIET_BOOT_SUPPORT}=                 ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    # Workaround for extremely long boot times on the server platform
    Set DUT Response Timeout    300s
    Power On Default
