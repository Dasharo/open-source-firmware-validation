*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               pikvm
${DUT_CONNECTION_METHOD}=                       pikvm
${FLASH_SIZE}=                                  ${16*1024*1024}
${FLASH_LENGTH}=                                ${TBD}
${MANUFACTURER}=                                Hardkernel
${CPU}=                                         Intel(R) N97
${POWER_CTRL}=                                  RteCtrl
${FLASH_VERIFY_METHOD}=                         tianocore-shell
${WIFI_CARD}=                                   ${TBD}
${MAX_CPU_TEMP}=                                ${TBD}
${FW_VERSION}=                                  ${TBD}
${DMIDECODE_SERIAL_NUMBER}=                     123456789
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.0-rc3
${DMIDECODE_PRODUCT_NAME}=                      ODROID-H4
${DMIDECODE_RELEASE_DATE}=                      12/10/2024
${DMIDECODE_MANUFACTURER}=                      HARDKERNEL
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FAMILY}=                            Default String
${DMIDECODE_TYPE}=                              Desktop
${DEVICE_USB_KEYBOARD}=                         Logitech, Inc. Keyboard K120
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${CLEVO_DISK}=                                  Samsung SSD 990 PRO 1TB
${DEVICE_AUDIO1}=                               ALC897
${DEVICE_AUDIO2}=                               Alderlake-P HDMI
${USB_MODEL}=                                   ${TBD}
${USB_DEVICE}=                                  ${TBD}
${FLASHROM_FLAGS}=                              ${TBD}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}=     ${EMPTY}
${ETH_PORTS}=                                   ${EMPTY}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${UEFI_SHELL_SUPPORT}=                          ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${EMMC_SUPPORT}=                                ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=                    ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${TRUE}

${INITIAL_CPU_FREQUENCY}=                       800
${PLATFORM_CPU_SPEED}=                          2.0
${CPU_MIN_FREQUENCY}=                           800
${CPU_MAX_FREQUENCY}=                           3600
${PLATFORM_RAM_SPEED}=                          4800
${PLATFORM_RAM_SIZE}=                           8192
${E_MMC_NAME}=                                  PJ3032
${DEF_THREADS_TOTAL}=                           4
${DEF_THREADS_PER_CORE}=                        1
${DEF_CORES_PER_SOCKET}=                        4
${DEF_SOCKETS}=                                 1
${DEF_ONLINE_CPU}=                              0-3
${FLASH_VERIFY_OPTION}=                         UEFI Shell    # Selected One Time Boot option
${L2_CACHE_SUPPORT}=                            ${TRUE}
${L3_CACHE_SUPPORT}=                            ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${IPXE_BOOT_SUPPORT}=                           ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
${RELEASE_DATE_VERIFICATION}=                   ${TRUE}
${MANUFACTURER_VERIFICATION}=                   ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                   ${TRUE}
${VENDOR_VERIFICATION}=                         ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}
${ONLY_FLASH_BIOS}=                             ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                  ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            2

# Dasharo performance
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}

# Dasharo security
${TPM_SUPPORT}=                                 ${TRUE}
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}
${BIOS_LOCK_SUPPORT}=                           ${TRUE}
${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${TRUE}

# Dasharo stability
${NVME_DETECTION_SUPPORT}=                      ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=      5


*** Keywords ***
Power On
    Power On Default
