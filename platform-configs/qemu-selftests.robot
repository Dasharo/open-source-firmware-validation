*** Comments ***
This config targets QEMU firmware with as many menus enabled as possible.


*** Settings ***
Library     ../lib/QemuMonitor.py    /tmp/qmp-socket
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${RTE_S2_N_PORT}=                       1234
${FLASH_SIZE}=                          ${8*1024*1024}
${BOOT_MENU_KEY}=                       ${ESC}
${SETUP_MENU_KEY}=                      ${F2}
${MANUFACTURER}=                        QEMU
${POWER_CTRL}=                          RteCtrl
${FLASHING_METHOD}=                     none

${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v0.2.0
${DMIDECODE_PRODUCT_NAME}=              QEMU x86 q35/ich9
${DMIDECODE_RELEASE_DATE}=              06/21/2024
${DMIDECODE_MANUFACTURER}=              Emulation
${DMIDECODE_VENDOR}=                    3mdeb
${DMIDECODE_FAMILY}=                    N/A
${DMIDECODE_TYPE}=                      Desktop

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${TRUE}
${TESTS_IN_METATB_SUPPORT}=             ${TRUE}

# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=       ${TRUE}
${DASHARO_USB_MENU_SUPPORT}=            ${TRUE}
${DASHARO_NETWORKING_MENU_SUPPORT}=     ${TRUE}
${DASHARO_INTEL_ME_MENU_SUPPORT}=       ${TRUE}
${DASHARO_CHIPSET_MENU_SUPPORT}=        ${TRUE}
${DASHARO_POWER_MGMT_MENU_SUPPORT}=     ${TRUE}
${DASHARO_PCI_PCIE_MENU_SUPPORT}=       ${TRUE}
${DASHARO_MEMORY_MENU_SUPPORT}=         ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Read From Terminal
    Qemu Monitor.System Reset
