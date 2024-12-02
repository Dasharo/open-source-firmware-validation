*** Settings ***
Resource    include/protectli-vp32xx.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      VP3210
${POWER_CTRL}=                  sonoff

${INITIAL_CPU_FREQUENCY}=       800
${PLATFORM_CPU_SPEED}=          3,80
${CPU_MIN_FREQUENCY}=           800
${CPU_MAX_FREQUENCY}=           3800
${PLATFORM_RAM_SPEED}=          4800
${PLATFORM_RAM_SIZE}=           16384
${WIFI_CARD_UBUNTU}=            Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter (rev 30)
${BLUETOOTH_CARD_UBUNTU}=       Qualcomm Atheros Communications AR3012 Bluetooth 4.0
${E_MMC_NAME}=                  BJTD4R
${CPU}=                         Intel(R) Core(TM) i3-N305
${DMIDECODE_MANUFACTURER}=      Protectli
${DMIDECODE_SERIAL_NUMBER}=     123456789
${DMIDECODE_FAMILY}=            Vault Pro
${DMIDECODE_TYPE}=              Desktop
${DEF_THREADS_TOTAL}=           8
${DEF_THREADS_PER_CORE}=        1
${DEF_CORES_PER_SOCKET}=        8
${DEF_SOCKETS}=                 1
${DEF_ONLINE_CPU}=              0-7
${DEVICE_AUDIO1}=               Alderlake-P HDMI
${FLASH_SIZE}=                  ${16*1024*1024}
