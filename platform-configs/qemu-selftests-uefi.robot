*** Comments ***
This config targets QEMU firmware with as many menus enabled as possible.


*** Settings ***
Library     ../lib/QemuMonitor.py    /tmp/qmp-socket
Resource    qemu.robot
Resource    include/default.robot


*** Variables ***
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

# Test module: trenchboot
${TRENCHBOOT_SUPPORT}=                      ${TRUE}

${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=        0

# Test module: dasharo-stability
${CAPSULE_UPDATE_SUPPORT}=                  ${TRUE}
