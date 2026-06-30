*** Settings ***
Resource    include/protectli-vp24xx.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}

${INITIAL_CPU_FREQUENCY}=               3300
${FLASHING_METHOD}=                     external

# eMMC driver support
${E_MMC_NAME}=                          BJTD4R

# dmidecode.robot
${DMIDECODE_SERIAL_NUMBER}=             123456789
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.9.0-rc4
${DMIDECODE_PRODUCT_NAME}=              VP2440    # this should change once vp2445 gets its own binary
${DMIDECODE_RELEASE_DATE}=              08/14/2025
${POWER_CTRL}=                          sonoff
# CPF
${CPU_MAX_FREQUENCY}=                   3400
${CPU_MIN_FREQUENCY}=                   700

${WATCHDOG_SUPPORT}=                    ${FALSE}

${DEF_THREADS_TOTAL}=                   4
${DEF_THREADS_PER_CORE}=                1
${DEF_CORES_PER_SOCKET}=                8
${DEF_SOCKETS}=                         1
${DEF_ONLINE_CPU}=                      0-3

${PLATFORM_CPU_SPEED}=                  1.0    # get-robot-variables suggests 3,40, but 0,80 is what setup menu shows
${PLATFORM_RAM_SPEED}=                  4800
${PLATFORM_RAM_SIZE}=                   32768

${CPU}=                                 Intel(R) N100

${WIFI_CARD}=                           MEDIATEK Corp. Device 7906
${WIFI_CARD_UBUNTU}=                    MEDIATEK Corp. Device 7906
${BLUETOOTH_CARD_UBUNTU}=               Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter (rev 32)
${USB_MODEL}=                           SanDisk
${USB_DEVICE}=                          SanDisk
@{ATTACHED_USB}=                        SanDisk
${EXPECTED_FW_SHA256}=                  43e9ff889ee8161d43f05d4ccc3ef370a6e2a1bd0e807fe52de7f9ad63a64894

${ESP_SCANNING_SUPPORT}=                ${TRUE}
@{ETH_PORTS}=                           64-62-66-25-05-61
...                                     64-62-66-25-05-62

@{ETH_PERF_PAIR_2_G}=                   enp3s0    enp4s0

${ETHERNET_ID}=                         8086:125c

${TPM_EXPECTED_CHIP}=                   SLB9670
${SATA_SUPPORT}=                        ${TRUE}
${DEVICE_NVME_DISK}=
...                                     Non-Volatile memory controller: Phison Electronics Corporation PS5019-E19 PCIe4 NVMe Controller
