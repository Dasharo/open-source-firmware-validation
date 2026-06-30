*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1610

${CPU_MAX_FREQUENCY}=           3100
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           16384
${EXPECTED_FW_SHA256}=          11332580c340a070ef923e6de16ef5c85adc3c95fbdaa8a5f5c1a77a1d6f7ee6

@{ETH_PERF_PAIR_2_G}=           enp4s0    enp5s0

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-09-f0
...                             64-62-66-2f-09-f1
...                             64-62-66-2f-09-f2
...                             64-62-66-2f-09-f3
...                             64-62-66-2f-09-f4
...                             64-62-66-2f-09-f5
${ETHERNET_ID}=                 8086:125c
