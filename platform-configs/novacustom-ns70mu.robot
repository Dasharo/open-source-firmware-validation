*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-tgl.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=          3200*1000
${CLEVO_DISK}=                      Samsung SSD 980 PRO
${CLEVO_USB_C_HUB}=                 4-port
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          NS50_70MU
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${USB_DEVICE}=                      SanDisk
${USB_MODEL}=                       USB Flash Memory
${CPU_MAX_FREQUENCY}=               4800
${CPU_MIN_FREQUENCY}=               300

# dasharo-compability
${FW_NO_EC_SYNC_DOWNLOAD_LINK}=
...                                 https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_v1.5.1.rom
${EC_NO_SYNC_DOWNLOAD_LINK}=
...                                 https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_ec_v1.5.1.rom
${FW_EC_SYNC_VERSION}=              v1.5.2
${EC_SYNC_VERSION}=                 2023-12-08_2b2c17a
${FW_NO_EC_SYNC_VERSION}=           v1.5.1
${EC_NO_SYNC_VERSION}=              2023-10-31_f148431
