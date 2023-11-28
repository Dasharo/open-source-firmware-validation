*** Keywords ***
Check Firmware Version
    [Documentation]    Keyword allows to check firmware version in the Dasharo
    ...    Tools Suite Shell.
    ${output}=    Execute Command In Terminal    dmidecode -t 0
    Should Contain    ${output}    ${FW_VERSION}
