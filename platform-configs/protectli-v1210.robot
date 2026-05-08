*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1210

${CPU_MAX_FREQUENCY}=           2900
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           4096
${EXPECTED_FW_SHA256}=          a012adad6be96ebc28a6550e338f49f41d52fbab737cf454a5391c769040f871

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-00-12
...                             64-62-66-2f-00-13
${ETHERNET_ID}=                 8086:125c
@{ETH_PERF_PAIR_2_G}=           eno0    eno1
${MAX_CPU_TEMP_THRESHOLD}=      100
