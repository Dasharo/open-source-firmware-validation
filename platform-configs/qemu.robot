*** Settings ***
Library     ../lib/QemuMonitor.py    /tmp/qmp-socket
Resource    include/default.robot


*** Variables ***
${DUT_CONNECTION_METHOD}=                   Telnet
${RTE_S2_N_PORT}=                           1234
${FLASH_SIZE}=                              ${8*1024*1024}
${BOOT_MENU_KEY}=                           ${ESC}
${SETUP_MENU_KEY}=                          ${F2}
${MANUFACTURER}=                            QEMU
${POWER_CTRL}=                              none
${FLASHING_METHOD}=                         none

${DMIDECODE_SERIAL_NUMBER}=                 N/A
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) v0.2.0
${DMIDECODE_PRODUCT_NAME}=                  QEMU x86 q35/ich9
${DMIDECODE_RELEASE_DATE}=                  06/21/2024
${DMIDECODE_MANUFACTURER}=                  Emulation
${DMIDECODE_VENDOR}=                        3mdeb
${DMIDECODE_FAMILY}=                        N/A
${DMIDECODE_TYPE}=                          Desktop

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=               ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                 ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=           ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=         ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=           ${TRUE}
${DASHARO_CHIPSET_MENU_SUPPORT}=            ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=         ${TRUE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=           ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=             ${TRUE}
# Test module: dasharo-compatibility
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=            ${TRUE}
${CUSTOM_SETUP_MENU_KEY_SUPPORT}=           ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=     ${TRUE}
${CUSTOM_LOGO_SUPPORT}=                     ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=             ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=          ${TRUE}
${UEFI_SHELL_SUPPORT}=                      ${TRUE}
${IPXE_BOOT_SUPPORT}=                       ${TRUE}
${AUDIO_SUBSYSTEM_SUPPORT}=                 ${TRUE}
${FIRMWARE_NUMBER_VERIFICATION}=            ${TRUE}
${PRODUCT_NAME_VERIFICATION}=               ${TRUE}
${RELEASE_DATE_VERIFICATION}=               ${TRUE}
${MANUFACTURER_VERIFICATION}=               ${TRUE}
${VENDOR_VERIFICATION}=                     ${TRUE}
${TYPE_VERIFICATION}=                       ${TRUE}
${EMMC_SUPPORT}=                            ${TRUE}
${DTS_SUPPORT}=                             ${TRUE}
${UPLOAD_ON_USB_SUPPORT}=                   ${TRUE}
${RESET_TO_DEFAULTS_SUPPORT}=               ${TRUE}
${MEMORY_PROFILE_SUPPORT}=                  ${TRUE}
${ESP_SCANNING_SUPPORT}=                    ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                             ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                   ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=             ${TRUE}
${MEASURED_BOOT_SUPPORT}=                   ${TRUE}
${SECURE_BOOT_SUPPORT}=                     ${TRUE}
${USB_STACK_SUPPORT}=                       ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                   ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                   ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                 ${TRUE}
${PLATFORM_STABILITY_CHECKING}=             ${TRUE}

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=        0


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Read From Terminal
    Qemu Monitor.System Reset
