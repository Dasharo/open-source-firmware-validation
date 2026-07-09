*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/default.robot


*** Variables ***
${FW_VERSION}=                                  v0.9.0-rc2
${MANUFACTURER}=                                Micro-Star International Co., Ltd.
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=                      MS-7E56
${DMIDECODE_RELEASE_DATE}=                      07/09/2026
${DMIDECODE_TYPE}=                              Desktop
${DMIDECODE_MANUFACTURER}=                      Micro-Star International Co., Ltd.
${CHECK_POWER_LED_SUPPORT}=                     ${TRUE}
${FLASH_VERIFY_METHOD}=                         none
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                         Linux Foundation Multifunction Composite Gadget
${BOOT_MENU_KEY}=                               ${F10}
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       Telnet
${POWER_CTRL}=                                  sonoff
${DUT_HAS_CMOS_RESET}=                          ${TRUE}
${FLASH_SIZE}=                                  ${32*1024*1024}
${INITIAL_CPU_FREQUENCY}=                       2400
${FLASHING_METHOD}=                             external

${SETUP_MENU_KEY}=                              ${DELETE}
${BOOT_MENU_KEY}=                               ${F11}

${DEFAULT_BOOT_OS_ID}=                          ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                             ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}

${USB_MODEL}=                                   Flash Drive
${USB_DEVICE}=                                  Multifunction Composite Gadget

# CPF
${CPU_MAX_FREQUENCY}=                           5000
${CPU_MIN_FREQUENCY}=                           400
${MAX_CPU_TEMP}=                                95

${DEF_THREADS_TOTAL}=                           12
${DEF_THREADS_PER_CORE}=                        2
${DEF_CORES_PER_SOCKET}=                        6
${DEF_SOCKETS}=                                 1
${DEF_ONLINE_CPU}=                              0-11

${PLATFORM_CPU_SPEED}=                          4.35
${PLATFORM_RAM_SPEED}=                          3733
${PLATFORM_RAM_SIZE}=                           32768
${MAX_CPU_TEMP_THRESHOLD}=                      93
${CPU}=                                         AMD Ryzen 5 8600G w/ Radeon 760M Graphics

${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${TRUE}

# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${CUSTOM_BOOT_ORDER_SUPPORT}=                   ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${IPXE_BOOT_SUPPORT}=                           ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                   ${TRUE}
${RELEASE_DATE_VERIFICATION}=                   ${TRUE}
${MANUFACTURER_VERIFICATION}=                   ${TRUE}
${VENDOR_VERIFICATION}=                         ${TRUE}
${TYPE_VERIFICATION}=                           ${TRUE}
${DTS_SUPPORT}=                                 ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                       ${FALSE}
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${L2_CACHE_SUPPORT}=                            ${TRUE}
${L3_CACHE_SUPPORT}=                            ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${SATA_SUPPORT}=                                ${TRUE}
${CPU_THROTTLING_SUPPORT}=                      ${FALSE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=                    ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            3
${NETWORK_BOOT_NEEDS_OPTION_ROMS}=              ${FALSE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORTED_VERSION}=                       2
${TPM_MULTIPLE_BANK_SUPPORT}=                   ${FALSE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=              ${FALSE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${NVME_DETECTION_SUPPORT}=                      ${TRUE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${CAPSULE_UPDATE_SUPPORT}=                      ${TRUE}
${FUM_BOOT_IPXE_FOR_AUTO_UPDATE}=               ${FALSE}
${CAPSULE_DOES_NOT_PERSIST_ACROSS_RESET}=       ${TRUE}
${CAPSULE_ON_DISK_SUPPORT}=                     ${TRUE}
${ROMHOLE_SUPPORT}=                             ${TRUE}
${USB_DETECTION_ITERATIONS_NUMBER}=             5
${BOOT_FROM_USB_ITERATIONS_NUMBER}=             5

${DCU_UUID_SUPPORT}=                            ${FALSE}
${DCU_SERIAL_SUPPORT}=                          ${FALSE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}

${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                  ${FALSE}
${TPM_EXPECTED_CHIP}=                           AMD fTPM
${USB_STACK_SUPPORT}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}
${FAST_AND_QUIET_BOOT_SUPPORT}=                 ${TRUE}
${M2_WIFI_SUPPORT}=                             ${TRUE}
${WIFI_CARD_UBUNTU}=                            Qualcomm Technologies, Inc WCN785x Wi-Fi 7


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    Power On Default
