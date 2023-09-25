*** Settings ***
Resource    ../../../keywords.robot


*** Keywords ***
Detect Pwrtest
    [Documentation]    This keyword checks if pwrtest is installed. Adequate
    ...    variable has to be set
    ${ls}=    Execute Command In Terminal    ls '${WINDOWS_PWRTEST_LOCATION}'
    Should Contain
    ...    ${ls}
    ...    pwrtest.exe
    ...    msg=pwrtest not found! Make sure that WDK is installed and windows_pwrtest_location is set correctly!

Perform Suspend Test Using Pwrtest
    [Documentation]    Keyword allows to perform hibernation and resume
    ...    procedure test by using Firmware Test Suite tool
    Write Into Terminal    & '${WINDOWS_PWRTEST_LOCATION}\\pwrtest.exe' /cs
    Sleep    60s
    Read From Terminal Until Prompt
    ${logs}=    Execute Command In Terminal    Get-Content -Path '${WINDOWS_PWRTEST_LOCATION}\\pwrtestlog.log'
    ${pass}=    Run Keyword And Return Status
    ...    Should Contain    ${logs}    End: Pass
    RETURN    ${pass}
