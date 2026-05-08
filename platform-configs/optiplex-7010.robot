*** Settings ***
Resource    include/optiplex-common.robot


*** Variables ***
${DEVICE_USB_KEYBOARD}=         SiGma Micro Keyboard TRACER Gamma Ivory
${USB_MODEL}=                   Kingston
${USB_DEVICE}=                  Multifunction Composite Gadget

${CPU}=                         Intel(R) Core(TM) i5-3470 CPU @ 3.20GHz
${PLATFORM_CPU_SPEED}=          3.20
${INITIAL_CPU_FREQUENCY}=       1600
${CPU_MIN_FREQUENCY}=           300
${CPU_MAX_FREQUENCY}=           3600
${PLATFORM_RAM_SPEED}=          800
${DEF_THREADS_TOTAL}=           4
${DEF_THREADS_PER_CORE}=        1
${DEF_CORES_PER_SOCKET}=        4
${DEF_SOCKETS}=                 1
${DEF_ONLINE_CPU}=              0-3
${DEF_CORES}=                   2
${DEF_THREADS}=                 1
${DEF_CPU}=                     2
${DRAM_SIZE}=                   ${16384}
${PLATFORM_RAM_SIZE}=           16384
${EXPECTED_FW_SHA256}=          e553f0d8cd07c874b3b77da2bfd08d52d1a431ff125106e6fa1832894e5d1554
${DMIDECODE_PRODUCT_NAME}=      OptiPlex 7010

${DEVICE_NVME_DISK}=            Non-Volatile memory controller

# DTS E2E variables
