*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=              ${16*1024*1024}

${MAX_CPU_TEMP}=            82
${DEVICE_USB_KEYBOARD}=     Logitech, Inc. Keyboard K120
${ETHERNET_ID}=             8086:125c

${SENSORS_CONFIG_FILE}=     include/sensors/default-sensors-config.yaml
