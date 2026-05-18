*** Settings ***
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                                  ${16*1024*1024}

${DEF_CORES_PER_SOCKET}=                        4
${DEF_THREADS_PER_CORE}=                        1
${DEF_THREADS_TOTAL}=                           4
${DEF_ONLINE_CPU}=                              0-3
${DEF_SOCKETS}=                                 1

${INITIAL_CPU_FREQUENCY}=                       2000
${MAX_CPU_TEMP}=                                77

${E_MMC_NAME}=                                  BJTD4R
${NVME_SATA_DISABLING_SUPPORT}=                 ${TRUE}
${NVME_LNKCAP}=
...                                             LnkCap: Port #0, Speed \\d+GT/s, Width x4, ASPM L1, Exit Latency L1 <64us
${NVME_LNKCTL}=                                 LnkCtl: ASPM L1 Enabled; RCB 64 bytes, LnkDisable- CommClk\\+
${DMIDECODE_SERIAL_NUMBER}=                     N/A
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v
${DMIDECODE_RELEASE_DATE}=                      ${EMPTY}
${DMIDECODE_FAMILY}=                            Vault
@{TESTED_LINUX_DISTROS}=                        ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}
${NVME_DISK_SUPPORT}=                           ${TRUE}
${MEASURED_BOOT_SUPPORT}=                       ${TRUE}

${DASHARO_USB_MENU_SUPPORT}=                    ${FALSE}
${USB_STACK_SUPPORT}=                           ${FALSE}
${USB_MASS_STORAGE_SUPPORT}=                    ${FALSE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=               ${FALSE}
${NVME_X2_SLOT_SUPPORT}=                        ${TRUE}
${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}=     ${EMPTY}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${TRUE}

${M2_WIFI_SUPPORT}=                             ${TRUE}
${WIFI_CARD_UBUNTU}=                            Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${HIBERNATION_AND_RESUME_SUPPORT}=              ${TRUE}
${HIBERNATION_ITERATIONS_NUMBER}=               5
${TPM_MULTIPLE_BANK_SUPPORT}=                   ${FALSE}


*** Keywords ***
Flash Device Via External Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using external programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    ${flash_result}=    Run    osfv_cli rte --rte_ip ${RTE_IP} flash write --rom ${FW_FILE}
    Should Contain    ${flash_result}    Flash written
