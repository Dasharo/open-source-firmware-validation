*** Keywords ***
Check EC Firmware Version
    [Documentation]    Keyword allows checking EC firmware version via the
    ...    system76_ectool info utility.
    [Arguments]    ${EXPECTED_VERSION}=${EC_VERSION}    ${TOOL}=system76_ectool
    ${output}=    Execute Command In Terminal    ${TOOL} info
    Should Contain    ${output}    ${EXPECTED_VERSION}

Flash EC Firmware
    [Documentation]    Keyword allows flashing EC firmware via the
    ...    system76_ectool info utility.
    [Arguments]
    ...    ${EC_FW_DOWNLOAD_LINK}=https://3mdeb.com/open-source-firmware/Dasharo/${EC_BINARY_LOCATION}
    ...    ${TOOL}=system76_ectool
    Execute Command In Terminal
    ...    command=wget -O /tmp/ec.rom ${EC_FW_DOWNLOAD_LINK}
    ...    timeout=320s
    Write Into Terminal    ${TOOL} flash /tmp/ec.rom
    Press Enter
    Read From Terminal Until    Successfully programmed SPI ROM
    Sleep    10s
