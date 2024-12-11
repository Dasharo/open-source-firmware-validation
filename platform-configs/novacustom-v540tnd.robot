*** Settings ***
Resource    include/novacustom-common.robot
Resource    include/novacustom-mtl.robot


*** Variables ***
${CPU}=                                         Intel(R) Core(TM) Ultra 7 155H

${3_MDEB_WIFI_NETWORK}=                         3mdeb_abr
${DEVICE_NVME_DISK}=                            Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                         Keyboard
${DMIDECODE_PRODUCT_NAME}=                      V5xTNC_TND_TNE
${EXTERNAL_HEADSET}=                            USB PnP Audio Device
${CPU_MAX_FREQUENCY}=                           4800
${CPU_MIN_FREQUENCY}=                           200

${NVIDIA_GRAPHICS_CARD_SUPPORT}=                ${TRUE}

${TESTS_IN_WINDOWS_SUPPORT}=                    ${FALSE}    # change windows/ubuntu support depending
${TESTS_IN_UBUNTU_SUPPORT}=                     ${TRUE}    # on which OS is first in the boot order

${WIFI_CARD_UBUNTU}=
...                                             00:14.3 Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${WEBCAM_UBUNTU}=                               Chicony Electronics Co., Ltd Chicony USB2.0 Camera
${MINI_PC_IE_SLOT_SUPPORT}=                     ${TRUE}
${WIFI_CARD}=
...                                             Network controller: Intel Corporation Meteor Lake PCH CNVi WiFi (rev 20)
${CPU_TESTS_SUPPORT}=                           ${TRUE}
${USB_DEVICE}=                                  SanDisk
${ME_STATICALLY_DISABLED}=                      ${TRUE}
${DMIDECODE_FIRMWARE_VERSION}=                  Dasharo (coreboot+UEFI) v0.9.1-rc5
${DMIDECODE_RELEASE_DATE}=                      09/10/2024
${TPM_DETECT_SUPPORT}=                          ${TRUE}
${CLEVO_USB_C_HUB}=                             Thunderbolt 4 Dock
${DOCKING_STATION_USB_C_CHARGING_SUPPORT}=      ${TRUE}
${DOCKING_STATION_AUDIO_SUPPORT}=               ${TRUE}
${VERIFIED_BOOT_SUPPORT}=                       ${TRUE}
