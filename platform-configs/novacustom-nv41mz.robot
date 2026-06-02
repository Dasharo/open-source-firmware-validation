*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                         Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=      3250000

${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=      NV4XMB,ME,MZ

${USB_DEVICE}=                  SanDisk
${USB_MODEL}=                   USB Flash Memory
${CPU_MAX_FREQUENCY}=           4800
${CPU_MIN_FREQUENCY}=           300

${OPTIONS_LIB}=                 options-lib_dcu
${EXPECTED_FW_SHA256}=          c5b399891fac4f243eb12605ec54327815165594f800ef6fbc4ef5f1b85b79d1
# DTS E2E variables
