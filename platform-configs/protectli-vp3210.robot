*** Settings ***
Resource    include/protectli-vp32xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           700
${PLATFORM_CPU_SPEED}=              0.80
${CPU_MIN_FREQUENCY}=               700
${CPU_MAX_FREQUENCY}=               3400
${PLATFORM_RAM_SPEED}=              4800
${PLATFORM_RAM_SIZE}=               16384

${WIFI_CARD}=                       Qualcomm Atheros QCA61x4A Wireless Network Adapter
${WIFI_CARD_UBUNTU}=                Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
${BLUETOOTH_CARD_UBUNTU}=           Qualcomm Atheros Communications AR3012 Bluetooth 4.0

${E_MMC_NAME}=                      BJTD4R
${CPU}=                             Intel(R) N100

${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_SERIAL_NUMBER}=         123456789
${DMIDECODE_PRODUCT_NAME}=          VP3210
${DMIDECODE_FAMILY}=                Vault Pro
${DMIDECODE_TYPE}=                  Desktop
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.0-rc10
${DMIDECODE_RELEASE_DATE}=          03/14/2025
${DEF_THREADS_TOTAL}=               4
${DEF_THREADS_PER_CORE}=            1
${DEF_CORES_PER_SOCKET}=            4
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-3
${DEVICE_AUDIO1}=                   Alderlake-P HDMI
${DEVICE_AUDIO2}=                   ${EMPTY}
${DEVICE_AUDIO1_WIN}=               High Definition Audio Controller

${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${CLEVO_DISK}=                      N/A

@{ETH_PORTS}=                       64-62-66-23-90-47
...                                 64-62-66-23-90-48

${TPM_SUPPORTED_VERSION}=           2
${TPM_EXPECTED_CHIP}=               SLB9670
