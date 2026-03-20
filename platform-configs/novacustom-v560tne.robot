*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
${CPU}=                                         Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                         3mdeb_abr
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=                      V5xTNC_TND_TNE

${CPU_MAX_FREQUENCY}=                           4800
${CPU_MIN_FREQUENCY}=                           200
${PLATFORM_CPU_SPEED}=                          3.0
${PLATFORM_RAM_SPEED}=                          5600
${PLATFORM_RAM_SIZE}=                           32768

${INITIAL_DUT_CONNECTION_METHOD}=               SSH
${DUT_CONNECTION_METHOD}=                       SSH
${POWER_CTRL}=                                  none
${OPTIONS_LIB}=                                 options-lib_dcu
${CHECK_POWER_LED_SUPPORT}=                     ${FALSE}
${DTS_SUPPORT}=                                 ${TRUE}

${CLEVO_BATTERY_CAPACITY}=                      5100*1000
${FAN_SPEED_MEASURE_SUPPORT}=                   ${TRUE}
${CUSTOM_NETWORK_BOOT_ENTRIES_SUPPORT}=         ${TRUE}

${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
${DEFAULT_BOOT_OS_ID}=                          ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=                        ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}    ${ENV_ID_QUBES}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${FALSE}
${NETBOOT_UTILITIES_SUPPORT}=                   ${TRUE}

# DMI
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v1.0.0
${DMIDECODE_RELEASE_DATE}=                      01/29/2026

${USB_DETECTION_ITERATIONS_NUMBER}=             3
${BOOT_FROM_USB_ITERATIONS_NUMBER}=             3
${WIFI_CARD}=                                   Intel(R) Wi-Fi 6E AX211 160MHz
${DGPU_ONLY_SUPPORT}=                           ${TRUE}
${CLEVO_USB_C_HUB}=                             Thunderbolt 4 Dock
${WEBCAM_UBUNTU}=                               Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${USB_MODEL}=                                   SanDisk
${USB_DEVICE}=                                  SanDisk
@{ATTACHED_USB}=                                SanDisk

# performance
&{CPP_CRAY_1080_P_BENCHMARK}=
...                                             name=Resolution: 1080p - Rays Per Pixel: 16
...                                             score=80.547
...                                             scale=lower_is_better
...                                             dev=0.2
...                                             type=singlecore
&{CPP_CRAY_4_K_BENCHMARK}=
...                                             name=Resolution: 4K - Rays Per Pixel: 16
...                                             score=326.895
...                                             scale=lower_is_better
...                                             dev=0.2
...                                             type=singlecore
&{CPP_CRAY_5_K_BENCHMARK}=
...                                             name=Resolution: 5K - Rays Per Pixel: 16
...                                             score=585.333
...                                             scale=lower_is_better
...                                             dev=0.2
...                                             type=singlecore
&{CPP_COREMARK_BENCHMARK}=
...                                             name=CoreMark Size 666 - Iterations Per Second
...                                             score=407451.446
...                                             scale=higher_is_better
...                                             dev=0.2
...                                             type=singlecore
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                             name=Test: Compression Rating
...                                             score=79729
...                                             scale=higher_is_better
...                                             dev=0.2
...                                             type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                             name=Test: Decompression Rating
...                                             score=52410
...                                             scale=higher_is_better
...                                             dev=0.2
...                                             type=multicore
@{CPP_BENCHMARKS}=
...                                             &{CPP_CRAY_1080_P_BENCHMARK}
...                                             &{CPP_CRAY_4_K_BENCHMARK}
...                                             &{CPP_CRAY_5_K_BENCHMARK}
...                                             &{CPP_COREMARK_BENCHMARK}
...                                             &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                             &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

# disk i-o
${DISK_IO_REFERENCE_DISK_NAME}=                 SSDPR-PX700
${UBU_SEQ_READ_QUEUED}=                         5953.5    # MB/s
${UBU_SEQ_WRITE_QUEUED}=                        5728.6    # MB/s
${UBU_SEQ_READ_NONQUE}=                         4357.4    # MB/s
${UBU_SEQ_WRITE_NONQUE}=                        4293.5    # MB/s
${UBU_RAND_READ_QUEUED}=                        5944.8    # MB/s
${UBU_RAND_WRITE_QUEUED}=                       5634.1    # MB/s
${UBU_RAND_READ_NONQUE}=                        3653.9    # MB/s
${UBU_RAND_WRITE_NONQUE}=                       4083.7    # MB/s

${WIN_SEQ_READ_QUEUED}=                         ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_QUEUED}=                        ${EMPTY}    # MB/s
${WIN_SEQ_READ_NONQUE}=                         ${EMPTY}    # MB/s
${WIN_SEQ_WRITE_NONQUE}=                        ${EMPTY}    # MB/s
${WIN_RAND_READ_QUEUED}=                        ${EMPTY}    # MB/s
${WIN_RAND_WRITE_QUEUED}=                       ${EMPTY}    # MB/s
${WIN_RAND_READ_NONQUE}=                        ${EMPTY}    # MB/s
${WIN_RAND_WRITE_NONQUE}=                       ${EMPTY}    # MB/s

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=               ${TRUE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=             114    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=            26.2    # FPS

# cpu performance Windows
# reference score for 155H from https://openbenchmarking.org/result/2508216-NE-SKIBIDI6461
&{UPP_SMALLPT_BENCHMARK}=
...                                             name=smallpt
...                                             score=19.02
...                                             scale=lower_is_better
...                                             dev=0.2
...                                             type=singlecore
# reference score for 155H from https://openbenchmarking.org/test/pts/crafty
&{UPP_CRAFTY_BENCHMARK}=
...                                             name=crafty
...                                             score=10919999
...                                             scale=higher_is_better
...                                             dev=0.2
...                                             type=singlecore
# reference score for 155H from https://openbenchmarking.org/result/2508217-NE-AAAAAAA9714
&{UPP_CACHEBENCH_BENCHMARK}=
...                                             name=cachebench
...                                             score=106987
...                                             scale=higher_is_better
...                                             dev=0.2
...                                             type=multicore
# reference score for 155H from    https://openbenchmarking.org/result/2508292-NE-20250829131
&{UPP_BLAKE2_BENCHMARK}=
...                                             name=blake2
...                                             score=4.06
...                                             scale=lower_is_better
...                                             dev=0.2
...                                             type=multicore
@{UPP_BENCHMARKS}=
...                                             &{UPP_SMALLPT_BENCHMARK}
...                                             &{UPP_CRAFTY_BENCHMARK}
...                                             &{UPP_CACHEBENCH_BENCHMARK}
...                                             &{UPP_BLAKE2_BENCHMARK}

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                             &{DTS_TEST_VERSIONS_BASE}
...                                             Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                        V560TNx
@{DTS_TEST_WORKFLOWS}=                          Initial Deployment    UEFI Update
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                             ${{ ("UEFI Update", "DCR") }}

${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=      ${TRUE}
