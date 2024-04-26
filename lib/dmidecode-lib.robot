*** Keywords ***
Check Firmware Version
    [Documentation]    Keyword allows to check firmware version via dmidecode
    [Arguments]    ${EXPECTED_VERSION}=${FW_VERSION}
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should Contain    ${output}    ${EXPECTED_VERSION}

Get Firmware UUID
    [Documentation]    Keyword allows to check firmware UUID via dmidecode
    ${uuid}=    Execute Command In Terminal    dmidecode | grep UUID | awk -F': ' '{print $2}'
    RETURN    ${uuid}

Get Firmware Serial Number
    [Documentation]    Keyword allows to check firmware serial number via
    ...    dmidecode
    ${serial_no}=    Execute Command In Terminal    dmidecode | grep Serial | awk -F': ' 'NR == 1 {print $2}'
    RETURN    ${serial_no}
