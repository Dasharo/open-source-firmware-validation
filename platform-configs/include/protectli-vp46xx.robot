*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${DEVICE_AUDIO1}=                   ALC897
${DEVICE_AUDIO2}=                   Kabylake HDMI
${DEVICE_AUDIO1_WIN}=               High Definition Audio Device
${INITIAL_CPU_FREQUENCY}=           2600
${MAX_CPU_TEMP}=                    82
${WATCHDOG_SUPPORT}=                ${TRUE}

# eMMC driver support
${E_MMC_NAME}=                      AJTD4R

${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.0
${DMIDECODE_RELEASE_DATE}=          03/13/2024

@{ETH_PERF_PAIR_2_G}=               enp5s0    enp6s0
