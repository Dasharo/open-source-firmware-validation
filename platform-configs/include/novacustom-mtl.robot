*** Variables ***
${POWER_CTRL}=                                      none

# Flash
${FLASH_SIZE}=                                      ${32*1024*1024}

# CPU
${INITIAL_CPU_FREQUENCY}=                           2800
${DEF_CORES_PER_SOCKET}=                            16
${DEF_THREADS_PER_CORE}=                            2
${DEF_THREADS_TOTAL}=                               22
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                                  0-7
${DEF_SOCKETS}=                                     1

# Audio
${DEVICE_AUDIO1}=                                   ALC245
${DEVICE_AUDIO2}=                                   Intel Meteor Lake HDMI
${DEVICE_AUDIO1_WIN}=                               Realtek High Definition Audio

# Connectivity
${WIFI_CARD}=                                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                                Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${BLUETOOTH_CARD_UBUNTU}=                           Intel Corp. AX211 Bluetooth

# USB
${WEBCAM_UBUNTU}=                                   Bison Electronics Inc. BisonCam,NB Pro
${USB_STACK_SUPPORT}=                               ${TRUE}

# DMI
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.5.2
# TODO verify
${DMIDECODE_RELEASE_DATE}=                          03/17/2022

# Not supported until we release the Dasharo System Driver
${FAN_SPEED_MEASURE_SUPPORT}=                       ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}

${L3_CACHE_SUPPORT}=                                ${TRUE}

# Only S0ix is available on MTL
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${FALSE}

# Benchmark reference data to nvidia model

# performance
${ZIP_MULTI_COMPRESSION}=                           63476    # MIPS
${ZIP_MULTI_DECOMPRESSION}=                         39336    # MIPS
${CRAY_5_K_RENDER}=                                 654.5    # sec
${CRAY_4_K_RENDER}=                                 356.9    # sec
${CRAY_1080_P_RENDER}=                              90.8    # sec
${COREMARK_SINGLE}=                                 400079.5    # iterations/s

# disk i-o
${UBU_SEQ_READ_QUEUED}=                             4677    # MB/s
${UBU_SEQ_WRITE_QUEUED}=                            1878.5    # MB/s
${UBU_SEQ_READ_NONQUE}=                             2232.5    # MB/s
${UBU_SEQ_WRITE_NONQUE}=                            1884.7    # MB/s
${UBU_RAND_READ_QUEUED}=                            823    # MB/s
${UBU_RAND_WRITE_QUEUED}=                           917.3    # MB/s
${UBU_RAND_READ_NONQUE}=                            68.6    # MB/s
${UBU_RAND_WRITE_NONQUE}=                           272.1    # MB/s

${WIN_SEQ_READ_QUEUED}=                             7119.5    # MB/s
${WIN_SEQ_WRITE_QUEUED}=                            6511.4    # MB/s
${WIN_SEQ_READ_NONQUE}=                             5001.2    # MB/s
${WIN_SEQ_WRITE_NONQUE}=                            5475.5    # MB/s
${WIN_RAND_READ_QUEUED}=                            886.5    # MB/s
${WIN_RAND_WRITE_QUEUED}=                           461.3    # MB/s
${WIN_RAND_READ_NONQUE}=                            82.8    # MB/s
${WIN_RAND_WRITE_NONQUE}=                           239.6    # MB/s
