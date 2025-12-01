*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                          v0.9.4
${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=              MS-7E06
${DMIDECODE_RELEASE_DATE}=              11/29/2025

${CPU_MAX_FREQUENCY}=                   5200
${CPU_MIN_FREQUENCY}=                   300

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI->Heads Transition=Dasharo (coreboot+UEFI) 0.9.4
${DTS_TEST_BOARD_MODEL}=                PRO Z790-P WIFI (MS-7E06)
@{DTS_TEST_DEFAULT_RELEASES}=           DPP
&{DTS_TEST_EXPORTS}=
...                                     &{DTS_TEST_BASE_EXPORTS}
...                                     TEST_BOARD_HAS_BOOTSPLASH=false
...                                     TEST_VBOOT_KEYS=true
...                                     TEST_ME_HAP_DISABLED=true
...                                     TEST_SOUND_CARD_PRESENT=false
...                                     TEST_BOARD_HAS_GBE_REGION=false
...                                     TEST_INTEL_IS_FUSED=true
...                                     TEST_HCI_PRESENT=true
...                                     TEST_BOARD_FD_REGION_RW=false
...                                     TEST_BOARD_ME_REGION_RW=false
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_WORKFLOW}=
...                                     &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
...                                     UEFI Update=&{{ {"TEST_IS_COREBOOT": "true", "TEST_FMAP_REGIONS": "BOOTSPLASH", "TEST_HCI_PRESENT": "false", "TEST_BOARD_FD_REGION_RW": "true", "TEST_BOARD_ME_REGION_RW": "true"} }}
...                                     UEFI->Heads Transition=&{{ {"TEST_IS_COREBOOT": "true", "TEST_FMAP_REGIONS": "BOOTSPLASH"} }}
# robocop: on=LEN08
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("UEFI->Heads Transition", "DPP") }}
...                                     ${{ ("UEFI Update", "DPP") }}
...                                     ${{ ("Initial Deployment", "DPP") }}
