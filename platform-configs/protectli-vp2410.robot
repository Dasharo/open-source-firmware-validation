*** Settings ***
Resource    include/protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                          ${8*1024*1024}
${WIFI_CARD}=                           ${EMPTY}
${WIFI_CARD_UBUNTU}=                    ${EMPTY}
${LTE_CARD}=                            ${EMPTY}
${DEF_ONLINE_CPU}=                      0-3
${DEF_SOCKETS}=                         1
${INITIAL_CPU_FREQUENCY}=               2000
${MAX_CPU_TEMP}=                        77
${CPU_MAX_FREQUENCY}=                   2800
${CPU_MIN_FREQUENCY}=                   300

# eMMC driver support
${E_MMC_NAME}=                          8GTF4R

@{ATTACHED_USB}=                        @{EMPTY}

${DMIDECODE_SERIAL_NUMBER}=             N/A
${DMIDECODE_FIRMWARE_VERSION}=          Dasharo (coreboot+UEFI) v
${DMIDECODE_PRODUCT_NAME}=              VP2410
${DMIDECODE_RELEASE_DATE}=              ${EMPTY}
${DMIDECODE_MANUFACTURER}=              Protectli
${DMIDECODE_VENDOR}=                    3mdeb
${DMIDECODE_FAMILY}=                    Vault Pro
${DMIDECODE_TYPE}=                      Desktop

${L3_CACHE_SUPPORT}=                    ${FALSE}
${DASHARO_SECURITY_MENU_SUPPORT}=       ${TRUE}

# Test module: dasharo-security
${MEASURED_BOOT_SUPPORT}=               ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=        ${TRUE}
${UEFI_PASSWORD_SUPPORT}=               ${TRUE}
${ME_STATICALLY_DISABLED}=              ${TRUE}

${PLATFORM_CPU_SPEED}=                  2.00
${PLATFORM_RAM_SPEED}=                  2400
${PLATFORM_RAM_SIZE}=                   8192


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off
    Sleep    10s
    Telnet.Read
    # After RteCtrl Power Off, the platform cannot be powered back using the power button.
    # Possibly bug in HW or FW.
    Power Cycle On

Flash Protectli VP2410 Internal
    Set Local Variable    ${is_flash_chip_content_identical}    ${FALSE}
    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${device_ip}=    Get Hostname Ip
    # Get and build flashrom - currently we don't have such a keyword
    SSHLibrary.Write    scp -o StrictHostKeyChecking=no /tmp/coreboot.rom user@${device_ip}:/tmp/dasharo.rom
    SSHLibrary.Read Until    password:
    SSHLibrary.Write    ubuntu
    SSHLibrary.Read Until Prompt
    Write Into Terminal    ./flashrom -p internal -w /tmp/dasharo.rom --ifd -i bios
    ${flash_result}=    Read From Terminal Until Prompt
    ${is_flash_chip_content_identical}=    Evaluate
    ...    'Chip content is identical to the requested image' in '''${flash_result}'''
    IF    ${is_flash_chip_content_identical}    RETURN
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    Power Cycle On
    Should Contain    ${flash_result}    VERIFIED

Flash Protectli VP2410 External
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to ON state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Power Cycle On
    Sleep    5s
    RteCtrl Power Off
    Sleep    3s
    RteCtrl Set OC GPIO    2    high-z
    Sleep    2s
    RteCtrl Set OC GPIO    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    1    low
    Sleep    2s
    Power Cycle Off
    Sleep    2s
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom -c "MX25U6435E/F" 2>&1
    ...    return_rc=True
    Sleep    2s
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    Power Cycle On
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
