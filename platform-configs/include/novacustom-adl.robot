*** Variables ***
# Flash
${FLASH_SIZE}=                              ${32*1024*1024}

# CPU - all our models happen to have 4P + 8E configuration
${INITIAL_CPU_FREQUENCY}=                   2100
${DEF_CORES_PER_SOCKET}=                    12
${DEF_THREADS_PER_CORE}=                    2
${DEF_THREADS_TOTAL}=                       16
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                          0-15
${DEF_SOCKETS}=                             1

# Connectivity
${MINI_PC_IE_SLOT_SUPPORT}=                 ${TRUE}
${WIFI_CARD}=                               Intel(R) Wi-Fi 6 AX201 160MHz
# ${WIFI_CARD}=    Qualcomm Atheros AR946x Wireless Network Adapter
${WIFI_CARD_UBUNTU}=                        Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
# ${WIFI_CARD_UBUNTU}=    Qualcomm Atheros AR9462 Wireless Network Adapter

${BLUETOOTH_CARD_UBUNTU}=                   Intel Corp. AX201 Bluetooth

# USB
${WEBCAM_UBUNTU}=                           Chicony Electronics Co., Ltd Chicony USB2.0 Camera

# DMI
${DMIDECODE_FIRMWARE_VERSION}=              Dasharo (coreboot+UEFI) v1.8.0-rc9
${DMIDECODE_RELEASE_DATE}=                  03/24/2026
${DMIDECODE_SERIAL_NUMBER}=                 123456789

${L3_CACHE_SUPPORT}=                        ${TRUE}

# DTS E2E variables
&{DTS_TEST_EXPORTS}=
...                                         &{DTS_TEST_BASE_EXPORTS}
...                                         TEST_AC_PRESENT=true
...                                         TEST_ME_DISABLED=false
...                                         TEST_ME_OP_MODE=1
...                                         TEST_VBOOT_KEYS=true
...                                         TEST_FMAP_REGIONS=BOOTSPLASH
...                                         TEST_BOARD_HAS_BOOTSPLASH=false

@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI Update", "DCR") }}

${TESTS_IN_WINDOWS_SUPPORT}=                ${TRUE}

${INTEL_CBNT_BOOTGUARD_FUSING_SUPPORT}=     ${TRUE}
