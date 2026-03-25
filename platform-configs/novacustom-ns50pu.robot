*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                     Intel(R) Core(TM) i5-1240P

# Test configuration
${3_MDEB_WIFI_NETWORK}=                     3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=                  3200*1000

${DEVICE_NVME_DISK}=                        Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                     Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=                  NS5x_NS7xPU

${USB_DEVICE}=                              Kingston
${USB_MODEL}=                               USB Flash Memory
${CPU_MAX_FREQUENCY}=                       4500
${CPU_MIN_FREQUENCY}=                       300

${OPTIONS_LIB}=                             options-lib_dcu

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                         &{DTS_TEST_VERSIONS_BASE}
...                                         Fuse Platform=Dasharo (coreboot+UEFI) 1.8.0
@{DTS_TEST_WORKFLOWS}=
...                                         Initial Deployment
...                                         UEFI Update
...                                         Fuse Platform
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI Update", "DCR") }}
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
...                                         ${{ ("UEFI Update", "DCR") }}=${{ { "TEST_ME_DISABLED": "true", "TEST_ME_OP_MODE": "3", "TEST_DIFFERENT_FMAP": "true" } }}
...                                         ${{ ("Fuse Platform", "DCR") }}=${{ { "TEST_ME_HAP_DISABLED": "true", "TEST_ME_OP_MODE": "2", "TEST_IS_COREBOOT": "true" } }}

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
# ...                                       &{CPP_CRAY_1080_P_BENCHMARK}
# ...                                       &{CPP_CRAY_4_K_BENCHMARK}
# ...                                       &{CPP_CRAY_5_K_BENCHMARK}
...                                         &{CPP_COREMARK_BENCHMARK}
...                                         &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                         &{CPP_ZIP_DECOMPRESSION_BENCHMARK}
