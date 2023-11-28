*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Make Sure That Flash Locks Are Disabled
...                     AND
...                     Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${GOLDEN_LOGO_SHA256_SUM}=      f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513


*** Test Cases ***
LCM001.001 Ability to replace logo in existing firmware image
    [Documentation]    Check whether the DUT is configured properly to use
    ...    a custom boot logo.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    LCM001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM001.001 not supported

    Power On
    Set DUT Response Timeout    60s
    Launch To DTS Shell
    Download File    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download    /tmp/logo.bmp
    Replace Logo In Firmware    /tmp/logo.bmp
    Write Into Terminal    poweroff

LCM001.002 Check replaced logo in existing firmware image
    [Documentation]    Check if the custom logo is displayed
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    LCM001.002 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM001.002 not supported

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    sha256sum /sys/firmware/acpi/bgrt/image
    Should Contain    ${out}    ${GOLDEN_LOGO_SHA256_SUM}

LCM004.001 Custom logo persists after firmware update
    [Documentation]    Check whether after updating the platform's firmware
    ...    with the `fwupd` command, the custom added logo remains unaffected
    ...    and continues to display.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    LCM004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM004.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Download File    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download    logo.bmp
    Set DUT Response Timeout    400s
    Read Firmware Clevo
    Write Into Terminal    dcu logo coreboot.rom -l logo.bmp
    # Read From Terminal Until    Success -- only after DTS/dcu update
    Read From Terminal Until    logo
    Flash Firmware    coreboot.rom
    Write Into Terminal    dasharo-deploy update
    Read From Terminal Until    (Y
    Write Into Terminal    y
    Read From Terminal Until    (Y
    Write Into Terminal    y
    Read From Terminal Until    Updating EC...
    Sleep    60s
    Power On
    # needs a manual power button push here - update resets the power after
    # fail option
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Write Into Terminal    sha256sum /sys/firmware/acpi/bgrt/image
    ${out}=    Read From Terminal Until    root@3mdeb
    Should Contain    ${out}    ${GOLDEN_LOGO_SHA256_SUM}
