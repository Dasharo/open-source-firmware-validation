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
${SNIPEIT}=                         no
${FLASH_SIZE}=                      33554432

${TESTS_IN_WINDOWS_SUPPORT}=        ${FALSE}
${TESTS_IN_UBUNTU_SUPPORT}=         ${TRUE}
${USB_STACK_SUPPORT}=               ${TRUE}
${CLEVO_BATTERY_CAPACITY}=          4602000

# performance
${ZIP_MULTI_COMPRESSION}=           15923    # MIPS
${ZIP_MULTI_DECOMPRESSION}=         12245    # MIPS
${CRAY_5_K_RENDER}=                 ${EMPTY}    # sec
${CRAY_4_K_RENDER}=                 ${EMPTY}    # sec
${CRAY_1080_P_RENDER}=              ${EMPTY}    # sec
${COREMARK_SINGLE}=                 ${EMPTY}    # iterations/s

# disk i-o
${UBU_SEQ_READ_QUEUED}=             5953.5    # MB/s
${UBU_SEQ_WRITE_QUEUED}=            5728.6    # MB/s
${UBU_SEQ_READ_NONQUE}=             4357.4    # MB/s
${UBU_SEQ_WRITE_NONQUE}=            4293.5    # MB/s
${UBU_RAND_READ_QUEUED}=            5944.8    # MB/s
${UBU_RAND_WRITE_QUEUED}=           5634.1    # MB/s
${UBU_RAND_READ_NONQUE}=            3653.9    # MB/s
${UBU_RAND_WRITE_NONQUE}=           4083.7    # MB/s

${WIN_SEQ_READ_QUEUED}=             ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_QUEUED}=            ${EMPTY}    # MB/s
${WIN_SEQ_READ_NONQUE}=             ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_NONQUE}=            ${EMPTY}    # MB/s
${WIN_RAND_READ_QUEUED}=            ${EMPTY}    # MB/s
${WIN_RAND_WRITE_QUEUED}=           ${EMPTY}    # MB/s
${WIN_RAND_READ_NONQUE}=            ${EMPTY}    # MB/s
${WIN_RAND_WRITE_NONQUE}=           ${EMPTY}    # MB/s
