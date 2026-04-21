*** Settings ***
Resource    include/novacustom-nuc_box.robot
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot
Resource    include/default.robot


*** Variables ***
${CPU}=                                 Intel(R) Core(TM) Ultra 5 125H
${DEF_CORES_PER_SOCKET}=                14
${DEF_THREADS_TOTAL}=                   18
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300
${PLATFORM_CPU_SPEED}=                  3.0
${DEF_ONLINE_CPU}=                      0-17
${DEF_SOCKETS}=                         1

${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${USB_MODEL}=                           ${TBD}
${USB_DEVICE}=                          Linux

${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               Telnet
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${OPTIONS_LIB}=                         options-lib_uefi-setup-menu
${POWER_CTRL}=                          sonoff

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
# ${ENV_ID_FEDORA}
@{TESTED_LINUX_DISTROS}=
...                                     ${ENV_ID_UBUNTU}
...                                     ${ENV_ID_FEDORA}
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}

# cpu performance Ubuntu
&{CPP_CRAY_1080_P_BENCHMARK}=
...                                     name=Resolution: 1080p - Rays Per Pixel: 16
...                                     score=80.547
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_CRAY_4_K_BENCHMARK}=
...                                     name=Resolution: 4K - Rays Per Pixel: 16
...                                     score=326.895
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_CRAY_5_K_BENCHMARK}=
...                                     name=Resolution: 5K - Rays Per Pixel: 16
...                                     score=585.333
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_COREMARK_BENCHMARK}=
...                                     name=CoreMark Size 666 - Iterations Per Second
...                                     score=407451.446
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{CPP_ZIP_COMPRESSION_BENCHMARK}=
...                                     name=Test: Compression Rating
...                                     score=79729
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{CPP_ZIP_DECOMPRESSION_BENCHMARK}=
...                                     name=Test: Decompression Rating
...                                     score=52410
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
@{CPP_BENCHMARKS}=
...                                     &{CPP_CRAY_1080_P_BENCHMARK}
...                                     &{CPP_CRAY_4_K_BENCHMARK}
...                                     &{CPP_CRAY_5_K_BENCHMARK}
...                                     &{CPP_COREMARK_BENCHMARK}
...                                     &{CPP_ZIP_COMPRESSION_BENCHMARK}
...                                     &{CPP_ZIP_DECOMPRESSION_BENCHMARK}

# cpu performance Windows
&{UPP_SMALLPT_BENCHMARK}=
...                                     name=smallpt
...                                     score=12.454
...                                     scale=lower_is_better
...                                     dev=0.2
...                                     type=singlecore
&{UPP_CRAFTY_BENCHMARK}=
...                                     name=crafty
...                                     score=9289333
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=singlecore
&{UPP_CACHEBENCH_BENCHMARK}=
...                                     name=cachebench
...                                     score=108463.4
...                                     scale=higher_is_better
...                                     dev=0.2
...                                     type=multicore
&{UPP_BLAKE2_BENCHMARK}=                name=blake2    score=4.08    scale=lower_is_better    dev=0.2    type=multicore
@{UPP_BENCHMARKS}=
...                                     &{UPP_SMALLPT_BENCHMARK}
...                                     &{UPP_CRAFTY_BENCHMARK}
...                                     &{UPP_CACHEBENCH_BENCHMARK}
...                                     &{UPP_BLAKE2_BENCHMARK}

# disk i-o
&{DISK_IO_REFERENCE_VALUES_UBUNTU}=
...                                     SEQ_READ_QUEUED=4677
...                                     SEQ_WRITE_QUEUED=1878
...                                     SEQ_READ_NONQUE=2232
...                                     SEQ_WRITE_NONQUE=1884
...                                     RAND_READ_QUEUED=823
...                                     RAND_WRITE_QUEUED=917
...                                     RAND_READ_NONQUE=68
...                                     RAND_WRITE_NONQUE=272

&{DISK_IO_REFERENCE_VALUES_WINDOWS}=
...                                     SEQ_READ_QUEUED=7119
...                                     SEQ_WRITE_QUEUED=6511
...                                     SEQ_READ_NONQUE=5001
...                                     SEQ_WRITE_NONQUE=5475
...                                     RAND_READ_QUEUED=886
...                                     RAND_WRITE_QUEUED=461
...                                     RAND_READ_NONQUE=82
...                                     RAND_WRITE_NONQUE=239

${UNIGINE_SUPERPOSITION_RESULT_AC}=     20.6    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    20.3    # FPS


*** Keywords ***
Power On
    Novacustom-common.Power On
