*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=                   SSH
${DUT_CONNECTION_METHOD}=                           SSH
${POWER_CTRL}=                                      none
${TESTS_IN_FIRMWARE_SUPPORT}=                       ${FALSE}
${OPTIONS_LIB}=                                     options-lib_dcu
${DEFAULT_BOOT_OS_ID}=                              ${ENV_ID_UBUNTU}
# ${ENV_ID_FEDORA}
@{TESTED_LINUX_DISTROS}=
...                                                 ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}    ${ENV_ID_QUBES}

${CPU}=                                             Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                             3mdeb_abr
${DEVICE_NVME_DISK}=                                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                             Keyboard
${DMIDECODE_PRODUCT_NAME}=                          V5xTNC_TND_TNE

${CPU_MAX_FREQUENCY}=                               4800
${CPU_MIN_FREQUENCY}=                               200
${PLATFORM_CPU_SPEED}=                              3.0

${DGPU_ONLY_SUPPORT}=                               ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                        ${TRUE}    # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=                         ${TRUE}    # on which OS is first in the boot order

${WIFI_CARD_UBUNTU}=
...                                                 00:14.3 Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${WEBCAM_UBUNTU}=                                   Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${MINI_PC_IE_SLOT_SUPPORT}=                         ${TRUE}
${WIFI_CARD}=
...                                                 Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${USB_DEVICE}=                                      SanDisk
${ME_STATICALLY_DISABLED}=                          ${TRUE}
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.0.0
${DMIDECODE_RELEASE_DATE}=                          01/29/2026
${TPM_DETECT_SUPPORT}=                              ${TRUE}
${EXPECTED_FW_SHA256}=                              3bb957f609f8ad995be396f5cca674e6f16dc7bab0bf70c4d613a78fa0676033

${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=          ${TRUE}
${DOCKING_STATION_AUDIO_SUPPORT}=                   ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                           ${TRUE}

${TPM_SUPPORTED_VERSION}=                           2
${TPM_EXPECTED_CHIP}=                               SLB9672
${USB_DISKS_DETECTION_SUPPORT}=                     ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=                  ${TRUE}
# /sys/class/power_supply/BAT0/charge_full
${CLEVO_BATTERY_CAPACITY}=
...                                                 4636000
${FAN_SPEED_MEASURE_SUPPORT}=                       ${TRUE}
${HDMI_AUDIO_SUPPORT}=                              ${TRUE}

# cpu performance Ubuntu
&{CPP_CRAY_1080_P_BENCHMARK}=
...                                                 name=Resolution: 1080p - Rays Per Pixel: 16
...                                                 score=90.8
...                                                 scale=lower_is_better
...                                                 dev=0.2
...                                                 type=singlecore
&{CPP_CRAY_4_K_BENCHMARK}=
...                                                 name=Resolution: 4K - Rays Per Pixel: 16
...                                                 score=356.9
...                                                 scale=lower_is_better
...                                                 dev=0.2
...                                                 type=singlecore
&{CPP_CRAY_5_K_BENCHMARK}=
...                                                 name=Resolution: 5K - Rays Per Pixel: 16
...                                                 score=654.5
...                                                 scale=lower_is_better
...                                                 dev=0.2
...                                                 type=singlecore
&{CPP_COREMARK_BENCHMARK}=
...                                                 name=CoreMark Size 666 - Iterations Per Second
...                                                 score=400079.5
...                                                 scale=higher_is_better
...                                                 dev=0.2
...                                                 type=singlecore
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                                 name=Test: Compression Rating
...                                                 score=63476
...                                                 scale=higher_is_better
...                                                 dev=0.2
...                                                 type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                                 name=Test: Decompression Rating
...                                                 score=39336
...                                                 scale=higher_is_better
...                                                 dev=0.2
...                                                 type=multicore
@{CPP_BENCHMARKS}=
...                                                 &{CPP_CRAY_1080_P_BENCHMARK}
...                                                 &{CPP_CRAY_4_K_BENCHMARK}
...                                                 &{CPP_CRAY_5_K_BENCHMARK}
...                                                 &{CPP_COREMARK_BENCHMARK}
...                                                 &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                                 &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

# cpu performance Windows
# reference score for 155H from https://openbenchmarking.org/result/2508216-NE-SKIBIDI6461
&{UPP_SMALLPT_BENCHMARK}=
...                                                 name=smallpt
...                                                 score=19.02
...                                                 scale=lower_is_better
...                                                 dev=0.2
...                                                 type=singlecore
# reference score for 155H from https://openbenchmarking.org/test/pts/crafty
&{UPP_CRAFTY_BENCHMARK}=
...                                                 name=crafty
...                                                 score=10919999
...                                                 scale=higher_is_better
...                                                 dev=0.2
...                                                 type=singlecore
# reference score for 155H from https://openbenchmarking.org/result/2508217-NE-AAAAAAA9714
&{UPP_CACHEBENCH_BENCHMARK}=
...                                                 name=cachebench
...                                                 score=106987
...                                                 scale=higher_is_better
...                                                 dev=0.2
...                                                 type=multicore
# reference score for 155H from    https://openbenchmarking.org/result/2508292-NE-20250829131
&{UPP_BLAKE2_BENCHMARK}=
...                                                 name=blake2
...                                                 score=4.06
...                                                 scale=lower_is_better
...                                                 dev=0.2
...                                                 type=multicore
@{UPP_BENCHMARKS}=
...                                                 &{UPP_SMALLPT_BENCHMARK}
...                                                 &{UPP_CRAFTY_BENCHMARK}
...                                                 &{UPP_CACHEBENCH_BENCHMARK}
...                                                 &{UPP_BLAKE2_BENCHMARK}

# disk i-o
&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                                 SEQ_READ_QUEUED=4677
...                                                 SEQ_WRITE_QUEUED=1878
...                                                 SEQ_READ_NONQUE=2232
...                                                 SEQ_WRITE_NONQUE=1884
...                                                 RAND_READ_QUEUED=823
...                                                 RAND_WRITE_QUEUED=917
...                                                 RAND_READ_NONQUE=68
...                                                 RAND_WRITE_NONQUE=272

&{DISK_IO_REFERENCE_VALUES_WINDOWS}=
...                                                 SEQ_READ_QUEUED=7119
...                                                 SEQ_WRITE_QUEUED=6511
...                                                 SEQ_READ_NONQUE=5001
...                                                 SEQ_WRITE_NONQUE=5475
...                                                 RAND_READ_QUEUED=886
...                                                 RAND_WRITE_QUEUED=461
...                                                 RAND_READ_NONQUE=82
...                                                 RAND_WRITE_NONQUE=239

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=                   ${TRUE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                    ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=                 94.4    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=                21.9    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                                 &{DTS_TEST_VERSIONS_BASE}
...                                                 UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
...                                                 Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                            V540TNx
@{DTS_TEST_WORKFLOWS}=                              Initial Deployment
...                                                 UEFI Update
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                                 ${{ ("UEFI Update", "DCR") }}
...                                                 ${{ ("Fuse Platform", "DCR") }}

${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${TRUE}
${SENSORS_CONFIG_FILE}=                             include/sensors/novacustom-v540tnd-sensors-config.yaml
