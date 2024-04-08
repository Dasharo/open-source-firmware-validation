*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-adl.robot


*** Variables ***
# CPU
${CPU}=                         Intel(R) Core(TM) i5-1240P CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=      3200*1000
${CLEVO_DISK}=                  Samsung SSD 980 PRO
${CLEVO_USB_C_HUB}=             4-port
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=      NV4xPZ
${EXTERNAL_HEADSET}=            USB PnP Audio Device
${SD_CARD_MODEL}=               Transcend
${SD_CARD_VENDOR}=              TS-RDF5A
${USB_DEVICE}=                  Kingston
${USB_MODEL}=                   USB Flash Memory
