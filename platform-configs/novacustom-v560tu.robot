*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) Ultra 5 125H

${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          V560TU
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${CPU_MAX_FREQUENCY}=               4500
${CPU_MIN_FREQUENCY}=               300

${NVIDIA_GRAPHICS_CARD_SUPPORT}=    ${TRUE}
