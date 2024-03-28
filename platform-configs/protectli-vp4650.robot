*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       2200
${DEF_CORES}=                   4
${DEF_THREADS}=                 2
${DEF_CPU}=                     8
${DEF_ONLINE_CPU}=              0-7
${DEF_SOCKETS}=                 1

${POWER_CTRL}=                  sonoff
${WIFI_CARD_UBUNTU}=            Qualcomm Atheros QCA6174
${LTE_CARD}=                    ${EMPTY}
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP4650
