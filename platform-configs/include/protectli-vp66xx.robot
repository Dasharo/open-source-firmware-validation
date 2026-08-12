*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                                      ${16*1024*1024}
${INITIAL_CPU_FREQUENCY}=                           2600
${MAX_CPU_TEMP}=                                    82

${CPU_P_CORES_MAX}=                                 2
${CPU_E_CORES_MAX}=                                 8

${DMIDECODE_FIRMWARE_VERSION}=                      Dasharo (coreboot+UEFI) v0.9.2
${DMIDECODE_RELEASE_DATE}=                          06/10/2025

${EMMC_SUPPORT}=                                    ${FALSE}
${HYPER_THREADING_SUPPORT}=                         ${TRUE}
${INTEL_HYBRID_ARCH_SUPPORT}=                       ${TRUE}
@{ETH_PERF_PAIR_2_G}=                               enp5s0    enp6s0
@{ETH_PERF_PAIR_10_G}=                              enp2s0f0    enp2s0f1
${WIFI_CARD_UBUNTU}=                                Qualcomm Atheros QCA6174 802.11ac Wireless Network Adapter
${WIFI_CARD}=                                       Qualcomm Atheros QCA61x4A Wireless Network Adapter
${EXPECTED_FW_SHA256}=                              f66e19018e2893f6cfec0d1edbfc0db033293ac16fdb21debb5da745071ddada

${ETHERNET_ID}=                                     8086:125c

${CUSTOM_FAN_CURVE_PERFORMANCE_MODE_SUPPORT}=       ${TRUE}
${CUSTOM_FAN_CURVE_SILENT_MODE_SUPPORT}=            ${TRUE}
${CUSTOM_FAN_CURVE_OFF_MODE_SUPPORT}=               ${TRUE}

# Variables used in lib/sensors to determine platform-specific methods of
# measuring temperatures, fans etc.
${SENSORS_CONFIG_FILE}=                             include/sensors/protectli-vp66xx-sensors-config.yaml
${CUSTOM_FAN_CURVE_FILE}=                           include/sensors/protectli-vp66xx-fan-curve-config.yaml

${CAPSULE_UPDATE_SUPPORT}=                          ${TRUE}
${CAPSULE_UPDATE_IN_FUM_SUPPORT}=                   ${FALSE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=                 ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=                   ${TRUE}
${INTEL_CBNT_SUPPORT}=                              ${TRUE}
${INTEL_CBNT_STATUS_MENU_SUPPORT}=                  ${TRUE}
${DTS_SUPPORT}=                                     ${TRUE}

# DTS E2E variables
${DTS_TEST_SYSTEM_VENDOR}=                          Protectli
@{DTS_TEST_WORKFLOWS}=                              Fuse Platform
@{DTS_TEST_DEFAULT_RELEASES}=                       DCR
@{DTS_TEST_WORKFLOW_PROFILES}=                      ${{ ("Fuse Platform", "DCR") }}
&{DTS_TEST_VERSIONS}=
...                                                 &{DTS_TEST_VERSIONS_BASE}
...                                                 Fuse Platform=Dasharo (coreboot+UEFI) 0.9.3
&{DTS_TEST_EXPORTS}=
...                                                 &{DTS_TEST_BASE_EXPORTS}
...                                                 TEST_ME_HAP_DISABLED=true
...                                                 TEST_ME_OP_MODE=2
