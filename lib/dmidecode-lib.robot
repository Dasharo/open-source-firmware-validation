*** Keywords ***
Check Firmware Version
    [Documentation]    Keyword allows to check firmware version via dmidecode
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should Contain    ${output}    ${FW_VERSION}

Get Firmware UUID
    [Documentation]    Keyword allows to check firmware UUID via dmidecode
    Write Into Terminal    dmidecode | grep UUID | awk -F': ' '{print $2}'
    ${uuid}=    Read From Terminal Until Prompt
    RETURN    ${uuid}

Get Firmware Serial Number
    [Documentation]    Keyword allows to check firmware serial number via
    ...    dmidecode

    Write Into Terminal    dmidecode | grep Serial | awk -F': ' 'NR == 1 {print $2}'
    ${serial_no}=    Read From Terminal Until Prompt
    RETURN    ${serial_no}
