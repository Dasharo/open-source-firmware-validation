*** Settings ***
Library     ../keywords.py


*** Keywords ***
Get Linux Version ID
    [Documentation]    This keyword return the linux version
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        ${output}=    SSHLibrary.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
    ELSE IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        ${output}=    Telnet.Execute Command    sh -c "cat /etc/os-release | grep VERSION_ID | cut -d '=' -f 2"
        ${output}=    Get Line    ${output}    0
    ELSE
        FAIL    Connection method not supported for checking version
    END
    RETURN    ${output}

Get Utility Version
    [Documentation]    This keyword checks whether a utility is available
    ...    fails if its not, but if it is the version gets logged.
    [Arguments]    ${utility}
    ${output}=    Telnet.Execute Command    ${utility} --version | head -1
    ${output}=    Get Line    ${output}    0
    Should Not Contain    ${output}    command not found
    Log    ${output}
