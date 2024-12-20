*** Settings ***
Resource    default.robot


*** Variables ***
${MANUFACTURER}=                                Dell
${FLASH_VERIFY_METHOD}=                         tianocore-shell
${FLASH_VERIFY_OPTION}=                         UEFI Shell    # Selected One Time Boot option

# Platform flashing flags
${INITIAL_DUT_CONNECTION_METHOD}=               Telnet
${DUT_CONNECTION_METHOD}=                       ${INITIAL_DUT_CONNECTION_METHOD}
${FLASH_SIZE}=                                  ${4*1024*1024}
${BOOT_MENU_KEY}=                               ${F7}
${SETUP_MENU_KEY}=                              ${F2}
${IPXE_BOOT_ENTRY}=                             Network Boot and Utilities
${POWER_CTRL}=                                  sonoff
${MAX_CPU_TEMP}=                                80
${TPM_EXPECTED_VERSION}=                        1

${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FAMILY}=                            N/A
${DMIDECODE_TYPE}=                              Desktop

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                ${TRUE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=                 ${TRUE}
# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=                ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=               ${TRUE}
${EXTERNAL_HDMI_DISPLAY_SUPPORT}=               ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                         ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${UEFI_SHELL_SUPPORT}=                          ${TRUE}
${UEFI_COMPATIBLE_INTERFACE_SUPPORT}=           ${TRUE}
${IPXE_BOOT_SUPPORT}=                           ${TRUE}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${SD_CARD_READER_SUPPORT}=                      ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                     ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=                    ${TRUE}
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
${MEMORY_PROFILE_SUPPORT}=                      ${TRUE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                 ${TRUE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=              ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}
${TPM_EXPECTED_CHIP}=                           N/A

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=     ${TRUE}

${RESET_TO_DEFAULTS_SUPPORT}=                   ${TRUE}
${BASE_PORT_ROMSTAGE_SUPPORT}=                  ${TRUE}
${BASE_PORT_POSTCAR_SUPPORT}=                   ${TRUE}
${BASE_PORT_RAMSTAGE_SUPPORT}=                  ${TRUE}
${BASE_PORT_ALLOCATOR_V4_SUPPORT}=              ${TRUE}
${SERIAL_NUMBER_VERIFICATION}=                  ${TRUE}
${FAMILY_VERIFICATION}=                         ${TRUE}
${NETBOOT_UTILITIES_SUPPORT}=                   ${TRUE}
${HIBERNATION_AND_RESUME_SUPPORT}=              ${TRUE}


*** Keywords ***
Power On
    Power On Default
