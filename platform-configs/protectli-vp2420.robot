*** Settings ***
Resource    include/protectli-pro.robot
Resource    include/protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}
${WIFI_CARD_UBUNTU}=                Intel Corporation Wi-Fi 6 AX200 (rev 1a)
${LTE_CARD}=                        Qualcomm, Inc. MDG200
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${INITIAL_CPU_FREQUENCY}=           2600
${MAX_CPU_TEMP}=                    95
${FLASHING_METHOD}=                 internal

# eMMC driver support
${E_MMC_NAME}=                      8GTF4R

@{ATTACHED_USB}=                    ${EMPTY}

${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.0
${DMIDECODE_PRODUCT_NAME}=          VP2420
${DMIDECODE_RELEASE_DATE}=          10/12/2023
${DMIDECODE_MANUFACTURER}=          Protectli
${DMIDECODE_VENDOR}=                3mdeb
${DMIDECODE_FAMILY}=                N/A
${DMIDECODE_TYPE}=                  N/A

${CPU_MAX_FREQUENCY}=               2700
${CPU_MIN_FREQUENCY}=               300

${WATCHDOG_SUPPORT}=                ${TRUE}

@{ETH_PERF_PAIR_2_G}=               enp3s0    enp4s0


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    Rte Power Off
    Sleep    10s
    Telnet.Read
    Rte Power On

Flash Protectli VP2420 Internal
    Make Sure That Flash Locks Are Disabled
    Power On
    # Boot operating system    ubuntu
    Boot Operating System    Samsung SSD 860 EVO M.2 250GB
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Send File To DUT    ${FW_FILE}    /tmp/dasharo.rom
    Flash Via Internal Programmer    /tmp/dasharo.rom    "bios"
