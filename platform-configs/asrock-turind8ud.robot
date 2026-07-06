*** Comments ***
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=           Telnet
${DUT_CONNECTION_METHOD}=                   Telnet
${POWER_CTRL}=                              sonoff

# LinuxBoot payload: drive the firmware-specific boot flow via the LinuxBoot
# payload library instead of the default EDK2/Tianocore one. Iteration 1 relies
# on the platform automatically booting the desired OS.
${PAYLOAD}=                                 linuxboot
${PAYLOAD_LIB}=                             payload-lib_linuxboot
${TESTS_IN_LINUXBOOT_SUPPORT}=              ${TRUE}
${DUT_HAS_CMOS_RESET}=                      ${FALSE}
${DUT_HAS_POWER_BUTTON}=                    ${FALSE}
${RTC_BOOT_SUPPORT}=                        ${FALSE}
${FLASH_SIZE}=                              ${32*1024*1024}
${CPU_MIN_FREQUENCY}=                       1211
${FLASHING_METHOD}=                         external

# dmidecode.robot
${MANUFACTURER}=                            ASRock
${DMIDECODE_VENDOR}=                        3mdeb
# TODO: firmware currently reports a placeholder serial; update once coreboot
# sets a real board serial.
${DMIDECODE_SERIAL_NUMBER}=                 123456789
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo v0.9.0-rc1
# TODO: firmware currently reports "FIXME" as the SMBIOS product name; update
# this once the coreboot mainboard sets a proper product name.
${DMIDECODE_PRODUCT_NAME}=                  FIXME
${DMIDECODE_RELEASE_DATE}=                  06/25/2026
# TODO: firmware reports "Not Specified"; update once coreboot sets a family.
${DMIDECODE_FAMILY}=                        Not Specified
${DMIDECODE_TYPE}=                          Main Server Chassis
# NOTE: firmware reports the manufacturer in all-caps ("ASROCK").
${DMIDECODE_MANUFACTURER}=                  ASROCK
${CHECK_POWER_LED_SUPPORT}=                 ${FALSE}
${FLASH_VERIFY_METHOD}=                     none
${TESTS_IN_UBUNTU_SUPPORT}=                 ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=               ${FALSE}    # This flag in practice means TESTS_IN_UEFI_SUPPORT
${DEVICE_NVME_DISK}=                        Non-Volatile memory controller

${DEFAULT_BOOT_OS_ID}=                      ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                         ${ENV_ID_UBUNTU}

${CPU}=                                     AMD EPYC 9115 16-Core Processor
${CPU_MAX_FREQUENCY}=                       4118.0132
${CPU_MIN_FREQUENCY}=                       1211.1810
${MAX_CPU_TEMP}=                            80
${MAX_CPU_TEMP_THRESHOLD}=                  93

${DEF_THREADS_TOTAL}=                       32
${DEF_THREADS_PER_CORE}=                    2
${DEF_CORES_PER_SOCKET}=                    16
${DEF_SOCKETS}=                             1
${DEF_ONLINE_CPU}=                          0-31

# Test module: dasharo-compatibility
# NOTE: UEFI setup/boot-menu features (custom boot menu key, custom setup menu
# key, custom boot order, reset to defaults) do not apply to the LinuxBoot
# payload. They are intentionally omitted here so they inherit ${FALSE} from
# default.robot; their tests also skip via ${TESTS_IN_FIRMWARE_SUPPORT}.
${USB_DISKS_DETECTION_SUPPORT}=             ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=          ${TRUE}
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
${SATA_SUPPORT}=                            ${TRUE}
${CPU_THROTTLING_SUPPORT}=                  ${FALSE}
${AUDIO_SUBSYSTEM_SUPPORT}=                 ${FALSE}

# Test module: dasharo-security
${TPM_SUPPORTED_VERSION}=                   2
${TPM_MULTIPLE_BANK_SUPPORT}=               ${FALSE}
${MEASURED_BOOT_SUPPORT}=                   ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=            ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                     ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                 ${TRUE}
${CPU_FREQUENCY_MEASURE}=                   ${TRUE}

# Test module: dasharo-stability
${TPM_DETECT_SUPPORT}=                      ${TRUE}
${NVME_DETECTION_SUPPORT}=                  ${TRUE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=    ${TRUE}
${USB_DETECTION_ITERATIONS_NUMBER}=         5
${BOOT_FROM_USB_ITERATIONS_NUMBER}=         5

${SERIAL_NUMBER_VERIFICATION}=              ${TRUE}
${FAMILY_VERIFICATION}=                     ${TRUE}
# TODO: confirm TPM chip (e.g. SLB9672) once readable on the board
${TPM_EXPECTED_CHIP}=                       ${TBD}
${PLATFORM_STABILITY_CHECKING}=             ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    # Workaround for extremely long boot times on the server platform
    Set DUT Response Timeout    300s
    Power On Default
