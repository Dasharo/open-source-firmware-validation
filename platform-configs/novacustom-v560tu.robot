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
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.0.1
${DMIDECODE_RELEASE_DATE}=              01/29/2026
${EXPECTED_FW_SHA256}=                  22c644a19d7f883bcf19ca42943c62afe81b2ead697ae883d89200ff5bf23fc0

${CPU_MAX_FREQUENCY}=                   4500
${CPU_MIN_FREQUENCY}=                   300
${PLATFORM_CPU_SPEED}=                  3.0
${BLUETOOTH_CARD_UBUNTU}=               8087:0033
${WEBCAM_UBUNTU}=                       USB2.0 Camera

${WIFI_CARD_UBUNTU}=                    Intel Corporation Wi-Fi 7
${POWER_CTRL}=                          none
${SNIPEIT}=                             no
${FLASH_SIZE}=                          33554432

${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE}
${WAKE_ON_LAN_SUPPORT}=                 ${TRUE}
@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}    ${ENV_ID_QUBES}
${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
${USB_STACK_SUPPORT}=                   ${TRUE}
${CLEVO_BATTERY_CAPACITY}=              4602000
${USB_DEVICE}=                          SanDisk
${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}

# cpu performance Ubuntu for processor ultra 5 125H
&{CPP_CRAY_1080_P_BENCHMARK}=
...                                     name=Resolution: 1080p - Rays Per Pixel: 16
...                                     score=308.289
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_CRAY_4_K_BENCHMARK}=
...                                     name=Resolution: 4K - Rays Per Pixel: 16
...                                     score=1349.461
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_CRAY_5_K_BENCHMARK}=
...                                     name=Resolution: 5K - Rays Per Pixel: 16
...                                     score=2210.755
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_COREMARK_BENCHMARK}=
...                                     name=CoreMark Size 666 - Iterations Per Second
...                                     score=92891.774
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                     name=Test: Compression Rating
...                                     score=15923
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                     name=Test: Decompression Rating
...                                     score=12245
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
@{CPP_BENCHMARKS}=
...                                     &{CPP_COREMARK_BENCHMARK}
...                                     &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                     &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

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
&{UPP_BLAKE2_BENCHMARK}=
...                                     name=blake2
...                                     score=4.06
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=multicore
@{UPP_BENCHMARKS}=
...                                     &{UPP_SMALLPT_BENCHMARK}
...                                     &{UPP_CRAFTY_BENCHMARK}
...                                     &{UPP_CACHEBENCH_BENCHMARK}
...                                     &{UPP_BLAKE2_BENCHMARK}

&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                     SEQ_READ_QUEUED=5953
...                                     SEQ_WRITE_QUEUED=5728
...                                     SEQ_READ_NONQUE=4357
...                                     SEQ_WRITE_NONQUE=4293
...                                     RAND_READ_QUEUED=5944
...                                     RAND_WRITE_QUEUED=5634
...                                     RAND_READ_NONQUE=3653
...                                     RAND_WRITE_NONQUE=4083

&{DISK_IO_REFERENCE_VALUES_WINDOWS}=    &{DISK_IO_REFERENCE_VALUES_UBUNTU}

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=     24.5    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    23.5    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
...                                     UEFI Update=Dasharo (coreboot+UEFI) 1.0.0
...                                     Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                V560TU
@{DTS_TEST_WORKFLOWS}=                  Initial Deployment    UEFI Update
...                                     UEFI->Heads Transition    Fuse Platform
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI->Heads Transition", "DPP") }}
...                                     ${{ ("UEFI Update", "DCR") }}
...                                     ${{ ("Fuse Platform", "DCR") }}
