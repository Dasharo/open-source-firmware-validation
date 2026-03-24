*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                     Intel(R) Core(TM) i5-1240P CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=                     3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=                  3200*1000

${DEVICE_NVME_DISK}=                        Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                     Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=                  NV4xPZ

${USB_DEVICE}=                              SanDisk
${USB_MODEL}=                               Ultra USB
${CPU_MAX_FREQUENCY}=                       4800
${CPU_MIN_FREQUENCY}=                       300

@{TESTED_LINUX_DISTROS}=                    ${ENV_ID_UBUNTU}    ${ENV_ID_QUBES}

${BLUETOOTH_CARD_UBUNTU}=                   8087:0026

${POWER_CTRL}=                              none

${USB_STACK_SUPPORT}=                       ${TRUE}

${TPM_SUPPORTED_VERSION}=                   2
${TPM_EXPECTED_CHIP}=                       SLB9670

${OPTIONS_LIB}=                             options-lib_dcu

${PLATFORM_CPU_SPEED}=                      2.10
${PLATFORM_RAM_SPEED}=                      3200
${PLATFORM_RAM_SIZE}=                       16384

# cpu performance Ubuntu
# https://openbenchmarking.org/result/2511237-NE-TEST1811909&export=html
&{CPP_CRAY_1080_P_BENCHMARK}=
...                                         name=Resolution: 1080p - Rays Per Pixel: 16
...                                         score=118
...                                         scale=lower_is_better
...                                         dev=0.2
...                                         type=singlecore
&{CPP_CRAY_4_K_BENCHMARK}=
...                                         name=Resolution: 4K - Rays Per Pixel: 16
...                                         score=475
...                                         scale=lower_is_better
...                                         dev=0.2
...                                         type=singlecore
&{CPP_CRAY_5_K_BENCHMARK}=
...                                         name=Resolution: 5K - Rays Per Pixel: 16
...                                         score=850
...                                         scale=lower_is_better
...                                         dev=0.2
...                                         type=singlecore
# https://openbenchmarking.org/result/2603115-NE-20260311070
&{CPP_COREMARK_BENCHMARK}=
...                                         name=CoreMark Size 666 - Iterations Per Second
...                                         score=68000
...                                         scale=higher_is_better
...                                         dev=0.2
...                                         type=singlecore
# https://openbenchmarking.org/result/2603116-NE-20260311040
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                         name=Test: Compression Rating
...                                         score=50000
...                                         scale=higher_is_better
...                                         dev=0.2
...                                         type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                         name=Test: Decompression Rating
...                                         score=35000
...                                         scale=higher_is_better
...                                         dev=0.2
...                                         type=multicore
@{CPP_BENCHMARKS}=
...                                         &{CPP_CRAY_1080_P_BENCHMARK}
...                                         &{CPP_CRAY_4_K_BENCHMARK}
...                                         &{CPP_CRAY_5_K_BENCHMARK}
...                                         &{CPP_COREMARK_BENCHMARK}
...                                         &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                         &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

# cpu performance Windows
&{UPP_SMALLPT_BENCHMARK}=
...                                         name=smallpt
...                                         score=30.796
...                                         scale=lower_is_better
...                                         dev=0.2
...                                         type=singlecore
&{UPP_CRAFTY_BENCHMARK}=
...                                         name=crafty
...                                         score=7480997
...                                         scale=higher_is_better
...                                         dev=0.2
...                                         type=singlecore
&{UPP_CACHEBENCH_BENCHMARK}=
...                                         name=cachebench
...                                         score=75584.7
...                                         scale=higher_is_better
...                                         dev=0.2
...                                         type=multicore
&{UPP_BLAKE2_BENCHMARK}=
...                                         name=blake2
...                                         score=3.22
...                                         scale=lower_is_better
...                                         dev=0.2
...                                         type=multicore
@{UPP_BENCHMARKS}=
...                                         &{UPP_SMALLPT_BENCHMARK}
...                                         &{UPP_CRAFTY_BENCHMARK}
...                                         &{UPP_CACHEBENCH_BENCHMARK}
...                                         &{UPP_BLAKE2_BENCHMARK}

# disk i-o
${DISK_IO_REFERENCE_DISK_NAME}=             Samsung SSD 980
&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                         SEQ_READ_QUEUED=3500
...                                         SEQ_WRITE_QUEUED=3000
...                                         SEQ_READ_NONQUE=1900
...                                         SEQ_WRITE_NONQUE=1800
...                                         RAND_READ_QUEUED=2900
...                                         RAND_WRITE_QUEUED=2400
...                                         RAND_READ_NONQUE=1700
...                                         RAND_WRITE_NONQUE=1600
&{DISK_IO_REFERENCE_VALUES_WINDOWS}=
...                                         SEQ_READ_QUEUED=2400
...                                         SEQ_WRITE_QUEUED=1400
...                                         SEQ_READ_NONQUE=1300
...                                         SEQ_WRITE_NONQUE=1800
...                                         RAND_READ_QUEUED=1800
...                                         RAND_WRITE_QUEUED=1200
...                                         RAND_READ_NONQUE=1100
...                                         RAND_WRITE_NONQUE=1000

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                         &{DTS_TEST_VERSIONS_BASE}
...                                         UEFI->Heads Transition=Dasharo (coreboot+UEFI) 1.7.2
...                                         Fuse Platform=Dasharo (coreboot+UEFI) 1.8.0
@{DTS_TEST_WORKFLOWS}=
...                                         Initial Deployment
...                                         UEFI Update
...                                         UEFI->Heads Transition
...                                         Fuse Platform

@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI Update", "DCR") }}
...                                         ${{ ("UEFI->Heads Transition", "DPP") }}
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
...                                         ${{ ("UEFI->Heads Transition", "DPP") }}=${{ {"TEST_ME_HAP_DISABLED": "false", "TEST_ME_DISABLED": "true"} }}
...                                         ${{ ("UEFI Update", "DCR") }}=${{ { "TEST_ME_DISABLED": "true", "TEST_ME_OP_MODE": "3", "TEST_DIFFERENT_FMAP": "true" } }}
...                                         ${{ ("Fuse Platform", "DCR") }}=${{ { "TEST_ME_HAP_DISABLED": "true", "TEST_ME_OP_MODE": "2", "TEST_IS_COREBOOT": "true" } }}
