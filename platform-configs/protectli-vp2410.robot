*** Settings ***
Resource    include/protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                          ${8*1024*1024}
${WIFI_CARD}=                           ${TBD}
${WIFI_CARD_UBUNTU}=                    ${TBD}
${LTE_CARD}=                            ${TBD}
${DEF_ONLINE_CPU}=                      0-3
${DEF_SOCKETS}=                         1
${INITIAL_CPU_FREQUENCY}=               2000
${MAX_CPU_TEMP}=                        77
${CPU_MAX_FREQUENCY}=                   2800
${CPU_MIN_FREQUENCY}=                   300

# eMMC driver support
${E_MMC_NAME}=                          8GTF4R

@{ATTACHED_USB}=                        @{EMPTY}

${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v
${DMIDECODE_PRODUCT_NAME}=              VP2410
${DMIDECODE_RELEASE_DATE}=              ${TBD}
${DMIDECODE_MANUFACTURER}=              Protectli
${DMIDECODE_VENDOR}=                    3mdeb
${DMIDECODE_FAMILY}=                    Vault Pro
${DMIDECODE_TYPE}=                      Desktop

${L3_CACHE_SUPPORT}=                    ${FALSE}
${DASHARO_SECURITY_MENU_SUPPORT}=       ${TRUE}

# Test module: dasharo-security
${MEASURED_BOOT_SUPPORT}=               ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=        ${TRUE}
${UEFI_PASSWORD_SUPPORT}=               ${TRUE}
${ME_STATICALLY_DISABLED}=              ${TRUE}

${PLATFORM_CPU_SPEED}=                  2.00
${PLATFORM_RAM_SPEED}=                  2400
${PLATFORM_RAM_SIZE}=                   8192

@{ETH_PERF_PAIR_1_G}=                   enp2s0    enp3s0

@{ETH_PORTS}=                           64-62-66-21-03-b8
...                                     64-62-66-21-03-b9
...                                     64-62-66-21-03-ba
...                                     64-62-66-21-03-bb
