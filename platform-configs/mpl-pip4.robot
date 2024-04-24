*** Settings ***
Resource    ../lib/bios/menus-ami.robot
Resource    ../lib/secure-boot-lib-ami.robot
Resource    ../os-config/ubuntu-credentials.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=           pikvm
${DUT_CONNECTION_METHOD}=                   ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                                 ami
${SETUP_MENU_KEY}=                          ${DELETE}
${POWER_CTRL}=                              sonoff
${RTE_S2_N_PORT}=                           13541
${TIANOCORE_STRING}=                        to enter setup.
${BOOT_MENU_KEY}=                           ${F7}
${MANUFACTURER}=                            ${EMPTY}
${DEVICE_UBUNTU_USERNAME}=                  ${UBUNTU_USERNAME}
${DEVICE_UBUNTU_PASSWORD}=                  ${UBUNTU_PASSWORD}
${DEVICE_UBUNTU_USER_PROMPT}=               ${UBUNTU_USER_PROMPT}
${DEVICE_UBUNTU_ROOT_PROMPT}=               ${UBUNTU_ROOT_PROMPT}
${ANSIBLE_SUPPORT}=                         ${TRUE}

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=               ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=                 ${TRUE}
${TESTS_IN_DEBIAN_SUPPORT}=                 ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=                ${FALSE}

# Test module: dasharo-security
${SECURE_BOOT_SUPPORT}=                     ${TRUE}
${DTS_UEFI_SB_SUPPORT}=                     ${TRUE}
${SECURE_BOOT_CAN_REMOVE_EXTERNAL_CERT}=    ${FALSE}


*** Keywords ***
Power On
    [Documentation]    Manual step, user needs to restart DUT and confirm
    Restore Initial DUT Connection Method
    Sonoff Power Off
    Sleep    2s
    Sonoff Power On
