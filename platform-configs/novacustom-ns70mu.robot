*** Settings ***
Resource    include/novacustom-tgl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                 Intel(R) Core(TM) i7-1165G7 CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=              9600000

${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              NS50_70MU

${USB_DEVICE}=                          SanDisk
${USB_MODEL}=                           USB Flash Memory
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300
${EXPECTED_FW_SHA256}=                  56c7752aed4d2514a44f77878eb87a740f3eaa9a2c602c3b2905b10ab6407724

# dasharo-compability
${FW_NO_EC_SYNC_DOWNLOAD_LINK}=
...                                     https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_v1.5.1.rom
${EC_NO_SYNC_DOWNLOAD_LINK}=
...                                     https://dl.3mdeb.com/open-source-firmware/Dasharo/novacustom_ns5x_tgl/v1.5.1/novacustom_ns5x_tgl_ec_v1.5.1.rom
${FW_NO_EC_SYNC_VERSION}=               v1.5.1
${EC_NO_SYNC_VERSION}=                  2023-10-31_f148431

${OPTIONS_LIB}=                         options-lib_dcu

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
