*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-adl.robot


*** Variables ***
${FLASH_SIZE}=                  ${32*1024*1024}

# CPU
${CPU}=                         Intel(R) Core(TM) i5-1240P CPU
${INITIAL_CPU_FREQUENCY}=       2100
${DEF_CORES_PER_SOCKET}=        12
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           16
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=              0-15
${DEF_SOCKETS}=                 1

# Test configuration
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=      3200*1000
${CLEVO_DISK}=                  Samsung SSD 980 PRO
${CLEVO_USB_C_HUB}=             4-port
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=      NV4xPZ
# TODO verify
${DMIDECODE_RELEASE_DATE}=      03/17/2022
${EXTERNAL_HEADSET}=            USB PnP Audio Device
${SD_CARD_MODEL}=               Transcend
${SD_CARD_VENDOR}=              TS-RDF5A
${USB_DEVICE}=                  Kingston
${USB_MODEL}=                   USB Flash Memory
