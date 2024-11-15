*** Settings ***
Resource    include/protectli-vp32xx.robot


*** Variables ***
# Automatically found variables
${POWER_CTRL}=                      sonoff

${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120

${INITIAL_CPU_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=              3,80
${CPU_MIN_FREQUENCY}=               800
${CPU_MAX_FREQUENCY}=               3800
${PLATFORM_RAM_SPEED}=              4800
${PLATFORM_RAM_SIZE}=               16384

${WIFI_CARD_UBUNTU}=                Qualcomm Atheros AR9462 Wireless Network Adapter (rev 01)
${BLUETOOTH_CARD_UBUNTU}=           Qualcomm Atheros Communications AR3012 Bluetooth 4.0

${E_MMC_NAME}=                      BJTD4R
${CPU}=                             Intel(R) Core(TM) i3-N305

${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_SERIAL_NUMBER}=         123456789
${DMIDECODE_PRODUCT_NAME}=          VP3230
${DMIDECODE_FAMILY}=                Vault Pro
${DMIDECODE_TYPE}=                  Desktop
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.0-rc4
${DMIDECODE_RELEASE_DATE}=          11/13/2024
${DEF_THREADS_TOTAL}=               8
${DEF_THREADS_PER_CORE}=            1
${DEF_CORES_PER_SOCKET}=            8
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-7
${DEVICE_AUDIO1}=                   Alderlake-P HDMI
${DEVICE_AUDIO2}=                   ${EMPTY}
${DEVICE_AUDIO1_WIN}=               N/A

${DEVICE_NVME_DISK}=                N/A
${CLEVO_DISK}=                      N/A
