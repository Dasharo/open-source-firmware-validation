*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                         Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=      3200*1000
${CLEVO_DISK}=                  Samsung SSD 980 PRO
${CLEVO_USB_C_HUB}=             4-port
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=      NV4XMB,ME,MZ
${EXTERNAL_HEADSET}=            USB PnP Audio Device
${USB_DEVICE}=                  SanDisk
${USB_MODEL}=                   USB Flash Memory
${CPU_MAX_FREQUENCY}=           4800
${CPU_MIN_FREQUENCY}=           300
