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

# IMPORTANT! Update the revisions with new releases
@{MICROCODE_REVISIONS}=             0x100
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.1-rc5
${DMIDECODE_RELEASE_DATE}=          05/22/2026
${DMIDECODE_SERIAL_NUMBER}=         123456789
${SERIAL_NUMBER_VERIFICATION}=      ${TRUE}
${EXPECTED_FW_SHA256}=              3e809b17cc96f60e4d6eb825055600b70c0f9ab8a5899ec9edce729751093796

@{ETH_PERF_PAIR_2_G}=               enp5s0    enp6s0

${ETHERNET_ID}=                     8086:15f3
