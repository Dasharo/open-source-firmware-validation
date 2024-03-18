*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${POWER_CTRL}=                      sonoff
${WIFI_CARD_UBUNTU}=                Qualcomm Atheros QCA6174
${LTE_CARD}=                        ${EMPTY}
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${USB_MODEL}=                       SanDisk

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.0.19
${DMIDECODE_PRODUCT_NAME}=          VP4650
${DMIDECODE_RELEASE_DATE}=          12/08/2022
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                N/A
${DMIDECODE_TYPE}=                  N/A

${INITIAL_CPU_FREQUENCY}=       2200
${DEF_CORES}=                   4
${DEF_THREADS}=                 2
${DEF_CPU}=                     8
${DEF_ONLINE_CPU}=              0-7
${DEF_SOCKETS}=                 1