*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       1100
${DEF_CORES_PER_SOCKET}=        6
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           12
${DEF_ONLINE_CPU}=              0-11
${DEF_SOCKETS}=                 1

${POWER_CTRL}=                  sonoff
${WIFI_CARD_UBUNTU}=            Qualcomm Atheros QCA6174
${LTE_CARD}=                    ${EMPTY}
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP4670

${CPU_MAX_FREQUENCY}=           5000
${CPU_MIN_FREQUENCY}=           300
