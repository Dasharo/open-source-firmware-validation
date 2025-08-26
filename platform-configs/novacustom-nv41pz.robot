*** Settings ***
Resource    include/novacustom-adl.robot
Resource    include/novacustom-common.robot


*** Variables ***
# CPU
${CPU}=                             Intel(R) Core(TM) i5-1240P CPU

# Test configuration
${3_MDEB_WIFI_NETWORK}=             3mdeb_abr
${CLEVO_BATTERY_CAPACITY}=          3200*1000
${CLEVO_USB_C_HUB}=                 4-port
${DEVICE_NVME_DISK}=                Non-Volatile memory controller
${DEVICE_USB_KEYBOARD}=             Logitech, Inc. Keyboard K120
${DMIDECODE_PRODUCT_NAME}=          NV4xPZ
${EXTERNAL_HEADSET}=                USB PnP Audio Device
${USB_DEVICE}=                      Kingston
${USB_MODEL}=                       USB Flash Memory
${CPU_MAX_FREQUENCY}=               4800
${CPU_MIN_FREQUENCY}=               300

${BLUETOOTH_CARD_UBUNTU}=           8087:0026

${POWER_CTRL}=                      none

${USB_STACK_SUPPORT}=               ${TRUE}
${TESTS_IN_WINDOWS_SUPPORT}=        ${FALSE}

${TPM_SUPPORTED_VERSION}=           2
${TPM_EXPECTED_CHIP}=               SLB9670

${OPTIONS_LIB}=                     options-lib_dcu

# cpu performance Windows
&{UPP_SMALLPT_BENCHMARK}=           name=smallpt    score=30.796    scale=lower_is_better    dev=0.2    type=singlecore
&{UPP_CRAFTY_BENCHMARK}=
...                                 name=crafty
...                                 score=7480997
...                                 scale=higher_is_better
...                                 dev=0.2
...                                 type=singlecore
&{UPP_CACHEBENCH_BENCHMARK}=
...                                 name=cachebench
...                                 score=75584.7
...                                 scale=higher_is_better
...                                 dev=0.2
...                                 type=multicore
&{UPP_BLAKE2_BENCHMARK}=            name=blake2    score=3.22    scale=lower_is_better    dev=0.2    type=multicore
@{UPP_BENCHMARKS}=
...                                 &{UPP_SMALLPT_BENCHMARK}
...                                 &{UPP_CRAFTY_BENCHMARK}
...                                 &{UPP_CACHEBENCH_BENCHMARK}
...                                 &{UPP_BLAKE2_BENCHMARK}

# DTS E2E variables
&{DTS_TEST_VERSIONS}=               &{DTS_TEST_VERSIONS_BASE}    UEFI->Heads Transition=Dasharo (coreboot+UEFI) 1.7.2
@{DTS_TEST_WORKFLOWS}=              Initial Deployment    UEFI Update    UEFI->Heads Transition

@{DTS_TEST_WORKFLOW_PROFILES}=
...                                 ${{ ("UEFI Update", "DCR") }}
...                                 ${{ ("UEFI->Heads Transition", "DPP") }}
