*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) Ultra 5 125H
${DEF_CORES_PER_SOCKET}=            14
${DEF_THREADS_TOTAL}=               18

${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          V54x_6x_TU
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${CPU_MAX_FREQUENCY}=               4500
${CPU_MIN_FREQUENCY}=               300
${BLUETOOTH_CARD_UBUNTU}=           8087:0033
${NVIDIA_GRAPHICS_CARD_SUPPORT}=    ${FALSE}
${WEBCAM_UBUNTU}=                   USB2.0 Camera

${POWER_CTRL}=                      none

${TESTS_IN_WINDOWS_SUPPORT}=        ${FALSE}
${USB_STACK_SUPPORT}=               ${TRUE}
