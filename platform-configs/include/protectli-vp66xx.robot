*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                                      ${16*1024*1024}
${INITIAL_CPU_FREQUENCY}=                           2600
${MAX_CPU_TEMP}=                                    82

${CPU_P_CORES_MAX}=                                 2
${CPU_E_CORES_MAX}=                                 8

${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v0.9.2-rc1
${DMIDECODE_RELEASE_DATE}=                          05/26/2025

${EMMC_SUPPORT}=                                    ${FALSE}
${HYPER_THREADING_SUPPORT}=                         ${TRUE}
${INTEL_HYBRID_ARCH_SUPPORT}=                       ${TRUE}
@{ETH_PERF_PAIR_2_G}=                               enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=                              enp2s0f0    enp2s0f1
${WIFI_CARD_UBUNTU}=                                Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
${WIFI_CARD}=                                       Qualcomm Atheros QCA61x4A Wireless Network Adapter

${ETHERNET_ID}=                                     8086:125c

${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${TRUE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}=               ${TRUE}

# Variables used in lib/sensors to determine platform-specific methods of
# measuring temperatures, fans etc.
${SENSORS_CONFIG_FILE}=                             include/sensors/protectli-vp66xx-sensors-config.yaml
${CUSTOM_FAN_CURVE_FILE}=                           include/sensors/protectli-vp66xx-fan-curve-config.yaml

${CAPSULE_UPDATE_SUPPORT}=                          ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${TRUE}
${COREBOOT_REDUNDANT_BOOT_SUPPORT}=                 ${TRUE}
