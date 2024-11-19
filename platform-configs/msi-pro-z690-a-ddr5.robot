*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                      v1.1.4-rc1
${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=          MS-7D25
${DMIDECODE_RELEASE_DATE}=          09/27/2024

${DEVICE_AUDIO2}=                   Raptorlake HDMI

${CPU_MAX_FREQUENCY}=               5200
${CPU_MIN_FREQUENCY}=               300


${CPU_TESTS_SUPPORT}=                           ${TRUE}
${INTEL_HYBRID_ARCH_SUPPORT}=                   ${TRUE}
${HYPER_THREADING_SUPPORT}=                     ${TRUE}

${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   20
${DEF_ONLINE_CPU}=                      0-19
${DEF_SOCKETS}=                         1

${DEF_CORES_PER_SOCKET}=                14

${CPU_P_CORES_MAX}=                     6
${CPU_E_CORES_MAX}=                     8