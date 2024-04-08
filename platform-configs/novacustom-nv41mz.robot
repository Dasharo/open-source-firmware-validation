*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-tgl.robot


*** Variables ***
${FLASH_SIZE}=                  ${16*1024*1024}
${CPU}=                         Intel(R) Core(TM) i7-1165G7 CPU
${INITIAL_CPU_FREQUENCY}=       2800
${DEF_CORES_PER_SOCKET}=        4
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           8
${DEF_ONLINE_CPU}=              0-7
${DEF_SOCKETS}=                 1
# TODO check
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
${USB_DEVICE}=                  SanDisk

${DMIDECODE_PRODUCT_NAME}=      NV4XMB,ME,MZ
# TODO verify
${DMIDECODE_RELEASE_DATE}=      03/17/2022
