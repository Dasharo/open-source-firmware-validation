*** Settings ***
Library             Collections
Library             Dialogs
Library             String
Resource            ../variables.robot
Resource            ../keywords.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${COREBOOT_REDUNDANT_BOOT_SUPPORT}
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
        Skip If    'semiauto' not in ${TEST_TAGS}    `semiauto` tag not selected

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
    Should Have Booted From Slot    COREBOOT

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
    Should Have Booted From Slot    COREBOOT_TS

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
    Should Have Booted From Slot    COREBOOT

CRB004.201 Slot A Protection (Ubuntu)
    [Documentation]    Check if the coreboot Slot A is protected with the
    ...    redundant boot feature turned on.
    Skip If    ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET} is ${None}    ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET} not defined, skipping test
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Attempt Slot B Flag    ${TRUE}
    Execute Reboot Command

    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    Verify Region Range Protected    # BOOTBLOCK
    ...    BIOS
    ...    ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.start}
    ...    ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.end}

    Verify Region Range Protected    # COREBOOT
    ...    BIOS
    ...    ${COREBOOT_REDUNDANT_BOOT_COREBOOT_OFFSET.start}
    ...    ${COREBOOT_REDUNDANT_BOOT_COREBOOT_OFFSET.end}


*** Keywords ***
Verify Region Range Protected
    [Arguments]    ${region_name}    ${expected_start}    ${expected_end}
    ${readonly_regions}=    Get Flashrom Readonly Offsets
    IF    len(${readonly_regions}) == 0
        Fail    No readonly regions found in flashrom output
    END

    ${expected_readonly_bootblock}=    Calculate Expected Flashrom Readonly Region
    ...    region_name=${region_name}
    ...    start_offset=${expected_start}
    ...    end_offset=${expected_end}

    VAR    ${expected_readonly_found}=    ${FALSE}
    FOR    ${region}    IN    @{readonly_regions}
        Log To Console    Found readonly region: ${region}
        Log To Console    Expected readonly region: ${expected_readonly_bootblock}
        ${start_matches}=    Evaluate    int(${region['start']}) == int(${expected_readonly_bootblock['start']})
        ${end_matches}=    Evaluate    int(${region['end']}) == int(${expected_readonly_bootblock['end']})
        IF    ${start_matches} and ${end_matches}
            VAR    ${expected_readonly_found}=    ${TRUE}
            BREAK
        END
    END
    IF    not ${expected_readonly_found}
        Fail    Expected readonly region ${expected_readonly_bootblock} not found in flashrom output
    END

Calculate Expected Flashrom Readonly Region
    [Arguments]    ${region_name}    ${start_offset}    ${end_offset}
    ${flashrom_regions}=    Get Flashrom Regions
    ${bios_start}=    Get From Dictionary    ${flashrom_regions['${region_name}']}    start
    ${bios_end}=    Get From Dictionary    ${flashrom_regions['${region_name}']}    end
    ${expected_readonly_start}=    Evaluate    hex(${bios_start} + ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.start})
    ${expected_readonly_end}=    Evaluate    hex(${bios_start} + ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.end})
    ${expected_readonly}=    Create Dictionary    start=${expected_readonly_start}    end=${expected_readonly_end}
    RETURN    ${expected_readonly}


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
    ${out}=    Execute Command In Terminal    cbmem -c | grep "Booting from"
    ${out}=    Convert To Lower Case    ${out}
    ${out}=    Strip String    ${out}
    Should Contain    ${out}    ${slot}

Get Flashrom Regions
    ${output}=    Execute Command In Terminal    flashrom -p internal
    ${lines}=    Split To Lines    ${output}
    ${dict}=    Create Dictionary
    FOR    ${l}    IN    @{lines}
        ${m}=    Get Regexp Matches    ${l}    FREG[0-9]+: (.+) region \\((0x[0-9a-f]+)-(0x[0-9a-f]+)\\) is (.+)    1    2    3    4
        IF    ${m} != []
            ${region}=    Create Dictionary    start=${m[0][1]}    end=${m[0][2]}    state=${m[0][3]}
            Set To Dictionary    ${dict}    ${m[0][0]}=${region}
        END
    END
    RETURN    ${dict}

Get Flashrom Readonly Offsets
    ${output}=    Execute Command In Terminal    flashrom -p internal
    ${lines}=    Split To Lines    ${output}
    ${list}=    Create List
    FOR    ${l}    IN    @{lines}
        ${m}=    Get Regexp Matches    ${l}    Warning: (0x[0-9a-f]+)-(0x[0-9a-f]+) is read-only    1    2
        IF    ${m} != []
            ${region}=    Create Dictionary    start=${m[0][0]}    end=${m[0][1]}
            Append To List    ${list}    ${region}
        END
    END
    RETURN    ${list}
