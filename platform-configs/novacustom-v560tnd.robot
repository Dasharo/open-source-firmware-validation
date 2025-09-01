*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
${CPU}=                                 Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              V5xTNC_TND_TNE
${EXTERNAL_HEADSET}=                    USB PnP Audio Device
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   200
${PLATFORM_CPU_SPEED}=                  3.0

${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               Telnet
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${OPTIONS_LIB}=                         options-lib_uefi-setup-menu
${POWER_CTRL}=                          sonoff
${CHECK_POWER_LED_SUPPORT}=             ${FALSE}
${DTS_SUPPORT}=                         ${TRUE}

${CLEVO_BATTERY_CAPACITY}=              5100*1000
${FAN_SPEED_MEASURE_SUPPORT}=           ${TRUE}

# DMI
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.0.0-rc3
# TODO verify
${DMIDECODE_RELEASE_DATE}=              04/25/2025

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}
${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE}    # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE}    # on which OS is first in the boot order
${TESTS_IN_FEDORA_SUPPORT}=             ${FALSE}

${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}
${USB_DETECTION_ITERATIONS_NUMBER}=     3
${BOOT_FROM_USB_ITERATIONS_NUMBER}=     3
${WIFI_CARD}=                           Intel(R) Wi-Fi 6E AX211
${CLEVO_USB_C_HUB}=                     Thunderbolt 4 Dock
${WEBCAM_UBUNTU}=                       Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${USB_MODEL}=                           SanDisk
${USB_DEVICE}=                          SanDisk
@{ATTACHED_USB}=                        SanDisk

${DGPU_ONLY_SUPPORT}=                   ${TRUE}

${DISK_IO_PERFORMANCE_TESTS}=           ${TRUE}

# cpu performance Ubuntu
${ZIP_MULTI_COMPRESSION}=               79729    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             52410    # MIPS
${CRAY_5_K_RENDER}=                     585.333    # sec
${CRAY_4_K_RENDER}=                     326.895    # sec
${CRAY_1080_P_RENDER}=                  80.547    # sec
${COREMARK_SINGLE}=                     407451.446    # iterations/s

# cpu performance Windows
# reference score for 155H from https://openbenchmarking.org/result/2508216-NE-SKIBIDI6461
&{UPP_SMALLPT_BENCHMARK}=
...                                     name=smallpt
...                                     score=19.02
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
# reference score for 155H from https://openbenchmarking.org/test/pts/crafty
&{UPP_CRAFTY_BENCHMARK}=
...                                     name=crafty
...                                     score=10919999
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
# reference score for 155H from https://openbenchmarking.org/result/2508217-NE-AAAAAAA9714
&{UPP_CACHEBENCH_BENCHMARK}=
...                                     name=cachebench
...                                     score=106987
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
# reference score for 155H from    https://openbenchmarking.org/result/2508292-NE-20250829131
&{UPP_BLAKE2_BENCHMARK}=                name=blake2    score=4.06    scale=lower_is_better    dev=0.2    type=multicore
@{UPP_BENCHMARKS}=
...                                     &{UPP_SMALLPT_BENCHMARK}
...                                     &{UPP_CRAFTY_BENCHMARK}
...                                     &{UPP_CACHEBENCH_BENCHMARK}
...                                     &{UPP_BLAKE2_BENCHMARK}

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
${NVIDIA_GRAPHICS_CARD_SUPPORT}=        ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=     104.5    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    24.0    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
...                                     Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                V560TNx
@{DTS_TEST_WORKFLOWS}=
...                                     Initial Deployment    UEFI Update
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI Update", "DCR") }}
...                                     ${{ ("Fuse Platform", "DCR") }}
