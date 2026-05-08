*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1211

${CPU_MAX_FREQUENCY}=           2900
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           8192
${EXPECTED_FW_SHA256}=          b3ae82c5954e85d4358c71cb03ffbfdfe37bd10f3342af294dc81f3e55fd717e
# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-07-d2
...                             64-62-66-2f-07-d3
${ETHERNET_ID}=                 8086:125c
@{ETH_PERF_PAIR_2_G}=           eno0    eno1
