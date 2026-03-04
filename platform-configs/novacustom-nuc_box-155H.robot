*** Settings ***
Resource    include/novacustom-nuc_box.robot
Resource    include/novacustom-mtl.robot
Resource    include/novacustom-common.robot
Resource    include/default.robot
Resource    include/cpu-perf-155h.robot


*** Variables ***
${CPU}=                                 Intel(R) Core(TM) Ultra 7 155H
${INITIAL_CPU_FREQUENCY}=               2800
${DEF_CORES_PER_SOCKET}=                16
${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   22
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                      0-21
${DEF_SOCKETS}=                         1

${CPU_MAX_FREQUENCY}=                   4800
${CPU_MIN_FREQUENCY}=                   200

@{EXTERNAL_HEADSETS}=                   JMTek, LLC. USB Audio
${DEVICE_NVME_DISK}=                    Non-Volatile memory controller
${USB_MODEL}=                           ${TBD}
${USB_DEVICE}=                          Linux

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


*** Keywords ***
Power On
    Novacustom-common.Power On
