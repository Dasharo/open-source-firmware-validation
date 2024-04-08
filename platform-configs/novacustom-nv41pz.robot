*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-adl.robot


*** Variables ***
${FLASH_SIZE}=                  ${32*1024*1024}
${CPU}=                         Intel(R) Core(TM) i5-1240P CPU
${INITIAL_CPU_FREQUENCY}=       2100
${DEF_CORES_PER_SOCKET}=        12
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           16
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=              0-15
${DEF_SOCKETS}=                 1
${DEVICE_IP}=                   192.168.4.240

# Platform flashing flags

${CLEVO_BATTERY_CAPACITY}=      3200*1000
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${CLEVO_DISK}=                  Samsung SSD 980 PRO
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${CLEVO_USB_C_HUB}=             4-port
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${SD_CARD_VENDOR}=              TS-RDF5A
${SD_CARD_MODEL}=               Transcend
${DEVICE_AUDIO1_WIN}=           Realtek High Definition Audio
${USB_MODEL}=                   USB Flash Memory
${EXTERNAL_HEADSET}=            USB PnP Audio Device
${USB_DEVICE}=                  Kingston

${DMIDECODE_PRODUCT_NAME}=      NV4xPZ
# TODO verify
${DMIDECODE_RELEASE_DATE}=      03/17/2022
