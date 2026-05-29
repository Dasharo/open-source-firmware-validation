*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                 Intel(R) Core(TM) i7-1165G7 CPU

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=              3250000

${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              NV4XMB,ME,MZ

${USB_DEVICE}=                          SanDisk
${USB_MODEL}=                           USB Flash Memory
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300

${EXPECTED_FW_SHA256}=                  c5b399891fac4f243eb12605ec54327815165594f800ef6fbc4ef5f1b85b79d1
${NVIDIA_GRAPHICS_CARD_SUPPORT}=        ${TRUE}
${OPTIONS_LIB}=                         options-lib_dcu

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

# DTS E2E variables
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
