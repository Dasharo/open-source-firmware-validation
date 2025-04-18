*** Settings ***
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                 Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                 3mdeb_abr
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=              V54x_6x_TU
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.0.0-rc2
${DMIDECODE_RELEASE_DATE}=              04/10/2025
${EXTERNAL_HEADSET}=                    JMTek, LLC. USB Audio
${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   300

${OPTIONS_LIB}=                         options-lib_dcu
${POWER_CTRL}=                          none

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    # ${ENV_ID_FEDORA}
${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE}
${CLEVO_USB_C_HUB}=                     Billboard Device
${USB_DEVICE}=                          Linux

# performance
${ZIP_MULTI_COMPRESSION}=               63476    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             39336    # MIPS
${CRAY_5_K_RENDER}=                     654.5    # sec
${CRAY_4_K_RENDER}=                     356.9    # sec
${CRAY_1080_P_RENDER}=                  90.8    # sec
${COREMARK_SINGLE}=                     400079.5    # iterations/s

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

${CLEVO_BATTERY_CAPACITY}=              4643000    # /sys/class/power_supply/BAT0/charge_full

# GPU Performance
# Reference config: Medium preset, 1920x1080, Windowed
${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}

${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=           ${TRUE}
${UNIGINE_SUPERPOSITION_RESULT_AC}=     20.6    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    20.3    # FPS


*** Keywords ***
Power On
    Novacustom-common.Power On
