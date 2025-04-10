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
${CLEVO_USB_C_HUB}=                     Thunderbolt 4 Dock

${OPTIONS_LIB}=                         options-lib_dcu
${POWER_CTRL}=                          none

${DGPU_ONLY_SUPPORT}=                   ${TRUE}

${DISK_IO_PERFORMANCE_TESTS}=           ${TRUE}

# performance
${ZIP_MULTI_COMPRESSION}=               79729    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             52410    # MIPS
${CRAY_5_K_RENDER}=                     585.333    # sec
${CRAY_4_K_RENDER}=                     326.895    # sec
${CRAY_1080_P_RENDER}=                  80.547    # sec
${COREMARK_SINGLE}=                     407451.446    # iterations/s

# disk i-o
${UBU_SEQ_READ_QUEUED}=                 5953.5    # MB/s
${UBU_SEQ_WRITE_QUEUED}=                5728.6    # MB/s
${UBU_SEQ_READ_NONQUE}=                 4357.4    # MB/s
${UBU_SEQ_WRITE_NONQUE}=                4293.5    # MB/s
${UBU_RAND_READ_QUEUED}=                5944.8    # MB/s
${UBU_RAND_WRITE_QUEUED}=               5634.1    # MB/s
${UBU_RAND_READ_NONQUE}=                3653.9    # MB/s
${UBU_RAND_WRITE_NONQUE}=               4083.7    # MB/s

${WIN_SEQ_READ_QUEUED}=                 ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_QUEUED}=                ${EMPTY}    # MB/s
${WIN_SEQ_READ_NONQUE}=                 ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_NONQUE}=                ${EMPTY}    # MB/s
${WIN_RAND_READ_QUEUED}=                ${EMPTY}    # MB/s
${WIN_RAND_WRITE_QUEUED}=               ${EMPTY}    # MB/s
${WIN_RAND_READ_NONQUE}=                ${EMPTY}    # MB/s
${WIN_RAND_WRITE_NONQUE}=               ${EMPTY}    # MB/s
