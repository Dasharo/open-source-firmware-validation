*** Variables ***
${POWER_CTRL}=                                      none

# Flash
${FLASH_SIZE}=                                      ${32*1024*1024}

# CPU
${INITIAL_CPU_FREQUENCY}=                           2800
${DEF_CORES_PER_SOCKET}=                            16
${DEF_THREADS_PER_CORE}=                            2
${DEF_THREADS_TOTAL}=                               22
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                                  0-21
${DEF_SOCKETS}=                                     1

# Connectivity
${WIFI_CARD}=                                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                                Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${BLUETOOTH_CARD_UBUNTU}=                           Intel Corp. AX211 Bluetooth
${MINI_PC_IE_SLOT_SUPPORT}=                         ${TRUE}
${EXTERNAL_DISPLAY_PORT_SUPPORT}=                   ${TRUE}
# USB
${WEBCAM_UBUNTU}=                                   Bison Electronics Inc. BisonCam,NB Pro
${USB_STACK_SUPPORT}=                               ${TRUE}

# DMI
${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v1.5.2
# TODO verify
${DMIDECODE_RELEASE_DATE}=                          03/17/2022

# Not supported until we release the Dasharo System Driver
${FAN_SPEED_MEASURE_SUPPORT}=                       ${FALSE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${FALSE}
${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${FALSE}

${L3_CACHE_SUPPORT}=                                ${TRUE}


# DTS E2E variables
&{DTS_TEST_EXPORTS}=
...                                                 &{DTS_TEST_BASE_EXPORTS}
...                                                 TEST_AC_PRESENT=true
...                                                 TEST_NOVACUSTOM_MODEL=${DTS_TEST_BOARD_MODEL}
...                                                 TEST_FMAP_REGIONS=BOOTSPLASH
...                                                 TEST_BOARD_HAS_BOOTSPLASH=false
...                                                 TEST_HCI_PRESENT=true
...                                                 TEST_ME_HAP_DISABLED=true
...                                                 TEST_ME_OP_MODE=2

${CAPSULE_UPDATE_SUPPORT}=                          ${TRUE}
