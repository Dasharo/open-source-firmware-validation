*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                 Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=              3200*1000

${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Keyboard
${DMIDECODE_PRODUCT_NAME}=              NV4XMB,ME,MZ
${EXPECTED_FW_SHA256}=                  62cd9a0dfc102a488601c8ab558f7f8c7a865416ad4138f38b76d3f73f20e65d

${USB_DEVICE}=                          SanDisk
${USB_MODEL}=                           SanDisk

${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300

# DTS E2E variables

# disk-io variables
${DISK_IO_REFERENCE_DISK_NAME}=         Samsung SSD 980 Pro
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

# cpu performance Ubuntu/Windows
&{CPP_CRAFTY_BENCHMARK}=
...                                     name=Elapsed Time
...                                     short_name=pts/crafty
...                                     score=5879755.4
...                                     scale=higher_is_better
...                                     dev=0.13
...                                     type=singlecore
&{CPP_STOCKFISH_BENCHMARK}=
...                                     name=Chess Benchmark
...                                     short_name=pts/stockfish
...                                     score=3738927.6
...                                     scale=higher_is_better
...                                     dev=0.07
...                                     type=multicore
@{CPP_BENCHMARKS}=
...                                     &{CPP_STOCKFISH_BENCHMARK}
...                                     &{CPP_CRAFTY_BENCHMARK}
