*** Settings ***
    Resource    include/default.robot
    Resource    include/protectli-vp24xx

*** Variables ***

*** Settings ***
Resource    include/protectli-vp24xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           3300
${FLASHING_METHOD}=                 external

# eMMC driver support
${E_MMC_NAME}=                      BJTD4R

@{ATTACHED_USB}=                    ${TBD}

${DMIDECODE_SERIAL_NUMBER}=         123456789
${DMIDECODE_FIRMWARE_VERSION}=      N/A
${DMIDECODE_PRODUCT_NAME}=          VP2430
${DMIDECODE_RELEASE_DATE}=          N/A
${DMIDECODE_TYPE}=                  Desktop


${CPU_MAX_FREQUENCY}=               3400
${CPU_MIN_FREQUENCY}=               700

${WATCHDOG_SUPPORT}=                ${TRUE}

${DEF_THREADS_TOTAL}=               4
${DEF_THREADS_PER_CORE}=            1
${DEF_CORES_PER_SOCKET}=            4
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-3

${PLATFORM_CPU_SPEED}=              0,80    # get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_RAM_SPEED}=              4800
${PLATFORM_RAM_SIZE}=               16384

${CPU}=                             Intel(R) N100

${DEVICE_AUDIO1}=                   Alderlake-P HDMI
${DEVICE_AUDIO1_WIN}=               ${TBD}
${WIFI_CARD}=                       ${TBD}    # On Windows: "Killer(R) Wi-Fi 6 AX1650x 160MHz Wireless Network Adapter (200NGW)"
${USB_MODEL}=                       SanDisk
${USB_DEVICE}=                      SanDisk
${BLUETOOTH_CARD_UBUNTU}=           Intel Corp. AX200 Bluetooth
