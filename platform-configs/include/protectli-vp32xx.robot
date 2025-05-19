*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                          ${16*1024*1024}

${MAX_CPU_TEMP}=                        82
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${ETHERNET_ID}=                         8086:125c
@{ETH_PERF_PAIR_2_G}=                   enp2s0    enp4s0

${SENSORS_CONFIG_FILE}=                 include/sensors/default-sensors-config.yaml

${DASHARO_INTEL_ME_MENU_SUPPORT}=       ${TRUE}
