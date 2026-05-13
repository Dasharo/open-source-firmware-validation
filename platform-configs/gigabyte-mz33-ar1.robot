*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=           Telnet
${DUT_CONNECTION_METHOD}=                   Telnet
${POWER_CTRL}=                              sonoff
${DUT_HAS_CMOS_RESET}=                      ${FALSE}
${FLASH_SIZE}=                              ${32*1024*1024}
${INITIAL_CPU_FREQUENCY}=                   3600
# FIXME: external flashing with RTE is unreliable (SPI VCC voltage drop)
${FLASHING_METHOD}=                         internal
${INTERNAL_PROGRAMMER_CHIPNAME}=            MX25L25635F/MX25L25645G

# dmidecode.robot
${MANUFACTURER}=                            Giga Computing
${DMIDECODE_VENDOR}=                        3mdeb
${DMIDECODE_SERIAL_NUMBER}=                 01234567890123456789AB
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) v0.9.0-rc2
${DMIDECODE_PRODUCT_NAME}=                  MZ33-AR1-000
${DMIDECODE_RELEASE_DATE}=                  04/29/2026
${DMIDECODE_FAMILY}=                        Server
${DMIDECODE_TYPE}=                          Main Server Chassis
${DMIDECODE_MANUFACTURER}=                  Giga Computing
${CHECK_POWER_LED_SUPPORT}=                 ${TRUE}
${FLASH_VERIFY_METHOD}=                     none
${TESTS_IN_UBUNTU_SUPPORT}=                 ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=               ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                ${TRUE}
${DEVICE_NVME_DISK}=                        Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                     KB216 Wired Keyboard
${BOOT_MENU_KEY}=                           ${F10}

${DEFAULT_BOOT_OS_ID}=                      ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                         ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}

# CPF
${CPU_MAX_FREQUENCY}=                       4100
${CPU_MIN_FREQUENCY}=                       1200
${MAX_CPU_TEMP}=                            80

${DEF_THREADS_TOTAL}=                       16
${DEF_THREADS_PER_CORE}=                    2
${DEF_CORES_PER_SOCKET}=                    8
${DEF_SOCKETS}=                             1
${DEF_ONLINE_CPU}=                          0-15

${PLATFORM_CPU_SPEED}=                      3.6
${PLATFORM_RAM_SPEED}=                      4800
${PLATFORM_RAM_SIZE}=                       32768
${MAX_CPU_TEMP_THRESHOLD}=                  93
${CPU}=                                     AMD EPYC 9015 8-Core Processor

${USB_MODEL}=                               Wilk
${USB_DEVICE}=                              USB 3.2 gen. 1
@{ATTACHED_USB}=                            Wilk USB 3.2 gen. 1

${DASHARO_SECURITY_MENU_SUPPORT}=           ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=         ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=         ${TRUE}

# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=            ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=           ${TRUE}
${CUSTOM_BOOT_ORDER_SUPPORT}=               ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=             ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=          ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=       ${TRUE}
${IPXE_BOOT_SUPPORT}=                       ${TRUE}
${NVME_DISK_SUPPORT}=                       ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=            ${TRUE}
${PRODUCT_NAME_VERIFICATION}=               ${TRUE}
${RELEASE_DATE_VERIFICATION}=               ${TRUE}
${MANUFACTURER_VERIFICATION}=               ${TRUE}
${VENDOR_VERIFICATION}=                     ${TRUE}
${TYPE_VERIFICATION}=                       ${TRUE}
${DTS_SUPPORT}=                             ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                   ${TRUE}
${CPU_TESTS_SUPPORT}=                       ${TRUE}
${L2_CACHE_SUPPORT}=                        ${TRUE}
${L3_CACHE_SUPPORT}=                        ${TRUE}
${ESP_SCANNING_SUPPORT}=                    ${TRUE}
${SATA_SUPPORT}=                            ${TRUE}
${CPU_THROTTLING_SUPPORT}=                  ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=               ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                 ${FALSE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=        3
${NETWORK_BOOT_NEEDS_OPTION_ROMS}=          ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=            ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORTED_VERSION}=                   2
${TPM_MULTIPLE_BANK_SUPPORT}=               ${FALSE}
${MEASURED_BOOT_SUPPORT}=                   ${TRUE}
${SECURE_BOOT_SUPPORT}=                     ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=          ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                   ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                     ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                 ${TRUE}
${CPU_FREQUENCY_MEASURE}=                   ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                      ${TRUE}
${NVME_DETECTION_SUPPORT}=                  ${TRUE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=    ${TRUE}
${CAPSULE_UPDATE_SUPPORT}=                  ${TRUE}
${FUM_BOOT_IPXE_FOR_AUTO_UPDATE}=           ${FALSE}
${USB_DETECTION_ITERATIONS_NUMBER}=         5
${BOOT_FROM_USB_ITERATIONS_NUMBER}=         5

${DCU_UUID_SUPPORT}=                        ${TRUE}
${DCU_SERIAL_SUPPORT}=                      ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                     ${TRUE}

${DASHARO_PCI_PCIE_MENU_SUPPORT}=           ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=              ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=     ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=              ${TRUE}
${FAMILY_VERIFICATION}=                     ${TRUE}
${TPM_EXPECTED_CHIP}=                       SLB9672
${USB_STACK_SUPPORT}=                       ${TRUE}
${PLATFORM_STABILITY_CHECKING}=             ${TRUE}
${FAST_AND_QUIET_BOOT_SUPPORT}=             ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    # Workaround for extremely long boot times on the server platform
    Set DUT Response Timeout    300s
    Power On Default
