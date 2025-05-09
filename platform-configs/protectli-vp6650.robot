*** Settings ***
Resource    include/protectli-vp66xx.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${INITIAL_CPU_FREQUENCY}=               1100
${DEF_CORES_PER_SOCKET}=                2
${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   4
${DEF_ONLINE_CPU}=                      0-3
${DEF_SOCKETS}=                         1

${POWER_CTRL}=                          sonoff
${WIFI_CARD_UBUNTU}=                    Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
${LTE_CARD}=                            ${TBD}
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${USB_MODEL}=                           SanDisk

${DMIDECODE_PRODUCT_NAME}=              VP6650
${HAS_E_CORES}=                         ${TRUE}

${CPU_MIN_FREQUENCY}=                   400
${CPU_MAX_FREQUENCY}=                   4400
${PLATFORM_CPU_SPEED}=                  2.50
${PLATFORM_RAM_SPEED}=                  4200
${PLATFORM_RAM_SIZE}=                   4209492

@{ETH_PERF_PAIR_2_G}=                   enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=                  enp2s0f0np0    enp2s0f1np1

@{ETH_PORTS}=                           64-62-66-22-84-f5
...                                     64-62-66-22-84-f6
...                                     64-62-66-22-84-f7
...                                     64-62-66-22-84-f8

${SATA_SUPPORT}=                        ${True}
${TESTS_IN_XCP_NG_SUPPORT}=             ${True}
@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    ${ENV_ID_XCP_NG}


*** Keywords ***
Power On
    Protectli-common.Power On
