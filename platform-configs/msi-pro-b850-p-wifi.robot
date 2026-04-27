*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                          v0.9.0-rc1
${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) ${FW_VERSION}
${DMIDECODE_PRODUCT_NAME}=              MS-7E56
${DMIDECODE_RELEASE_DATE}=              04/27/2026

${INITIAL_DUT_CONNECTION_METHOD}=           Telnet
${DUT_CONNECTION_METHOD}=                   Telnet
${POWER_CTRL}=                              sonoff
${DUT_HAS_CMOS_RESET}=                      ${TRUE}
${FLASH_SIZE}=                              ${32*1024*1024}
${INITIAL_CPU_FREQUENCY}=                   4350
${FLASHING_METHOD}=                         external

${SETUP_MENU_KEY}=                          ${DELETE}

# CPF
${CPU_MAX_FREQUENCY}=                       5000
${CPU_MIN_FREQUENCY}=                       1200
${MAX_CPU_TEMP}=                            95

${DEF_THREADS_TOTAL}=                       12
${DEF_THREADS_PER_CORE}=                    2
${DEF_CORES_PER_SOCKET}=                    6
${DEF_SOCKETS}=                             1
${DEF_ONLINE_CPU}=                          0-11

${PLATFORM_CPU_SPEED}=                      4.35
${PLATFORM_RAM_SPEED}=                      0
${PLATFORM_RAM_SIZE}=                       0
${MAX_CPU_TEMP_THRESHOLD}=                  93
${CPU}=                                     AMD Ryzen 5 8600G w/ Radeon 760M Graphics

# Does not boot anything yet
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE}
@{TESTED_LINUX_DISTROS}=                @{EMPTY}

${DASHARO_SECURITY_MENU_SUPPORT}=               ${FALSE}
${DASHARO_USB_MENU_SUPPORT}=                    ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=             ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=               ${FALSE}
${DASHARO_CHIPSET_MENU_SUPPORT}=                ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=             ${TRUE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=               ${TRUE}
${DASHARO_PCIE_REBAR_SUPPORT}=                  ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=                 ${FALSE}

${INTEL_HYBRID_ARCH_SUPPORT}=                   ${FALSE}
${HYPER_THREADING_SUPPORT}=                     ${FALSE}
${CPU_THROTTLING_SUPPORT}=                      ${FALSE}
