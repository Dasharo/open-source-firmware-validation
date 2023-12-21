*** Settings ***
Library     ../keywords.py


*** Keywords ***
Get Linux Version ID
    [Documentation]    This keyword returns the linux version.
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
    [Documentation]    This keyword checks whether a utility is available in the
    ...    system and logs it's version.
    [Arguments]    ${utility}
    ${output}=    Telnet.Execute Command    ${utility} --version
    Log    ${output}
    ${output}=    Telnet.Execute Command    echo $?
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    0
