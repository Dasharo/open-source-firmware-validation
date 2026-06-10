*** Settings ***
Resource    include/msi-z690-z790-common.robot


*** Variables ***
${FW_VERSION}=                              v1.1.6
${DMIDECODE_SERIAL_NUMBER}=                 N/A
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=                  MS-7D25
${DMIDECODE_RELEASE_DATE}=                  05/30/2026

${CPU_MAX_FREQUENCY}=                       5200
${CPU_MIN_FREQUENCY}=                       300

${DEF_THREADS_PER_CORE}=                    2
${DEF_THREADS_TOTAL}=                       20
${DEF_ONLINE_CPU}=                          0-19
${DEF_SOCKETS}=                             1

${DEF_CORES_PER_SOCKET}=                    14

${CPU_P_CORES_MAX}=                         6
${CPU_E_CORES_MAX}=                         8

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
