*** Settings ***
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${DEF_CORES}=                       4
${DEF_THREADS}=                     1
${DEF_CPU}=                         4
${DEF_ONLINE_CPU}=                  0-3
${DEF_SOCKETS}=                     1

${INITIAL_CPU_FREQUENCY}=           2000
${MAX_CPU_TEMP}=                    77

${E_MMC_NAME}=                      BJTD4R

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v
${DMIDECODE_RELEASE_DATE}=          ${EMPTY}
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                Vault
${DMIDECODE_TYPE}=                  Desktop

${NVME_DISK_SUPPORT}=               ${TRUE}
${MEASURED_BOOT_SUPPORT}=           ${TRUE}
