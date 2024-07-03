*** Settings ***
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${DEF_CORES_PER_SOCKET}=            4
${DEF_THREADS_PER_CORE}=            1
${DEF_THREADS_TOTAL}=               4
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

${DASHARO_USB_MENU_SUPPORT}=        ${FALSE}
${USB_STACK_SUPPORT}=               ${FALSE}
${USB_MASS_STORAGE_SUPPORT}=        ${FALSE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off
    Sleep    10s
    Telnet.Read
    # After RteCtrl Power Off, the platform cannot be powered back using the power button.
    # Possibly bug in HW or FW.
    Power Cycle On

Flash Device Via External Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using external programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    ${flash_result}=    Run    osfv_cli rte --rte_ip ${RTE_IP} flash write --rom ${FW_FILE}
    Should Contain    ${flash_result}    Flash written
