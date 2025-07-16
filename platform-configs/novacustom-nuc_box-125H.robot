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

${EXTERNAL_HEADSET}=                    JMTek, LLC. USB Audio
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${USB_MODEL}=                           ${TBD}
${USB_DEVICE}=                          Linux

# cpu performance Ubuntu
${ZIP_MULTI_COMPRESSION}=               79729    # MIPS
${ZIP_MULTI_DECOMPRESSION}=             52410    # MIPS
${CRAY_5_K_RENDER}=                     585.333    # sec
${CRAY_4_K_RENDER}=                     326.895    # sec
${CRAY_1080_P_RENDER}=                  80.547    # sec
${COREMARK_SINGLE}=                     407451.446    # iterations/s

# cpu performance Windows
${SMALLPT_TEST_SCORE}=                  12.454
${CRAFTY_TEST_SCORE}=                   9289333
${CACHEBENCH_TEST_SCORE}=               108463.4
${BLAKE2_TEST_SCORE}=                   4.08

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

${UNIGINE_SUPERPOSITION_RESULT_AC}=     20.6    # FPS
${UNIGINE_SUPERPOSITION_RESULT_BAT}=    20.3    # FPS


*** Keywords ***
Power On
    Novacustom-common.Power On
