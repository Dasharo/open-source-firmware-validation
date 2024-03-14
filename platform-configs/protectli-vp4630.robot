*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2100
${DEF_CORES}=                       2
${DEF_THREADS}=                     2
${DEF_CPU}=                         4
${DEF_ONLINE_CPU}=                  0-3
${DEF_SOCKETS}=                     1

${WIFI_CARD_UBUNTU}=                Intel(R) Wi-Fi 6 AX200
${LTE_CARD}=                        ME906s LTE
${DEVICE_NVME_DISK}=                Samsung Electronics Co Ltd NVMe
${USB_MODEL}=                       SanDisk

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.0.19
${DMIDECODE_PRODUCT_NAME}=          VP4630
${DMIDECODE_RELEASE_DATE}=          12/08/2022
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                N/A
${DMIDECODE_TYPE}=                  N/A


*** Keywords ***
Power On
    Rte Relay Power Cycle On
