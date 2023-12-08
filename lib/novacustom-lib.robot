*** Keywords ***
Check EC Firmware Version
    [Documentation]    Keyword allows checking EC firmware version via the
    ...    system76_ectool info utility.
    ${output}=    Execute Command In Terminal    system76_ectool info
    Should Contain    ${output}    ${EC_VERSION}

Flash EC Firmware
    [Documentation]    Keyword allows flashing EC firmware via the
    ...    system76_ectool info utility.
    Execute Command In Terminal
    ...    command=wget -0 /tmp/ec.rom https://3mdeb.com/open-source-firmware/Dasharo/${EC_BINARY_LOCATION}
    ...    timeout=320s
    ${output}=    Execute Command In Terminal
    ...    command=system76_ectool flash ec.rom
    ...    timeout=320s
    Should Contain    ${output}    Successfully programmed SPI ROM
    Sleep    10s
