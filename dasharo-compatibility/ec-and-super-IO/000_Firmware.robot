*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         ECR Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
ECR022.001 EC sync update with power adapter connected works correctly
    [Documentation]    This test aims to verify whether coreboot update
    ...    will also update EC firmware when power adapter is connected.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    ECR022.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    ECR022.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    ECR022.001 not supported
    # Flash old fw version without ec sync
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Execute Command In Terminal    wget -O /tmp/coreboot.rom ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash Via Internal Programmer    /tmp/coreboot.rom
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection

    # Make sure both coreboot and EC was flashed
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool
    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    Write Into Terminal    reboot
    Sleep    20s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Run Keyword And Expect Error    *    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Make sure EC isn't flashed second time after restart
    Write Into Terminal    reboot
    ${out}=    Read From Terminal Until    ${TIANOCORE_STRING}

ECR023.001 EC sync doesn't update with power adapter disconnected
    [Documentation]    This test aims to verify whether coreboot update
    ...    will display information to connect power adapter when it's
    ...    disconnected
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS023.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    DTS023.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS023.001 not supported

    # Flash old fw version without ec sync
    # Connect Laptop to power adapter
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Execute Command In Terminal    wget -O /tmp/coreboot.rom ${FW_NO_EC_SYNC_DOWNLOAD_LINK}
    Flash Via Internal Programmer    /tmp/coreboot.rom
    Flash EC Firmware
    ...    ${EC_NO_SYNC_DOWNLOAD_LINK}    TOOL=dasharo_ectool
    Sleep    15s
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Flash Locks Are Disabled
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool

    # Flash new fw with ec sync
    Put File    ${FW_FILE}    /tmp/coreboot_with_ec.rom    scp=ALL
    ${flash_result}=    Execute Command In Terminal
    ...    flashrom -p internal --ifd -i bios -w /tmp/coreboot_with_ec.rom
    Should Contain    ${flash_result}    VERIFIED
    # Disconnect power adapter
    Sonoff Off
    Write Into Terminal    reboot
    Sleep    20
    Power On
    Execute Manual Step    Enable console redirection
    Make Sure That Network Boot Is Enabled
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Run Keyword And Expect Error    *    Check Firmware Version
    ...    ${FW_NO_EC_SYNC_VERSION}
    Check EC Firmware Version
    ...    EXPECTED_VERSION=${EC_NO_SYNC_VERSION}    TOOL=dasharo_ectool
