*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=390 seconds
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
...                     Skip If    not ${CUSTOM_LOGO_SUPPORT}    Logo customization tests not supported
#...                     AND
#...                     Make Sure That Flash Locks Are Disabled
#...                     AND
#...                     Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${DASHARO_LOGO_SHA256_SUM}=     1b82d46de1a170c3dd01504fc4e650b0fc747203d4c9c3fde67bc24035eca2c9
${DASHARO_LOGO_URL}=
...                             https://raw.githubusercontent.com/Dasharo/dasharo-blobs/main/dasharo/evaluation_logo.bmp


*** Test Cases ***
LCM001.001 Ability to replace logo in existing firmware image
    [Documentation]    Check whether the DUT is configured properly to use
    ...    a custom boot logo.
#    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM001.001 not supported
    Login To Linux
    Switch To Root User
    Detect Or Install Package    coreboot-utils
    # If BOOTSPLASH region is not there, the platform does not support this feature
    Read FMAP And BOOTSPLASH Regions Internally    /tmp/firmware.rom
    ${layout}=    Execute Command In Terminal    cbfstool /tmp/firmware.rom layout -w
    Should Contain    ${layout}    BOOTSPLASH

LCM001.002 Check replaced logo in existing firmware image
    [Documentation]    Check if the custom logo is displayed
#    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM001.002 not supported
    Login To Linux
    Switch To Root User
    Detect Or Install Package    coreboot-utils
    # 1. Replace the logo in firmware file
    Download File    ${DASHARO_LOGO_URL}    /tmp/logo.bmp
    Replace Logo In Firmware    /tmp/logo.bmp
    Execute Reboot Command

    ### DCU in DTS is not yet updated
    # Read FMAP And BOOTSPLASH Regions Internally    /tmp/firmware.rom
    # ${out}=    Execute Command In Terminal    dcu logo /tmp/firmware.rom -l /tmp/logo.bmp
    # Should Contain    ${out}    Setting /tmp/logo.bmp as custom logo
    # 2. Flash modified firmware
    # Write BOOTSPLASH Region Internally    /tmp/firmware.rom
    # Execute Reboot Command

    # 3. Check if the displayed logo matches
    Login To Linux
    ${out}=    Execute Command In Terminal    sha256sum /sys/firmware/acpi/bgrt/image
    Should Contain    ${out}    ${DASHARO_LOGO_SHA256_SUM}

LCM004.001 Custom logo persists after firmware update
    [Documentation]    Check whether after updating the platform's firmware
    ...    with the `fwupd` command, the custom added logo remains unaffected
    ...    and continues to display.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    LCM004.001 not supported
#    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    LCM004.001 not supported
    ${laptop_platform}=    Check The Platform Is A Laptop
    Skip If    not ${laptop_platform}    The Platform is not a Laptop
    Skip
    Login To Linux
    Download File    ${DASHARO_LOGO_URL}    logo.bmp
    Set DUT Response Timeout    400s
    # Read Firmware Clevo -- fix keyword
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
    Should Contain    ${out}    ${DASHARO_LOGO_SHA256_SUM}
