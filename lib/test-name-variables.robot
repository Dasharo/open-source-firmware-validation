*** Keywords ***
Check Power Supply And Return Name
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${bat0_present_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/present
    ${bat0_present}=    Run Keyword And Return Status    Should Contain    ${bat0_present_raw}    1
    IF    ${bat0_present} == 1
        Log To Console    Battery detected (remember to change the name of the report files)
        ${ac_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/AC/online
        Should Not Contain    ${ac_online_raw}    No such file or directory
        ${ac_online}=    Run Keyword And Return Status    Should Contain    ${ac_online_raw}    1
        IF    ${ac_online} == 1
            Set Local Variable    ${POWER_SUPPLY_NAME}    (AC+battery)
        ELSE
            Set Local Variable    ${POWER_SUPPLY_NAME}    (battery)
        END
    ELSE
        Log To Console    Battery not detected
        Set Local Variable    ${POWER_SUPPLY_NAME}    ${EMPTY}
    END
    Set Suite Variable    ${POWER_SUPPLY_TEST_NAME}    ${POWER_SUPPLY_NAME}
