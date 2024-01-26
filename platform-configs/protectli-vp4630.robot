*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       2100
${DEF_CORES_PER_SOCKET}=        2
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           4
${DEF_ONLINE_CPU}=              0-3
${DEF_SOCKETS}=                 1

${WIFI_CARD_UBUNTU}=            Wi-Fi 6 AX200
${LTE_CARD}=                    ME906s LTE
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP4630

${PLATFORM_CPU_SPEED}=          2.60
${PLATFORM_RAM_SPEED}=          2400
${PLATFORM_RAM_SIZE}=           36864
