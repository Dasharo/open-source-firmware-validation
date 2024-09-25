*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1410

${CPU_MAX_FREQUENCY}=           2900
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           8192

@{ETH_PERF_PAIR_2_G}=           enp2s0    enp5s0

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-08-4a
...                             64-62-66-2f-08-4b
...                             64-62-66-2f-08-4c
...                             64-62-66-2f-08-4d
${ETHERNET_ID}=                 8086:125c
