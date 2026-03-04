*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot
Resource    include/cpu-perf-155h.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=               SSH
${DUT_CONNECTION_METHOD}=                       SSH
${POWER_CTRL}=                                  none
${TESTS_IN_FIRMWARE_SUPPORT}=                   ${FALSE}
${OPTIONS_LIB}=                                 options-lib_dcu
${DEFAULT_BOOT_OS_ID}=                          ${ENV_ID_UBUNTU}
# ${ENV_ID_FEDORA}
@{TESTED_LINUX_DISTROS}=
...                                             ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}

${CPU}=                                         Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                         3mdeb_abr
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                         Keyboard
${DMIDECODE_PRODUCT_NAME}=                      V5xTNC_TND_TNE
@{EXTERNAL_HEADSETS}=                           JMTek, LLC. USB Audio
${CPU_MAX_FREQUENCY}=                           4800
${CPU_MIN_FREQUENCY}=                           200
${PLATFORM_CPU_SPEED}=                          3.0

${DGPU_ONLY_SUPPORT}=                           ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=                    ${TRUE}    # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}    # on which OS is first in the boot order

${WIFI_CARD_UBUNTU}=
...                                             00:14.3 Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${WEBCAM_UBUNTU}=                               Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${MINI_PC_IE_SLOT_SUPPORT}=                     ${TRUE}
${WIFI_CARD}=
...                                             Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${USB_DEVICE}=                                  SanDisk
${ME_STATICALLY_DISABLED}=                      ${TRUE}
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.1-rc5
${DMIDECODE_RELEASE_DATE}=                      09/10/2024
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${CLEVO_USB_C_HUB}=                             Thunderbolt 4 Dock
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=      ${TRUE}
${DOCKING_STATION_AUDIO_SUPPORT}=               ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}

${TPM_SUPPORTED_VERSION}=                       2
${TPM_EXPECTED_CHIP}=                           SLB9672
${USB_DISKS_DETECTION_SUPPORT}=                 ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=              ${TRUE}
# /sys/class/power_supply/BAT0/charge_full
${CLEVO_BATTERY_CAPACITY}=
...                                             4636000
${FAN_SPEED_MEASURE_SUPPORT}=                   ${TRUE}
${HDMI_AUDIO_SUPPORT}=                          ${TRUE}

# disk i-o
${UBU_SEQ_READ_QUEUED}=                         4677    # MB/s
${UBU_SEQ_WRITE_QUEUED}=                        1878.5    # MB/s
${UBU_SEQ_READ_NONQUE}=                         2232.5    # MB/s
${UBU_SEQ_WRITE_NONQUE}=                        1884.7    # MB/s
${UBU_RAND_READ_QUEUED}=                        823    # MB/s
${UBU_RAND_WRITE_QUEUED}=                       917.3    # MB/s
${UBU_RAND_READ_NONQUE}=                        68.6    # MB/s
${UBU_RAND_WRITE_NONQUE}=                       272.1    # MB/s

${WIN_SEQ_READ_QUEUED}=                         7119.5    # MB/s
${WIN_SEQ_WRITE_QUEUED}=                        6511.4    # MB/s
${WIN_SEQ_READ_NONQUE}=                         5001.2    # MB/s
${WIN_SEQ_WRITE_NONQUE}=                        5475.5    # MB/s
${WIN_RAND_READ_QUEUED}=                        886.5    # MB/s
${WIN_RAND_WRITE_QUEUED}=                       461.3    # MB/s
${WIN_RAND_READ_NONQUE}=                        82.8    # MB/s
${WIN_RAND_WRITE_NONQUE}=                       239.6    # MB/s

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=               ${TRUE}
${NVIDIA_GRAPHICS_CARD_SUPPORT}=                ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=             94.4    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=            21.9    # FPS

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                             &{DTS_TEST_VERSIONS_BASE}
...                                             UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.0
...                                             Fuse Platform=Dasharo (coreboot+UEFI) 1.0.0
${DTS_TEST_BOARD_MODEL}=                        V540TNx
@{DTS_TEST_WORKFLOWS}=                          Initial Deployment
...                                             UEFI Update
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                             ${{ ("UEFI Update", "DCR") }}
...                                             ${{ ("Fuse Platform", "DCR") }}
