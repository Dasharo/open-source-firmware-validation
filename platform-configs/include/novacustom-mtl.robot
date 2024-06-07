*** Variables ***
# Flash
${FLASH_SIZE}=                      ${32*1024*1024}

# CPU
${INITIAL_CPU_FREQUENCY}=           2800
${DEF_CORES_PER_SOCKET}=            4
${DEF_THREADS_PER_CORE}=            2
${DEF_THREADS_TOTAL}=               ${EMPTY}
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                  0-7
${DEF_SOCKETS}=                     1

# Audio
${DEVICE_AUDIO1}=                   ALC245
${DEVICE_AUDIO2}=                   Tigerlake HDMI
${DEVICE_AUDIO1_WIN}=               Realtek High Definition Audio

# Connectivity
${WIFI_CARD}=                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                Intel Corporation Wi-Fi 6 AX201 (rev 20)
${BLUETOOTH_CARD_UBUNTU}=           Intel Corp. AX201 Bluetooth

# USB
${WEBCAM_UBUNTU}=                   Chicony Electronics Co., Ltd Chicony USB2.0 Camera

# DMI
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.5.2
# TODO verify
${DMIDECODE_RELEASE_DATE}=          03/17/2022
