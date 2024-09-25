*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1210

${CPU_MAX_FREQUENCY}=           2900
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           4096

# List of ethernet interfaces
@{ETH_PORTS}=                   64-62-66-2f-00-12
...                             64-62-66-2f-00-13
${ETHERNET_ID}=                 8086:125c
