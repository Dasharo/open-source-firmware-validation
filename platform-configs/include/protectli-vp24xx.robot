*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=              ${16*1024*1024}
${WIFI_CARD_UBUNTU}=        Intel Corporation Wi-Fi 6 AX200 (rev 1a)
${LTE_CARD}=                Qualcomm, Inc. MDG200
${DEVICE_USB_KEYBOARD}=     Logitech, Inc. Keyboard K120
${MAX_CPU_TEMP}=            95

${SENSORS_CONFIG_FILE}=     include/sensors/default-sensors-config.yaml
