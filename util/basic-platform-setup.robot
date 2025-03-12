*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# Library    ../osfv-scripts/osfv_cli/src/osfv/rf/rte_robot.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/ubuntu-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
BPS001.001 Power Control - PSU ON and serial output
    [Documentation]    Verifies if PSU can be turned ON and if the serial output can be read.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

BPS002.001 Power control - PSU OFF
    [Documentation]    Verifies if PSU can be turned OFF
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Rte Psu Off
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to switch PSU OFF

BPS003.001 RTE Power On
    [Documentation]    Verifies if Power Button can turn DUT ON/OFF.
    # TODO: do we have platforms in the lab that might not use
    # power/reset buttons? If so, we do not have flag for it.
    Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Power On keyword failed

    Rte Power Off
    Sleep    10s
    Read From Terminal
    ${result}=    Wait For Serial Output    timeout=10
    Should Not Be True    ${result}    msg=Failed to power off DUT via power button

    Rte Power On
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed to power on DUT via power button

BPS004.001 RTE Reset
    [Documentation]    Verifies if reset button can reset the DUT.
    Power On
    Wait For Serial Output
    Rte Reset
    Read From Terminal
    ${result}=    Wait For Serial Output
    Should Be True    ${result}    msg=Failed to reset DUT via reset button

BPS005.001 Boot to OS - Ubuntu
    [Documentation]    This test verifies if platform can be booted to Ubunto and if correct credentials are set.
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${logging}=    Get Logging Level
    IF    ${logging} != 0
        Log To Console    Changing logging level from ${logging} to 0
        Set Logging Level    0
    END
    ${logging}=    Get Logging Level
    Should Be Equal As Integers    ${logging}    0

BPS005.002 Boot to OS - Windows
    [Documentation]    This test verifies if platform can be booted to Windows, if SSH server is enabled and if correct credentials are set.
    Power On
    Login To Windows

BPS006.001 External flashing
    [Documentation]    This test verifies if the flash die can be detected.
    ${rc}=    Rte Flash Probe
    Should Be Equal As Integers    ${rc}    0

BPS006.002 Internal flashing
    [Documentation]    This test verifies if flashrom can detect the die.
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    Found chipset

BPS007.001 RTE CMOS clear
    [Documentation]    This test verifies if CMOS clear works with the platform setup.
    # CMOS should be cleared when platform is cut off from power
    Rte Psu Off
    Rte Clear Cmos
    Power On
    # TODO: Can we do it without Linux?
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    # Test relies entirely on coreboot console to print the CMOS invalid message
    Get Cbmem From Cloud
    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep -i rtc

    Should Contain Any    ${out}
    ...    "RTC: Clear requested"
    ...    "rtc_failed \= 0x1"
    ...    ignore_case=True

    Execute Reboot Command

    # Now check if the CMOS is not reset again after reboot. If CMOS fails it
    # means that either the CMOS battery is not connected at all or the
    # platform setup is incorrect.
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal
    ...    cbmem -1 | grep -i rtc

    Should Not Contain Any
    ...    ${out}
    ...    "RTC: Clear requested"
    ...    "rtc_failed \= 0x1"
    ...    ignore_case=True
    ...    msg=CMOS is invalid after reboot. Either the CMOS battery is not connected or the connection is wrong. Check DUT setup.


*** Keywords ***
Check If Empty
    [Documentation]    Checks if string is empty. Ignores spaces and newline.
    [Arguments]    ${str}
    ${str_length}=    Get Length    ${str}
    IF    ${str_length} != 0
        @{str}=    Split String To Characters    ${str}
        FOR    ${char}    IN    @{str}
            IF    '${char.replace('\n','').strip()}' != '${SPACE}'
                RETURN    ${FALSE}
            END
        END
    END
    RETURN    ${TRUE}

Wait For Serial Output
    [Documentation]    This keywords checks every second if non-whitespace
    ...    characters had appeared on the serial output. As soon as it happens,
    ...    it returns True. If it fails to receive any non-whitespace
    ...    characters as output during period defined as ${timeout} argument,
    ...    it returns False.
    [Arguments]    ${timeout}=120

    FOR    ${i}    IN RANGE    ${timeout}
        Sleep    1s
        ${out}=    Read From Terminal
        ${result}=    Check If Empty    ${out}
        IF    ${result} == ${FALSE}    RETURN    ${TRUE}
    END
    RETURN    ${FALSE}
