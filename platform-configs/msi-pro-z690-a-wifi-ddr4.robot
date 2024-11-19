*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                          v1.1.4-rc1
${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v1.1.4-rc1
${DMIDECODE_PRODUCT_NAME}=              MS-7D25
${DMIDECODE_RELEASE_DATE}=              10/07/2024

${WIFI_CARD}=                           Intel(R) Wi-Fi 6 AX201 160MHz
${WIFI_CARD_UBUNTU}=                    Intel Corporation Alder Lake-S PCH CNVi WiFi (rev 11)

${WIRELESS_CARD_SUPPORT}=               ${TRUE}
${WIRELESS_CARD_WIFI_SUPPORT}=          ${TRUE}
${WIRELESS_CARD_BLUETOOTH_SUPPORT}=     ${TRUE}

${CPU_MAX_FREQUENCY}=                   5000
${CPU_MIN_FREQUENCY}=                   300

${DEVICE_AUDIO2}=                       Raptorlake HDMI

# We have 2 such platforms in the lab and options below are suitable only for one of them as they have different CPUs.
${DEF_THREADS_PER_CORE}=                2
${DEF_THREADS_TOTAL}=                   28
${DEF_ONLINE_CPU}=                      0-27
${DEF_SOCKETS}=                         1

${DEF_CORES_PER_SOCKET}=                20

${CPU_P_CORES_MAX}=                     8
${CPU_E_CORES_MAX}=                     12
${WDT_DEFAULT}=                         600
