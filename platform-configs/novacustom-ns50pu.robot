*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                         Intel(R) Core(TM) i5-1240P


# Test configuration
${3_MDEB_WIFI_NETWORK}=         3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=      3200*1000
${CLEVO_USB_C_HUB}=             4-port
${DEVICE_NVME_DISK}=            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=         Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=      NS5x_NS7xPU
${EXTERNAL_HEADSET}=            USB PnP Audio Device
${USB_DEVICE}=                  Kingston
${USB_MODEL}=                   USB Flash Memory
${CPU_MAX_FREQUENCY}=           4500
${CPU_MIN_FREQUENCY}=           300

${TELNET_FUZZY_MAX_SUBSTITUTIONS}=                  1
${TELNET_FUZZY_MAX_INSERTIONS}=                     5
${TELNET_FUZZY_MAX_DELETIONS}=                      1

${INITIAL_DUT_CONNECTION_METHOD}=           Telnet
${DUT_CONNECTION_METHOD}=                   ${INITIAL_DUT_CONNECTION_METHOD}

@{TESTED_LINUX_DISTROS}=                ${ENV_ID_UBUNTU}    ${ENV_ID_FEDORA}
#${OPTIONS_LIB}=                 options-lib_dcu
${OPTIONS_LIB}=                 options-lib_uefi-setup-menu
${DASHARO_INTEL_ME_MENU_SUPPORT}=    ${TRUE}
${TESTS_IN_FIRMWARE_SUPPORT}=        ${TRUE}
${POWER_CTRL}=                              sonoff
${CHECK_POWER_LED_SUPPORT}=                         ${FALSE}
# DTS E2E variables
