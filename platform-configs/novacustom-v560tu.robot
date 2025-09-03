*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                 Intel(R) Core(TM) Ultra 5 125H
${DEF_CORES_PER_SOCKET}=                14
${DEF_THREADS_TOTAL}=                   18

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              V54x_6x_TU
${EXTERNAL_HEADSET}=                    USB PnP Audio Device
${CPU_MAX_FREQUENCY}=                   4500
${CPU_MIN_FREQUENCY}=                   300
${PLATFORM_CPU_SPEED}=                  3.0
${BLUETOOTH_CARD_UBUNTU}=               8087:0033
${WEBCAM_UBUNTU}=                       USB2.0 Camera
${CLEVO_USB_C_HUB}=                     Thunderbolt 4 Dock
${WIFI_CARD_UBUNTU}=                    Intel Corporation Wi-Fi 7
${POWER_CTRL}=                          none
${SNIPEIT}=                             no
${FLASH_SIZE}=                          33554432

${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE}
@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}
${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_FEDORA}
${USB_STACK_SUPPORT}=                   ${TRUE}
${CLEVO_BATTERY_CAPACITY}=              4602000
${USB_DEVICE}=                          SanDisk

# cpu performance Ubuntu for processor ultra 5 125H
${ZIP_MULTI_COMPRESSION}=               15923    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             12245    # MIPS
${CRAY_5_K_RENDER}=                     2210.755    # sec
${CRAY_4_K_RENDER}=                     1349.461    # sec
${CRAY_1080_P_RENDER}=                  308.289    # sec
${COREMARK_SINGLE}=                     92891.774    # iterations/s

# cpu performance Windows for processor ultra 5 125H
${SMALLPT_TEST_SCORE}=                  14.876
${CRAFTY_TEST_SCORE}=                   10237829
${CACHEBENCH_TEST_SCORE}=               125588.2
${BLAKE2_TEST_SCORE}=                   4.08

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

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=     24.5    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    23.5    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
${DTS_TEST_BOARD_MODEL}=                V560TU
@{DTS_TEST_WORKFLOWS}=                  Initial Deployment    UEFI Update    UEFI->Heads Transition
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI->Heads Transition", "DPP") }}
