*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       2200
${DEF_CORES_PER_SOCKET}=        4
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           8
${DEF_ONLINE_CPU}=              0-7
${DEF_SOCKETS}=                 1

${POWER_CTRL}=                  sonoff
${WIFI_CARD_UBUNTU}=            Qualcomm Atheros QCA6174
${LTE_CARD}=                    ${TBD}
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk

${DMIDECODE_PRODUCT_NAME}=      VP4650

${CPU_MAX_FREQUENCY}=           4300
${CPU_MIN_FREQUENCY}=           300

${TPM_EXPECTED_CHIP}=           SLB9665
