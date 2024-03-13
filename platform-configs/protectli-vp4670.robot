*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${POWER_CTRL}=                      sonoff
${WIFI_CARD_UBUNTU}=                Qualcomm Atheros QCA6174
${LTE_CARD}=                        ${EMPTY}
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${USB_MODEL}=                       SanDisk

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.1.0
${DMIDECODE_PRODUCT_NAME}=          VP4670
${DMIDECODE_RELEASE_DATE}=          15/06/2023
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                N/A
${DMIDECODE_TYPE}=                  N/A
${DEF_CORES}=                       6
${DEF_CPU}=                         12
${DEF_ONLINE_CPU}=                  0-11
${DEF_SOCKETS}=                     1
${DEF_THREADS}=                     2
