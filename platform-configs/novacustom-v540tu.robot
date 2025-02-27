*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          V540TU
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${CPU_MAX_FREQUENCY}=               4800
${CPU_MIN_FREQUENCY}=               300

${NVIDIA_GRAPHICS_CARD_SUPPORT}=    ${FALSE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears SSH buffer and sets Device Under Test
    ...    into Power On state from Mechanical Off. (coldboot) For example:
    ...    sonoff, RTE relays.
    IF    "${POWER_CTRL}"=="none"    RETURN
    Restore Initial DUT Connection Method
    Power Cycle On
    Sleep    2s
    RteCtrl Set OC GPIO    12    low
    Sleep    1s
    RteCtrl Set OC GPIO    12    high-z

# TODO make these generic
