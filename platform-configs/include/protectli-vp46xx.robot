*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${INITIAL_CPU_FREQUENCY}=           2600
${MAX_CPU_TEMP}=                    82
${WATCHDOG_SUPPORT}=                ${TRUE}

# eMMC driver support
${E_MMC_NAME}=                      AJTD4R

${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.1-rc1
${DMIDECODE_RELEASE_DATE}=          10/20/2025
${DMIDECODE_FAMILY}=                Vault Pro
${DMIDECODE_SERIAL_NUMBER}=         123456789
${SERIAL_NUMBER_VERIFICATION}=      ${TRUE}

@{ETH_PERF_PAIR_2_G}=               enp5s0    enp6s0

${ETHERNET_ID}=                     8086:15f3
