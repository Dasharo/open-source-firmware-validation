*** Settings ***
Resource    include/protectli-vp24xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2600
${FLASHING_METHOD}=                 internal

# eMMC driver support
${E_MMC_NAME}=                      8GTF4R

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.1-rc3
${DMIDECODE_PRODUCT_NAME}=          VP2420
${DMIDECODE_RELEASE_DATE}=          1/13/2025
${DMIDECODE_TYPE}=                  Desktop

${CPU_MAX_FREQUENCY}=               2700
${CPU_MIN_FREQUENCY}=               300

${WATCHDOG_SUPPORT}=                ${TRUE}

${DEF_THREADS_TOTAL}=               4
${DEF_THREADS_PER_CORE}=            1
${DEF_CORES_PER_SOCKET}=            4
${DEF_SOCKETS}=                     1
${DEF_ONLINE_CPU}=                  0-3

${PLATFORM_CPU_SPEED}=              2.00
${PLATFORM_RAM_SPEED}=              2933
${PLATFORM_RAM_SIZE}=               8192

${WIFI_CARD}=                       Qualcomm Atheros QCA61x4A Wireless Network Adapter
${WIFI_CARD_UBUNTU}=                Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
@{ETH_PERF_PAIR_2_G}=               enp3s0    enp4s0

@{ETH_PORTS}=                       00-e0-67-1c-29-79
...                                 00-e0-67-1c-29-7a
...                                 00-e0-67-1c-29-7b
...                                 00-e0-67-1c-29-7c

${ETHERNET_ID}=                     8086:15f3
${NVME_DISK_SUPPORT}=               ${FALSE}

${TPM_EXPECTED_CHIP}=               SLB9670


*** Keywords ***
Flash Protectli VP2420 Internal
    Make Sure That Flash Locks Are Disabled
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Send File To DUT    ${FW_FILE}    /tmp/dasharo.rom
    Flash Via Internal Programmer    /tmp/dasharo.rom    "bios"
