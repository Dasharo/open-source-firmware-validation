*** Settings ***
Library             Collections
Library             Dialogs
Library             String
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated

*** Variables ***
${NVRAM_ATTEMPT_B_FLAG}=        Attempt Slot B    #TBD
${NVRAM_ATTEMPT_B_FLAG_SET}=    1    # TBD
${NVRAM_ATTEMPT_B_FLAG_CLR}=    0    # TBD

*** Test Cases ***
CRB001.201 Boot Slot A After Clearing CMOS (Ubuntu)
    [Documentation]    Check if clearing the CMOS makes the DUT boot from slot A
    ...    which should contain a recovery firmware
    [Tags]    semiauto
    Execute Manual Step    Disconnect the CMOS battery
    Sleep    5s
    Execute Manual Step    Connect the CMOS battery

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Should Have Booted From Slot    A


CRB002.201 Boot Slot B After Setting Attempt Slot B Flag (Ubuntu)
    [Documentation]    Check if setting the Attempt Slot B flag the device boots
    ...    from the slot B
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Attempt Slot B Flag    ${TRUE}
    Execute Reboot Command

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Should Have Booted From Slot    B

CRB003.201 Boot Slot A After Clearing Attempt Slot B Flag (Ubuntu)
    [Documentation]    Check if clearing the Attempt Slot B flag the device boots
    ...    from the slot A
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Attempt Slot B Flag    ${FALSE}
    Execute Reboot Command

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Should Have Booted From Slot    A


*** Keywords ***
Set Attempt Slot B Flag
    [Arguments]    ${state}=${TRUE}
    IF    ${state}
        VAR    ${flag_state}=    ${NVRAM_ATTEMPT_B_FLAG_SET}
    ELSE
        VAR    ${flag_state}=    ${NVRAM_ATTEMPT_B_FLAG_CLR}
    END

    ${out}=    Execute Command In Terminal    nvramtool -w ${NVRAM_ATTEMPT_B_FLAG}=${flag_state}
    ${out}=    Execute Command In Terminal    nvramtool -r ${NVRAM_ATTEMPT_B_FLAG}
    Should Contain    ${out}    ${flag_state}

Should Have Booted From Slot
    [Arguments]    ${slot}
    ${slot}=    Convert To Lower Case    ${slot}
    # TBD - will this show slot B?
    ${out}=    Execute Command In Terminal    cbmem -c | grep -E "Slot [AB] is selected" | uniq | grep -oE " [AB] "
    ${out}=    Convert To Lower Case    ${out}
    ${out}=    Strip String    ${out}
    Should Be Equal    ${out}    ${slot}


