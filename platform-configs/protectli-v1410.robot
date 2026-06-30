*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1410

${CPU_MAX_FREQUENCY}=           2900
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           8192
${EXPECTED_FW_SHA256}=          b955fd440f285ef364f5daa23acac9e0d8812d7209c28887fc612c03c1730680

@{ETH_PERF_PAIR_2_G}=           enp2s0    enp5s0

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-08-4a
...                             64-62-66-2f-08-4b
...                             64-62-66-2f-08-4c
...                             64-62-66-2f-08-4d
${ETHERNET_ID}=                 8086:125c
${MAX_CPU_TEMP_THRESHOLD}=      100
