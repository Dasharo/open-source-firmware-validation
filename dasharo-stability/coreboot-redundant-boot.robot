*** Settings ***
Library             Collections
Library             Dialogs
Library             String
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${COREBOOT_REDUNDANT_BOOT_SUPPORT}    coreboot redundant boot not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Variables ***
${NVRAM_ATTEMPT_B_FLAG}=        attempt_slot_b
${NVRAM_ATTEMPT_B_FLAG_SET}=    Enable
${NVRAM_ATTEMPT_B_FLAG_CLR}=    Disable


*** Test Cases ***
CRB001.201 Boot Slot A After Clearing CMOS (Ubuntu)
    [Documentation]    Check if clearing the CMOS makes the DUT boot from slot A
    ...    which should contain a recovery firmware
    [Tags]    automated

    IF    ${DUT_HAS_CMOS_RESET}
        Rte Psu Off
        Rte Clear Cmos
    ELSE
        Log    RTE CMOS clear not supported. Test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}    `semiauto` tag not selected

        Execute Manual Step    Disconnect the CMOS battery
        Sleep    5s
        Execute Manual Step    Connect the CMOS battery and assemble back the device completely
        IF    ${POWER_CTRL} == 'none'
            Execute Manual Step    Make sure the device is ON
        END
    END

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    RTC BUC Control Bit Should Be    0

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
    RTC BUC Control Bit Should Be    1

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
    RTC BUC Control Bit Should Be    0

CRB004.201 Slot A Protection (Ubuntu)
    [Documentation]    Check if the coreboot Slot A is protected with the
    ...    redundant boot feature turned on.

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Attempt Slot B Flag    ${TRUE}
    Execute Reboot Command

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    Flashrom Verify FMAP Regions Protected    BOOTBLOCK    COREBOOT


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

RTC BUC Control Bit Should Be
    [Arguments]    ${slot}
    ${out}=    Execute Command In Terminal    cbmem -c | grep "Top Swap: RTC BUC control bit"
    Should Contain    ${out}    Top Swap: RTC BUC control bit: ${slot}
