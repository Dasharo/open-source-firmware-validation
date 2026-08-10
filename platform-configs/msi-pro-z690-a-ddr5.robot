*** Settings ***
Resource    include/msi-13600k.robot
Resource    include/msi-z690-z790-common.robot


*** Variables ***
${FW_VERSION}=                              v1.1.7-rc5
${DMIDECODE_SERIAL_NUMBER}=                 N/A
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=                  MS-7D25
${DMIDECODE_RELEASE_DATE}=                  08/10/2026

${EXPECTED_FW_SHA256}=                      a115ae254a2054d8fec6988ba89f251bc77dbaf74eb44e0069631d2b36433932

# DTS E2E variables
${DTS_TEST_BOARD_MODEL}=                    PRO Z690-A WIFI (MS-7D25)
&{DTS_TEST_VERSIONS}=
...                                         &{DTS_TEST_VERSIONS_BASE}
...                                         UEFI->Heads Transition=Dasharo (coreboot+UEFI) 1.1.6
...                                         UEFI Update=Dasharo (coreboot+UEFI) 1.1.5
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_WORKFLOW}=
...                                         &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
...                                         UEFI Update=&{{ {"TEST_IS_COREBOOT": "true"} }}
...                                         UEFI->Heads Transition=&{{ { "TEST_IS_COREBOOT": "true", "TEST_ME_DISABLED": "false", "TEST_ME_HAP_DISABLED": "true", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "cbfs"} }}
...                                         Initial Deployment=&{{ {"TEST_HCI_PRESENT": "true", "TEST_FMAP_REGIONS": "", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "flashmap"} }}
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
...                                         ${{ ("UEFI Update", "DCR") }}=${{ {"TEST_BIOS_VERSION": "Dasharo (coreboot+UEFI) 0.0.0", "TEST_FMAP_REGIONS": "", "TEST_ME_DISABLED": "false", "TEST_ROMHOLE_MIGRATION_FROM": "flashmap", "TEST_ROMHOLE_MIGRATION_TO": "flashmap" } }}
...                                         ${{ ("UEFI Update", "DPP") }}=${{ {"TEST_ME_OP_MODE": "2", "TEST_ME_HAP_DISABLED": "true"} }}
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI->Heads Transition", "DPP") }}
...                                         ${{ ("UEFI Update", "DPP") }}
...                                         ${{ ("Initial Deployment", "DPP") }}
