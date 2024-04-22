*** Settings ***
Resource    default.robot


*** Variables ***
# For the pikvm connection, we switch between pikvm/SSH when in firmware/OS.
# We need to go back to the initial method (pikvm) when switching back from
# OS to firmware (e.g. when rebooting inside a single test case).
${INITIAL_DUT_CONNECTION_METHOD}=               pikvm
${DUT_CONNECTION_METHOD}=                       ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                     tianocore
${RTE_S2_N_PORT}=                               13541
${FLASH_SIZE}=                                  ${32*1024*1024}
${FLASH_LENGTH}=                                ${EMPTY}
${TIANOCORE_STRING}=                            to boot directly
${BOOT_MENU_KEY}=                               F11
${SETUP_MENU_KEY}=                              Delete
${BOOT_MENU_STRING}=                            Please select boot device:
${SETUP_MENU_STRING}=                           Select Entry
${IPXE_BOOT_ENTRY}=                             iPXE Network Boot
${EDK2_IPXE_CHECKPOINT}=                        iPXE Shell
${MANUFACTURER}=                                ${EMPTY}
${CPU}=                                         ${EMPTY}
${POWER_CTRL}=                                  sonoff
${FLASH_VERIFY_METHOD}=                         none
${WIFI_CARD}=                                   ${EMPTY}
${MAX_CPU_TEMP}=                                80

${DMIDECODE_MANUFACTURER}=                      Micro-Star International Co., Ltd.
${DMIDECODE_VENDOR}=                            3mdeb
${DMIDECODE_FAMILY}=                            N/A
${DMIDECODE_TYPE}=                              Desktop

${DEVICE_USB_KEYBOARD}=                         SiGma Micro Keyboard TRACER Gamma Ivory
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_AUDIO1}=                               ALC897
${DEVICE_AUDIO2}=                               Alderlake HDMI
${DEVICE_AUDIO1_WIN}=                           Realtek High Definition Audio
${WIFI_CARD_UBUNTU}=                            ${EMPTY}
${USB_MODEL}=                                   Kingston
${USB_DEVICE}=                                  Multifunction Composite Gadget
${SD_CARD_VENDOR}=                              Mass
${SD_CARD_MODEL}=                               Storage

# Configuration flags
${ANSIBLE_SUPPORT}=                             ${TRUE}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=               ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${TRUE}
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
${ESP_SCANNING_SUPPORT}=                        ${TRUE}
${DCU_UUID_SUPPORT}=                            ${TRUE}
${DCU_SERIAL_SUPPORT}=                          ${TRUE}

# Test module: dasharo-security
${TPM_SUPPORT}=                                 ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=                 ${TRUE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}
${SECURE_BOOT_SUPPORT}=                         ${TRUE}
${USB_MASS_STORAGE_SUPPORT}=                    ${TRUE}
${TCG_OPAL_DISK_PASSWORD_SUPPORT}=              ${TRUE}
${BIOS_LOCK_SUPPORT}=                           ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=                ${TRUE}
${EARLY_BOOT_DMA_SUPPORT}=                      ${TRUE}
${UEFI_PASSWORD_SUPPORT}=                       ${TRUE}

# Test module: dasharo-performance
${SERIAL_BOOT_MEASURE}=                         ${TRUE}
${CPU_TEMPERATURE_MEASURE}=                     ${TRUE}
${CPU_FREQUENCY_MEASURE}=                       ${TRUE}

# Test module: dasharo-stab
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${NVME_DETECTION_SUPPORT}=                      ${TRUE}
${USB_TYPE-A_DEVICES_DETECTION_SUPPORT}=        ${TRUE}
${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}=     ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off    ${6}
    Sleep    5s
    # read the old output
    Telnet.Read
    RteCtrl Power On

Flash MSI-PRO-Z690
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to OFF state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Put File    ${FW_FILE}    /tmp/coreboot.rom
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    /home/root/flash.sh /tmp/coreboot.rom
    ...    return_rc=True
    IF    ${rc} != 0    Fail    \nFlashrom returned status: ${rc}\n
    Should Contain Any    ${flash_result}    VERIFIED    Warning: Chip content is identical to the requested image.

Read MSI-PRO-Z690
    [Documentation]    Read Device Under Test firmware and set RTE relay to OFF
    ...    state. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    Sonoff Power Cycle Off
    Sleep    2s
    SSHLibrary.Execute Command    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -r /tmp/coreboot.rom
    Power Cycle Off
