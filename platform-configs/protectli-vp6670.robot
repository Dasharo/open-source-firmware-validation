*** Settings ***
Resource    include/protectli-vp66xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=       1100
${DEF_CORES_PER_SOCKET}=        10
${DEF_THREADS_PER_CORE}=        2
${DEF_THREADS_TOTAL}=           12
${DEF_ONLINE_CPU}=              0-11
${DEF_SOCKETS}=                 1

${POWER_CTRL}=                  sonoff
${LTE_CARD}=                    ${TBD}
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${USB_MODEL}=                   SanDisk
@{ATTACHED_USB}=                Wilk USB

${DMIDECODE_PRODUCT_NAME}=      VP6670
${HAS_E_CORES}=                 ${TRUE}

${CPU_MIN_FREQUENCY}=           400
${CPU_MAX_FREQUENCY}=           4700
${PLATFORM_CPU_SPEED}=          2.60
${PLATFORM_RAM_SPEED}=          4200
${PLATFORM_RAM_SIZE}=           32768

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-22-89-99
...                             64-62-66-22-89-9a
...                             64-62-66-22-89-9b
...                             64-62-66-22-89-9c
@{ETH_SFP_PORTS}=               64-62-66-22-89-97
...                             64-62-66-22-89-98
@{ETH_PERF_PAIR_2_G}=           enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=          enp2s0f0np0    enp2s0f1np1
