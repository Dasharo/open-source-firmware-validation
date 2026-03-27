*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                                     Intel(R) Core(TM) i7-1260P

# Test configuration
${3_MDEB_WIFI_NETWORK}=                     3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=                  3200*1000
${CLEVO_USB_C_HUB}=                         4-port
${DEVICE_NVME_DISK}=                        Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=                     Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=                  NS5x_NS7xPU
@{EXTERNAL_HEADSETS}=                       USB PnP Audio Device
${USB_DEVICE}=                              Kingston
${USB_MODEL}=                               USB Flash Memory
${CPU_MAX_FREQUENCY}=                       4500
${CPU_MIN_FREQUENCY}=                       300

${OPTIONS_LIB}=                             options-lib_dcu

# DTS E2E variables
&{DTS_TEST_VERSIONS}=
...                                         &{DTS_TEST_VERSIONS_BASE}
...                                         Fuse Platform=Dasharo (coreboot+UEFI) 1.8.0
@{DTS_TEST_WORKFLOWS}=
...                                         Initial Deployment
...                                         UEFI Update
...                                         Fuse Platform
@{DTS_TEST_WORKFLOW_PROFILES}=
...                                         ${{ ("UEFI Update", "DCR") }}
&{DTS_TEST_EXPORTS_PER_FULL_WORKFLOW}=
...                                         ${{ ("UEFI Update", "DCR") }}=${{ { "TEST_ME_DISABLED": "true", "TEST_ME_OP_MODE": "3", "TEST_DIFFERENT_FMAP": "true" } }}
