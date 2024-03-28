*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       2100
${DEF_CORES}=                   2
${DEF_THREADS}=                 2
${DEF_CPU}=                     4
${DEF_ONLINE_CPU}=              0-3
${DEF_SOCKETS}=                 1

${WIFI_CARD_UBUNTU}=            Wi-Fi 6 AX200
${LTE_CARD}=                    ME906s LTE
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP4630
