*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
${CPU}=                                         Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                         3mdeb_abr
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                         Keyboard
${DMIDECODE_PRODUCT_NAME}=                      V5xTNC_TND_TNE
${EXTERNAL_HEADSET}=                            USB PnP Audio Device
${CPU_MAX_FREQUENCY}=                           4800
${CPU_MIN_FREQUENCY}=                           200

${NVIDIA_GRAPHICS_CARD_SUPPORT}=                ${TRUE}

${TESTS_IN_WINDOWS_SUPPORT}=                    ${FALSE}    # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}    # on which OS is first in the boot order

${WIFI_CARD_UBUNTU}=
...                                             00:14.3 Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${WEBCAM_UBUNTU}=                               Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${MINI_PC_IE_SLOT_SUPPORT}=                     ${TRUE}
${WIFI_CARD}=
...                                             Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${CPU_TESTS_SUPPORT}=                           ${TRUE}
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

${LAPTOP_PLATFORM}=                             ${TRUE}
${BATTERY_PRESENT}=                             ${TRUE}
${GPU_PERFORMANCE_TESTS_SUPPORT}=               ${TRUE}

# performance
${ZIP_MULTI_COMPRESSION}=                       63476    # MIPS
${ZIP_MULTI_DECOMPRESSION}=                     39336    # MIPS
${CRAY_5_K_RENDER}=                             654.5    # sec
${CRAY_4_K_RENDER}=                             356.9    # sec
${CRAY_1080_P_RENDER}=                          90.8    # sec
${COREMARK_SINGLE}=                             400079.5    # iterations/s

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
