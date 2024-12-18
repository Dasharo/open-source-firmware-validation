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

${CPU_MAX_FREQUENCY}=           4200
${CPU_MIN_FREQUENCY}=           300

@{ETH_PORTS}=                   00-e0-97-1b-99-50
...                             00-e0-97-1b-99-51
...                             00-e0-97-1b-99-52
...                             00-e0-97-1b-99-53
...                             00-e0-97-1b-99-54
...                             00-e0-97-1b-99-55
