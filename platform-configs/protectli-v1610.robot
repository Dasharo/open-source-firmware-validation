*** Settings ***
Resource    include/protectli-v1x10.robot


*** Variables ***
${DMIDECODE_PRODUCT_NAME}=      V1610

${CPU_MAX_FREQUENCY}=           3100
${CPU_MIN_FREQUENCY}=           800
${PLATFORM_CPU_SPEED}=          2.00
${PLATFORM_RAM_SPEED}=          2933
${PLATFORM_RAM_SIZE}=           16384

@{ETH_PERF_PAIR_2_G}=           enp4s0    enp5s0

# List of ethernet interfaces
${ETH_PORTS}=                   eno0:=64-62-66-2f-09-f0
...                             eno1:=64-62-66-2f-09-f1
...                             eno2:=64-62-66-2f-09-f2
...                             eno3:=64-62-66-2f-09-f3
...                             eno4:=64-62-66-2f-09-f4
...                             eno5:=64-62-66-2f-09-f5
