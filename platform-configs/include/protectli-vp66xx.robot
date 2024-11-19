*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${DEVICE_AUDIO1}=                   Alderlake-P HDMI
${DEVICE_AUDIO1_WIN}=               High Definition Audio Device
${INITIAL_CPU_FREQUENCY}=           2600
${MAX_CPU_TEMP}=                    82

${CPU_P_CORES_MAX}=                 2
${CPU_E_CORES_MAX}=                 8

${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v0.9.0
${DMIDECODE_RELEASE_DATE}=          07/01/2024

${EMMC_SUPPORT}=                    ${FALSE}
${HYPER_THREADING_SUPPORT}=         ${TRUE}
${INTEL_HYBRID_ARCH_SUPPORT}=       ${TRUE}
@{ETH_PERF_PAIR_2_G}=               enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=              enp2s0f0    enp2s0f1


*** Keywords ***
Power On
    Rte Power Off
    Sleep    5s
    Power Cycle On
