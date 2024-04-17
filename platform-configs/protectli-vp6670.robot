*** Settings ***
Resource    include/protectli-vp66xx.robot


*** Variables ***
${SNIPEIT}=                     no
${INITIAL_CPU_FREQUENCY}=       1100
${DEF_CORES_PER_SOCKET}=        6
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           12
${DEF_ONLINE_CPU}=              0-11
${DEF_SOCKETS}=                 1

${POWER_CTRL}=                  sonoff
${WIFI_CARD_UBUNTU}=            ${EMPTY}
${LTE_CARD}=                    ${EMPTY}
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP6670
