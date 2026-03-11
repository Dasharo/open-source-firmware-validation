*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                     Intel(R) Core(TM) i5-1240P CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=                     3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=                  3200*1000
${CLEVO_USB_C_HUB}=                         4-port
${DEVICE_NVME_DISK}=                        Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                     Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=                  NV4xPZ
@{EXTERNAL_HEADSETS}=                       USB PnP Audio Device
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
# https://openbenchmarking.org/result/2603116-NE-20260311040
${ZIP_MULTI_COMPRESSION}=                   50000    # MIPS
${ZIP_MULTI_DECOMPRESSION}=                 35000    # MIPS

# https://openbenchmarking.org/result/2511237-NE-TEST1811909&export=html
${CRAY_5_K_RENDER}=                         850    # sec
${CRAY_4_K_RENDER}=                         475    # sec
${CRAY_1080_P_RENDER}=                      118    # sec

# https://openbenchmarking.org/result/2603115-NE-20260311070
${COREMARK_SINGLE}=                         68000    # iterations/s

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
