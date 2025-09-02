*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       Telnet
${FLASH_SIZE}=                                  ${16*1024*1024}
${FLASH_LENGTH}=                                ${TBD}
${MANUFACTURER}=                                Hardkernel
${CPU}=                                         Intel(R) N97
${POWER_CTRL}=                                  RteCtrl
${FLASH_VERIFY_METHOD}=                         none
${MAX_CPU_TEMP}=                                105
${FW_VERSION}=                                  v0.9.1-rc3
${DMIDECODE_SERIAL_NUMBER}=                     123456789
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.1-rc3
${DMIDECODE_PRODUCT_NAME}=                      ODROID-H4
${DMIDECODE_RELEASE_DATE}=                      08/22/2025
${DMIDECODE_MANUFACTURER}=                      HARDKERNEL
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FAMILY}=                            H4
${DMIDECODE_TYPE}=                              Desktop
${DEVICE_USB_KEYBOARD}=                         Logitech, Inc. Keyboard K120
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${USB_DEVICE}=                                  Multifunction Composite Gadget
${FLASHROM_FLAGS}=                              ${TBD}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}=     ${EMPTY}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${EMMC_SUPPORT}=                                ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=                    ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${TRUE}
${DUT_HAS_RESET_BUTTON}=                        ${FALSE}
${DUT_HAS_CMOS_RESET}=                          ${FALSE}

${INITIAL_CPU_FREQUENCY}=                       800
${PLATFORM_CPU_SPEED}=                          2.0
${CPU_MIN_FREQUENCY}=                           800
${CPU_MAX_FREQUENCY}=                           3600
${PLATFORM_RAM_SPEED}=                          4800
${PLATFORM_RAM_SIZE}=                           8192
${E_MMC_NAME}=                                  PJ3032
${MAX_CPU_TEMP_THRESHOLD}=                      100
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
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=                 ${TRUE}
${DASHARO_SERIAL_PORT_MENU_SUPPORT}=            ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
${RELEASE_DATE_VERIFICATION}=                   ${TRUE}
${MANUFACTURER_VERIFICATION}=                   ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=                ${TRUE}
${PRODUCT_NAME_VERIFICATION}=                   ${TRUE}
${VENDOR_VERIFICATION}=                         ${TRUE}
${FAMILY_VERIFICATION}=                         ${TRUE}
${TYPE_VERIFICATION}=                           ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}
${ONLY_FLASH_BIOS}=                             ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${TRUE}
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${SUSPEND_AND_RESUME_SUPPORT}=                  ${TRUE}
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=            2
${USB_DETECTION_ITERATIONS_NUMBER}=             5
${BOOT_FROM_USB_ITERATIONS_NUMBER}=             5

${POWERSHELL_STR_HEADSET_OUT}=                  Headphones (2- High Definition Audio Device)
${POWERSHELL_STR_HEADSET_IN}=                   Microphone (2- High Definition Audio Device)

# Dasharo performance
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${PLATFORM_STABILITY_CHECKING}=                 ${TRUE}

# Dasharo security
${TPM_SUPPORTED_VERSION}=                       2
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}
${BIOS_LOCK_SUPPORT}=                           ${TRUE}
${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                 ${TRUE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${USB_STACK_SUPPORT}=                           ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}

# Dasharo stability
${NVME_DETECTION_SUPPORT}=                      ${TRUE}
${USB_TYPE_A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${CAPSULE_UPDATE_SUPPORT}=                      ${TRUE}
${STABILITY_DETECTION_SUSPEND_ITERATIONS}=      5

${CUSTOM_BOOT_ORDER_SUPPORT}=                   ${TRUE}
${HDMI_AUDIO_SUPPORT}=                          ${TRUE}
${HYPER_THREADING_SUPPORT}=                     ${TRUE}
${MEMORY_IBECC_SUPPORT}=                        ${TRUE}
${DTS_FIRMWARE_FLASHING_SUPPORT}=               ${TRUE}
${FAST_AND_QUIET_BOOT_SUPPORT}=                 ${TRUE}

${DTS_SUPPORT}=                                 ${TRUE}

# DTS E2E variables
${DTS_TEST_SYSTEM_VENDOR}=                      HARDKERNEL
${DTS_TEST_BOARD_MODEL}=                        ODROID-H4
@{DTS_TEST_WORKFLOWS}=                          Initial Deployment    UEFI Update
...                                             Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition
...                                             Dasharo (Slim Bootloader+UEFI) Initial Deployment
@{DTS_TEST_DEFAULT_RELEASES}=                   DPP
&{DTS_TEST_EXPORTS}=                            &{DTS_TEST_BASE_EXPORTS}
...                                             TEST_ME_DISABLED=false
...                                             TEST_FMAP_REGIONS=RW_SECTION_A
...                                             TEST_VBOOT_ENABLED=true
...                                             TEST_BOARD_HAS_GBE_REGION=false
...                                             TEST_SOUND_CARD_PRESENT=false
...                                             TEST_HCI_PRESENT=true

&{DTS_TEST_EXPORTS_PER_WORKFLOW}=
...                                             &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
...                                             UEFI Update=&{{ {"TEST_VBOOT_KEYS": "true", "TEST_IS_COREBOOT": "true"} }}
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                             ${{ ("Initial Deployment", "DPP") }}
...                                             ${{ ("Dasharo (coreboot+UEFI) to Dasharo (Slim Bootloader+UEFI) Transition", "DPP") }}
...                                             ${{ ("Dasharo (Slim Bootloader+UEFI) Initial Deployment", "DPP") }}


*** Keywords ***
Power On
    [Documentation]    Implementation of keywords.Power On
    Power On Default
