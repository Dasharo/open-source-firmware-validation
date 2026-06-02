*** Variables ***
# Flash
${FLASH_SIZE}=                          ${16*1024*1024}

# CPU
${INITIAL_CPU_FREQUENCY}=               2800
${DEF_CORES_PER_SOCKET}=                4
${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   8
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                      0-7
${DEF_SOCKETS}=                         1

# Connectivity
${WIFI_CARD}=                           Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                    Intel Corporation Wi-Fi 6 AX201 (rev 20)
${BLUETOOTH_CARD_UBUNTU}=               Intel Corp. AX201 Bluetooth

# USB
${WEBCAM_UBUNTU}=                       Chicony Electronics Co., Ltd Chicony USB2.0 Camera

# DMI
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.6.0-rc3

${DMIDECODE_RELEASE_DATE}=              05/22/2026
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}

${L3_CACHE_SUPPORT}=                    ${TRUE}

# DTS-E2E variables
&{DTS_TEST_VERSIONS}=                   &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI Update=Dasharo (coreboot+UEFI) v1.5.0

&{DTS_TEST_EXPORTS}=
...                                     &{DTS_TEST_BASE_EXPORTS}
...                                     TEST_AC_PRESENT=true
...                                     TEST_ME_DISABLED=false
...                                     TEST_ME_OP_MODE=1
...                                     TEST_VBOOT_KEYS=true
...                                     TEST_FMAP_REGIONS=BOOTSPLASH
...                                     TEST_BOARD_HAS_BOOTSPLASH=false

@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI Update", "DCR") }}

${HDMI_AUDIO_SUPPORT}=                  ${TRUE}

${SENSORS_CONFIG_FILE}=                 include/sensors/novacustom-tgl-sensors-config.yaml
${CUSTOM_FAN_CURVE_FILE}=               include/sensors/novacustom-tgl-fan-curve-config.yaml

# cpu performance Ubuntu
# https://openbenchmarking.org/s/Intel+Core+i7-1185G7
&{CPP_COREMARK_BENCHMARK}=
...                                     name=CoreMark Size 666 - Iterations Per Second
...                                     score=130000
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                     name=Test: Compression Rating
...                                     score=33000
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                     name=Test: Decompression Rating
...                                     score=20000
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
@{CPP_BENCHMARKS}=
...                                     &{CPP_COREMARK_BENCHMARK}
...                                     &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                     &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

# cpu performance Windows
&{UPP_SMALLPT_BENCHMARK}=
...                                     name=smallpt
...                                     score=35.376
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{UPP_CRAFTY_BENCHMARK}=
...                                     name=crafty
...                                     score=9224291
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{UPP_CACHEBENCH_BENCHMARK}=
...                                     name=cachebench
...                                     score=104565.1
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{UPP_BLAKE2_BENCHMARK}=                name=blake2    score=3.64    scale=lower_is_better    dev=0.2    type=multicore
@{UPP_BENCHMARKS}=
...                                     &{UPP_SMALLPT_BENCHMARK}
...                                     &{UPP_CRAFTY_BENCHMARK}
...                                     &{UPP_CACHEBENCH_BENCHMARK}
...                                     &{UPP_BLAKE2_BENCHMARK}

# disk i-o
${DISK_IO_REFERENCE_DISK_NAME}=         Samsung SSD 980 PRO
&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                     SEQ_READ_QUEUED=3500
...                                     SEQ_WRITE_QUEUED=3000
...                                     SEQ_READ_NONQUE=1900
...                                     SEQ_WRITE_NONQUE=1800
...                                     RAND_READ_QUEUED=2900
...                                     RAND_WRITE_QUEUED=2400
...                                     RAND_READ_NONQUE=1700
...                                     RAND_WRITE_NONQUE=1600
&{DISK_IO_REFERENCE_VALUES_WINDOWS}=
...                                     SEQ_READ_QUEUED=2400
...                                     SEQ_WRITE_QUEUED=1400
...                                     SEQ_READ_NONQUE=1300
...                                     SEQ_WRITE_NONQUE=1800
...                                     RAND_READ_QUEUED=1800
...                                     RAND_WRITE_QUEUED=1200
...                                     RAND_READ_NONQUE=1100
...                                     RAND_WRITE_NONQUE=1000
