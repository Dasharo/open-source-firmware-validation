*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-tgl.robot


*** Variables ***
${DUT_CONNECTION_METHOD}=               SSH
${PAYLOAD}=                             tianocore
${RTE_S2_N_PORT}=                       ${EMPTY}
${FLASH_SIZE}=                          ${16*1024*1024}
${TIANOCORE_STRING}=                    ENTER
${SETUP_MENU_KEY}=                      ${EMPTY}
${MANUFACTURER}=                        ${EMPTY}
${CPU}=                                 Intel(R) Core(TM) i7-1165G7 CPU
${INITIAL_CPU_FREQUENCY}=               2800
${DEF_ONLINE_CPU}=                      0-7
${DEF_SOCKETS}=                         2
${IPXE_BOOT_ENTRY}=                     iPXE Network boot
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=    ${EMPTY}
${LAPTOP_EC_SERIAL_WORKAROUND}=         ${TRUE}

# Test configuration
${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=              3200*1000
${CLEVO_DISK}=                          Samsung SSD 980 PRO
${CLEVO_USB_C_HUB}=                     4-port
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              NS50_70MU
${EXTERNAL_HEADSET}=                    USB PnP Audio Device
${SD_CARD_MODEL}=                       Transcend
${SD_CARD_VENDOR}=                      TS-RDF5A
${USB_DEVICE}=                          SanDisk
${USB_MODEL}=                           USB Flash Memory
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300
