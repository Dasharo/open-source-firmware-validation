*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=          9600000

${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          NS50_70MU

${USB_DEVICE}=                      SanDisk
${USB_MODEL}=                       Ultra USB
${CPU_MAX_FREQUENCY}=               4800
${CPU_MIN_FREQUENCY}=               300
${MAX_CPU_TEMP_THRESHOLD}=          100
${EXPECTED_FW_SHA256}=              c5b399891fac4f243eb12605ec54327815165594f800ef6fbc4ef5f1b85b79d1

# dasharo-compability
${FW_NO_EC_SYNC_DOWNLOAD_LINK}=
...                                 https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_v1.5.1.rom
${EC_NO_SYNC_DOWNLOAD_LINK}=
...                                 https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_ec_v1.5.1.rom
${FW_NO_EC_SYNC_VERSION}=           v1.5.1
${EC_NO_SYNC_VERSION}=              2023-10-31_f148431

# DTS E2E variables
