*** Settings ***
Resource    include/protectli-vp46xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2200
${DEF_CORES_PER_SOCKET}=            4
${DEF_THREADS_PER_CORE}=            2
${DEF_THREADS_TOTAL}=               8
${DEF_ONLINE_CPU}=                  0-7
${DEF_SOCKETS}=                     1
${PLATFORM_CPU_SPEED}=              2.20
${PLATFORM_RAM_SPEED}=              2667
${PLATFORM_RAM_SIZE}=               65536

${FLASHING_METHOD}=                 internal

${POWER_CTRL}=                      sonoff
${WIFI_CARD}=                       Qualcomm Atheros QCA61x4A Wireless Network Adapter
${WIFI_CARD_UBUNTU}=                Qualcomm Atheros QCA6174
${LTE_CARD}=                        ${TBD}
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${USB_MODEL}=                       SanDisk
${EXPECTED_FW_SHA256}=              3e809b17cc96f60e4d6eb825055600b70c0f9ab8a5899ec9edce729751093796
${DMIDECODE_PRODUCT_NAME}=          VP4651

${CPU_MAX_FREQUENCY}=               4300
${CPU_MIN_FREQUENCY}=               300

${ETHERNET_ID}=                     8086:125c
@{ETH_PORTS}=                       64-62-66-25-23-7b
...                                 64-62-66-25-23-7c
...                                 64-62-66-25-23-7d
...                                 64-62-66-25-23-7e
...                                 64-62-66-25-23-7f
...                                 64-62-66-25-23-80

${TPM_SUPPORTED_VERSION}=           2
${TPM_EXPECTED_CHIP}=               SLB9665

${AUDIO_SUBSYSTEM_SUPPORT}=         ${TRUE}
${EXTERNAL_HEADSET_SUPPORT}=        ${TRUE}
${POWERSHELL_STR_HEADSET_OUT}=      Headphones (2- High Definition Audio Device)
${POWERSHELL_STR_HEADSET_IN}=       Microphone (2- High Definition Audio Device)
${POWERSHELL_STR_HDMI_OUT}=         Display Audio

${EMMC_SUPPORT}=                    ${FALSE}
${E_MMC_NAME}=                      ${NONE}
