*** Variables ***
# Flash
${FLASH_SIZE}=                      ${16*1024*1024}

# CPU
${INITIAL_CPU_FREQUENCY}=           2800
${DEF_CORES_PER_SOCKET}=            4
${DEF_THREADS_PER_CORE}=            2
${DEF_THREADS_TOTAL}=               8
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                  0-7
${DEF_SOCKETS}=                     1

# Connectivity
${WIFI_CARD}=                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                Intel Corporation Wi-Fi 6 AX201 (rev 20)
${BLUETOOTH_CARD_UBUNTU}=           Intel Corp. AX201 Bluetooth

# USB
${WEBCAM_UBUNTU}=                   Chicony Electronics Co., Ltd Chicony USB2.0 Camera

# DMI
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.6.0-rc1
# TODO verify
${DMIDECODE_RELEASE_DATE}=          03/17/2022

${L3_CACHE_SUPPORT}=                ${TRUE}

# DTS-E2E variables
&{DTS_TEST_VERSIONS}=               &{DTS_TEST_VERSIONS_BASE}
...                                 UEFI Update=Dasharo (coreboot+UEFI) v1.5.0

&{DTS_TEST_EXPORTS}=
...                                 &{DTS_TEST_BASE_EXPORTS}
...                                 TEST_AC_PRESENT=true
...                                 TEST_ME_DISABLED=false
...                                 TEST_ME_OP_MODE=1
...                                 TEST_VBOOT_KEYS=true
...                                 TEST_FMAP_REGIONS=BOOTSPLASH
...                                 TEST_BOARD_HAS_BOOTSPLASH=false

@{DTS_TEST_WORKFLOW_PROFILES}=
...                                 ${{ ("UEFI Update", "DCR") }}
