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
${DMIDECODE_PRODUCT_NAME}=          NV4XMB,ME,MZ
# TODO verify
${DMIDECODE_RELEASE_DATE}=          03/17/2022
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${SD_CARD_MODEL}=                   Transcend
${SD_CARD_VENDOR}=                  TS-RDF5A
${USB_DEVICE}=                      SanDisk
${USB_MODEL}=                       USB Flash Memory

${NVIDIA_GRAPHICS_CARD_SUPPORT}=    ${TRUE}
