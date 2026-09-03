*** Settings ***
Resource    include/msi-14700k.robot
Resource    include/msi-z690-z790-common.robot


*** Variables ***
${FW_VERSION}=                              v1.1.7
${DMIDECODE_SERIAL_NUMBER}=                 N/A
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=                  MS-7D25
${DMIDECODE_RELEASE_DATE}=                  08/12/2026

${EXPECTED_FW_SHA256}=                      a115ae254a2054d8fec6988ba89f251bc77dbaf74eb44e0069631d2b36433932

@{TESTED_LINUX_DISTROS}=                    ${ENV_ID_UBUNTU}    ${ENV_ID_QUBES}

${WIFI_CARD}=                               Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                        Intel Corporation Alder Lake-S PCH CNVi WiFi (rev 11)

${TPM_MULTIPLE_BANK_SUPPORT}=               ${FALSE}

${WIRELESS_CARD_SUPPORT}=                   ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=              ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=         ${TRUE}

# DTS E2E variables
${DTS_TEST_BOARD_MODEL}=                    PRO Z690-A WIFI DDR4(MS-7D25)
&{DTS_TEST_VERSIONS}=
...                                         &{DTS_TEST_VERSIONS_BASE}
...                                         UEFI->Heads Transition=Dasharo (coreboot+UEFI) 1.1.6
...                                         UEFI Update=Dasharo (coreboot+UEFI) 1.1.5
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI->Heads Transition", "DPP") }}
...                                         ${{ ("UEFI Update", "DPP") }}
...                                         ${{ ("UEFI Update", "DCR") }}
...                                         ${{ ("Initial Deployment", "DCR") }}
...                                         ${{ ("Initial Deployment", "DPP") }}
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_WORKFLOW}=
...                                         &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
...                                         UEFI Update=&{{ {"TEST_IS_COREBOOT": "true"} }}
...                                         UEFI->Heads Transition=&{{ { "TEST_IS_COREBOOT": "true", "TEST_ME_HAP_DISABLED": "false", "TEST_ME_DISABLED": "true", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "cbfs" } }}
...                                         Initial Deployment=&{{ {"TEST_HCI_PRESENT": "true", "TEST_FMAP_REGIONS": "", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "flashmap"} }}
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
...                                         ${{ ("UEFI Update", "DCR") }}=${{ {"TEST_BIOS_VERSION": "Dasharo (coreboot+UEFI) 0.0.0", "TEST_FMAP_REGIONS": "", "TEST_ME_HAP_DISABLED": "false", "TEST_ME_DISABLED": "true", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "flashmap" } }}
...                                         ${{ ("UEFI Update", "DPP") }}=${{ {"TEST_ME_OP_MODE": "2", "TEST_ME_HAP_DISABLED": "true"} }}

${PLATFORM_RAM_SPEED}=                      2400
${PLATFORM_RAM_SIZE}=                       32768
${MEMORY_PROFILE_SUPPORT}=                  ${FALSE}
${CPU_THROTTLING_SUPPORT}=                  ${FALSE}
