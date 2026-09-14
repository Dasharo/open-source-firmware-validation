*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       Telnet
${POWER_CTRL}=                                  sonoff
${FLASH_SIZE}=                                  ${64*1024*1024}

${FLASHING_METHOD}=                             external

# dmidecode.robot
${DMIDECODE_MANUFACTURER}=                      ASROCK
${DMIDECODE_VENDOR}=                            3mdeb
# ${DMIDECODE_SERIAL_NUMBER}=    123456789
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.1-rc1
${DMIDECODE_PRODUCT_NAME}=                      SPC741D8-2L2T/BCM
${DMIDECODE_RELEASE_DATE}=                      09/15/2026
${DMIDECODE_TYPE}=                              Desktop
${CHECK_POWER_LED_SUPPORT}=                     ${FALSE}
${FLASH_VERIFY_METHOD}=                         none
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${EXPECTED_FW_SHA256}=                          2cbaf3ffb9d16312a79763719d280741d18ad5480a4cd2dd022e488556d1ea1c

${DEFAULT_BOOT_OS_ID}=                          ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                             ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}

${USB_MODEL}=                                   SanDisk
${USB_DEVICE}=                                  SanDisk
@{ATTACHED_USB}=                                SanDisk

${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${FALSE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${FALSE}
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
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
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
${INTEL_HYBRID_ARCH_SUPPORT}=                   ${FALSE}
${HYPER_THREADING_SUPPORT}=                     ${TRUE}
${MEMORY_PROFILE_SUPPORT}=                      ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${SATA_SUPPORT}=                                ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            2
${PCIE_BIFURCATION_SUPPORT}=                    ${TRUE}
@{PCIE_SLOTS}=
...                                             PCIE1
...                                             PCIE3
...                                             PCIE5
...                                             PCIE7
...                                             MCIO

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
${FAMILY_VERIFICATION}=                         ${FALSE}
${ME_STATICALLY_DISABLED}=                      ${TRUE}
${TPM_EXPECTED_CHIP}=                           ${TBD}    # Can't read it as TPM doesn't work as of today
${USB_STACK_SUPPORT}=                           ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}
${FAST_AND_QUIET_BOOT_SUPPORT}=                 ${TRUE}
${STM_SUPPORT}=                                 ${TRUE}
${DEVICE_DETECT_TEST_IN_SCOPE}=                 ${TRUE}

${TRENCHBOOT_SUPPORT}=                          ${TRUE}
${TESTS_IN_METATB_SUPPORT}=                     ${TRUE}
${TXT_TESTS_SUPPORT}=                           ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    # Workaround for extremely long boot times on the server platform
    Set DUT Response Timeout    300s
    Power On Default
