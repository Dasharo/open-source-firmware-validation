*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       SSH
${DUT_CONNECTION_METHOD}=               SSH
${POWER_CTRL}=                          none
${TESTS_IN_FIRMWARE_SUPPORT}=           ${FALSE}
${OPTIONS_LIB}=                         options-lib_dcu

${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.9.0
${DMIDECODE_PRODUCT_NAME}=              NUC_BOX
${DMIDECODE_MANUFACTURER}=              NovaCustom
${DMIDECODE_TYPE}=                      Desktop
${FLASH_LENGTH}=                        ${TBD}
${FW_VERSION}=                          v0.9.0
${DMIDECODE_RELEASE_DATE}=              08/27/2025
${FLASHROM_FLAGS}=                      ${EMPTY}
${EXPECTED_FW_SHA256}=                  7595d57fcec2d315db0b612b9aab6cf680a1151719b7a3b2d3313aea6be97c06
${DMIDECODE_SERIAL_NUMBER}=		123456789
${SERIAL_NUMBER_VERIFICATION}=		${TRUE}

${WIFI_CARD}=                           Intel Corporation Meteor Lake PCH CNVi WiFi

${DEFAULT_BOOT_OS_ID}=                  ${ENV_ID_UBUNTU}
@{TESTED_LINUX_DISTROS}=
...                                     ${ENV_ID_UBUNTU}  ${ENV_ID_FEDORA}  ${ENV_ID_QUBES}
${TESTS_IN_WINDOWS_SUPPORT}=            ${TRUE}

${GPU_PERFORMANCE_TESTS_SUPPORT}=       ${TRUE}
${ESP_SCANNING_SUPPORT}=                ${TRUE}
${USB_DISKS_DETECTION_SUPPORT}=         ${TRUE}
${USB_KEYBOARD_DETECTION_SUPPORT}=      ${TRUE}
${FAN_SPEED_MEASURE_SUPPORT}=           ${TRUE}

# DTS E2E test variables
@{DTS_TEST_WORKFLOWS}=                  Initial Deployment    UEFI Update
${DTS_TEST_SYSTEM_VENDOR}=              NovaCustom
&{DTS_TEST_VERSIONS}=
...                                     &{DTS_TEST_VERSIONS_BASE}
...                                     UEFI Update=Dasharo (coreboot+UEFI) 0.9.0
&{DTS_TEST_EXPORTS}=
...                                     &{DTS_TEST_BASE_EXPORTS}
...                                     TEST_SOUND_CARD_PRESENT=false
...                                     TEST_BOARD_HAS_GBE_REGION=false
...                                     TEST_HCI_PRESENT=true
...                                     TEST_MEI_AMT_CHECK=true
# robocop: off=LEN08
&{DTS_TEST_EXPORTS_PER_WORKFLOW}=
...                                     &{DTS_TEST_EXPORTS_PER_WORKFLOW_BASE}
...                                     Initial Deployment=&{{ {"TEST_SYSTEM_MODEL": "NUC BOX-125H", "TEST_SYSTEM_VENDOR": "ASRock Industrial", "TEST_BIOS_VENDOR": "proprietary", "TEST_USING_OPENSOURCE_EC_FIRM": "false"} }}
...                                     UEFI Update=&{{ {"TEST_ME_HAP_DISABLED": "true", "TEST_ME_OP_MODE": "2", "TEST_HCI_PRESENT": "false"} }}
# robocop: off=LEN08
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                     ${{ ("Initial Deployment", "DCR") }}
...                                     ${{ ("UEFI Update", "DCR") }}

# End of DTS E2E test variables

${CAPSULE_UPDATE_SUPPORT}=              ${TRUE}
