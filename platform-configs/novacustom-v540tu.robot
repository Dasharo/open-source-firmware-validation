*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       SSH
${DUT_CONNECTION_METHOD}=               SSH
${POWER_CTRL}=                          none
${OPTIONS_LIB}=                         options-lib_dcu
# CPU
${CPU}=
...                                     Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${DEVICE_NVME_DISK}=
...                                     Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=
...                                     Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              V54x_6x_TU
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.0.0-rc7
${DMIDECODE_RELEASE_DATE}=              09/16/2025
${DMIDECODE_SERIAL_NUMBER}=             123456789
${WIFI_CARD}=
...                                     Intel Corporation Meteor Lake PCH CNVi WiFi
${EXTERNAL_HEADSET}=                    JMTek, LLC. USB Audio
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300
${PLATFORM_CPU_SPEED}=                  3.0

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
# ${ENV_ID_FEDORA}
@{TESTED_LINUX_DISTROS}=
...                                     ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}    ${ENV_ID_QUBES}
${TESTS_IN_QUBESOS_SUPPORT}=            ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}
${CLEVO_USB_C_HUB}=                     Billboard Device
${USB_DEVICE}=                          Linux
${MAX_CPU_TEMP_THRESHOLD}=              110

# cpu performance Ubuntu
${ZIP_MULTI_COMPRESSION}=               63476    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             39336    # MIPS
${CRAY_5_K_RENDER}=                     654.5    # sec
${CRAY_4_K_RENDER}=                     356.9    # sec
${CRAY_1080_P_RENDER}=                  90.8    # sec
${COREMARK_SINGLE}=                     400079.5    # iterations/s

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
${UBU_SEQ_READ_QUEUED}=                 4677    # MB/s
${UBU_SEQ_WRITE_QUEUED}=                1878.5    # MB/s
${UBU_SEQ_READ_NONQUE}=                 2232.5    # MB/s
${UBU_SEQ_WRITE_NONQUE}=                1884.7    # MB/s
${UBU_RAND_READ_QUEUED}=                823    # MB/s
${UBU_RAND_WRITE_QUEUED}=               917.3    # MB/s
${UBU_RAND_READ_NONQUE}=                68.6    # MB/s
${UBU_RAND_WRITE_NONQUE}=               272.1    # MB/s

${WIN_SEQ_READ_QUEUED}=                 7119.5    # MB/s
${WIN_SEQ_WRITE_QUEUED}=                6511.4    # MB/s
${WIN_SEQ_READ_NONQUE}=                 5001.2    # MB/s
${WIN_SEQ_WRITE_NONQUE}=                5475.5    # MB/s
${WIN_RAND_READ_QUEUED}=                886.5    # MB/s
${WIN_RAND_WRITE_QUEUED}=               461.3    # MB/s
${WIN_RAND_READ_NONQUE}=                82.8    # MB/s
${WIN_RAND_WRITE_NONQUE}=               239.6    # MB/s

# /sys/class/power_supply/BAT0/charge_full
${CLEVO_BATTERY_CAPACITY}=
...                                     4643000

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}

${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=           ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=     20.6    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    20.3    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
...                                     UEFI Update=Dasharo (coreboot+UEFI) 0.9.0
...                                     Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                V540TU
@{DTS_TEST_WORKFLOWS}=                  Initial Deployment    UEFI Update
...                                     UEFI->Heads Transition    Fuse Platform
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI->Heads Transition", "DPP") }}
...                                     ${{ ("UEFI Update", "DCR") }}
...                                     ${{ ("Fuse Platform", "DCR") }}

${HDMI_AUDIO_SUPPORT}=                  ${TRUE}


*** Keywords ***
Power On
    Novacustom-common.Power On
