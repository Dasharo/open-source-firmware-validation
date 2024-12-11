*** Settings ***
Resource    include/protectli-vp24xx.robot


*** Variables ***
${INITIAL_CPU_FREQUENCY}=           2600
${FLASHING_METHOD}=                 internal

# eMMC driver support
${E_MMC_NAME}=                      8GTF4R
${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.0
${DMIDECODE_PRODUCT_NAME}=          VP2420
${DMIDECODE_RELEASE_DATE}=          10/12/2023
${DMIDECODE_TYPE}=                  N/A

${CPU_MAX_FREQUENCY}=               2700
${CPU_MIN_FREQUENCY}=               300

${WATCHDOG_SUPPORT}=                ${TRUE}

@{ETH_PERF_PAIR_2_G}=               enp3s0    enp4s0


*** Keywords ***
Flash Protectli VP2420 Internal
    Make Sure That Flash Locks Are Disabled
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Send File To DUT    ${FW_FILE}    /tmp/dasharo.rom
    Flash Via Internal Programmer    /tmp/dasharo.rom    "bios"
