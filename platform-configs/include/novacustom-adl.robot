# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Variables ***
# Flash
${FLASH_SIZE}=                      ${32*1024*1024}

# CPU - all our models happen to have 4P + 8E configuration
${INITIAL_CPU_FREQUENCY}=           2100
${DEF_CORES_PER_SOCKET}=            12
${DEF_THREADS_PER_CORE}=            2
${DEF_THREADS_TOTAL}=               16
# TODO: remove, the value below can be inferred from the one above
${DEF_ONLINE_CPU}=                  0-15
${DEF_SOCKETS}=                     1

# Audio
${DEVICE_AUDIO1}=                   ALC256
${DEVICE_AUDIO2}=                   Alderlake-P HDMI
${DEVICE_AUDIO1_WIN}=               Realtek High Definition Audio

# Connectivity
${WIFI_CARD}=                       Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
${BLUETOOTH_CARD_UBUNTU}=           Intel Corp. AX201 Bluetooth

# USB
${WEBCAM_UBUNTU}=                   Chicony Electronics Co., Ltd Chicony USB2.0 Camera

# DMI
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.7.2
# TODO verify
${DMIDECODE_RELEASE_DATE}=          03/17/2022
