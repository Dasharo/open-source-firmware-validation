*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
${CPU}=                                 Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              V5xTNC_TND_TNE
${EXTERNAL_HEADSET}=                    USB PnP Audio Device
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   200

${NVIDIA_GRAPHICS_CARD_SUPPORT}=        ${TRUE}

${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE} # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE} # on which OS is first in the boot order

${USB_DETECTION_ITERATIONS_NUMBER}=     3
${BOOT_FROM_USB_ITERATIONS_NUMBER}=     3
${WIFI_CARD}=                           Intel(R) Wi-Fi 6E AX211 160MHz
