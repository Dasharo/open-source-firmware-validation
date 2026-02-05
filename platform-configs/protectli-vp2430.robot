*** Settings ***
Resource    include/protectli-vp24xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=               3300
${FLASHING_METHOD}=                     external

# eMMC driver support
${E_MMC_NAME}=                          BJTD4R

${DMIDECODE_SERIAL_NUMBER}=             123456789
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.9.0-rc2
${DMIDECODE_PRODUCT_NAME}=              VP2430
${DMIDECODE_RELEASE_DATE}=              12/17/2024
${DMIDECODE_TYPE}=                      Desktop

${CPU_MAX_FREQUENCY}=                   3400
${CPU_MIN_FREQUENCY}=                   700

${WATCHDOG_SUPPORT}=                    ${FALSE}

${DEF_THREADS_TOTAL}=                   4
${DEF_THREADS_PER_CORE}=                1
${DEF_CORES_PER_SOCKET}=                4
${DEF_SOCKETS}=                         1
${DEF_ONLINE_CPU}=                      0-3

${PLATFORM_CPU_SPEED}=                  0.80    # get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_RAM_SPEED}=                  4800
${PLATFORM_RAM_SIZE}=                   49152

${CPU}=                                 Intel(R) N100

${WIFI_CARD}=                           Qualcomm Atheros QCA61x4A Wireless Network Adapter
${WIFI_CARD_UBUNTU}=                    Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter (rev 32)
${BLUETOOTH_CARD_UBUNTU}=               Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter (rev 32)
${USB_MODEL}=                           SanDisk
${USB_DEVICE}=                          SanDisk
@{ATTACHED_USB}=                        SanDisk

${ESP_SCANNING_SUPPORT}=                ${TRUE}
@{ETH_PORTS}=                           00-e0-97-1b-00-47
...                                     00-e0-97-1b-00-48
...                                     00-e0-97-1b-00-49
...                                     00-e0-97-1b-00-4a
@{ETH_PERF_PAIR_2_G}=                   enp3s0    enp4s0

${ETHERNET_ID}=                         8086:125c

${TPM_EXPECTED_CHIP}=                   SLB9670
${SATA_SUPPORT}=                        ${TRUE}
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller: Kingston Technology Company

${DEFAULT_POWER_STATE_AFTER_FAIL}=      Powered Off
