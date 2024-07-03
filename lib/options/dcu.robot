*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../terminal.robot
Resource            ../../keywords.robot
Resource            ../../platform-configs/include/novacustom-common.robot
Resource            ../cbmem.robot


*** Keywords ***
Set UEFI Option
    [Documentation]    Set an UEFI option to a value.
    [Arguments]    ${option_name}    ${value}
    Run    git clone https://github.com/Dasharo/dcu
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Execute Command In Terminal    flashrom -p internal -r coreboot.rom --fmap -i FMAP -i SMMSTORE &> /dev/null
    SSHLibrary.Get File    coreboot.rom    dcu/coreboot.rom
    ${result}=    Run Process
    ...    cd dcu && ./dcu v coreboot.rom --set "${option_name}" --value "${value}"
    ...    shell=True
    Should Contain    ${result.stdout}    Success
    SSHLibrary.Put File    dcu/coreboot.rom    coreboot.rom
    Execute Command In Terminal    flashrom -p internal -w coreboot.rom --fmap -i SMMSTORE --noverify-all &> /dev/null
    Execute Reboot Command
    # Assume we don't have serial to tell us that we've rebooted, so just wait
    # 20s for shutdown to finish, to prevent subsequent kwds from running before
    # reboot.
    Sleep    20s

Get UEFI Option
    [Documentation]    Read an UEFI option value.
    [Arguments]    ${option_name}
    Run    git clone https://github.com/Dasharo/dcu
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Execute Command In Terminal    flashrom -p internal -r coreboot.rom --fmap -i FMAP -i SMMSTORE &> /dev/null
    Execute Command In Terminal    chmod 666 coreboot.rom
    SSHLibrary.Get File    coreboot.rom    dcu/coreboot.rom
    ${out}=    Run Process
    ...    cd dcu && ./dcu v coreboot.rom --get "${option_name}"
    ...    shell=True
    RETURN    ${out.stdout}

Get UEFI Boot Manager Entries
    [Documentation]    Read list of UEFI boot manager

    Login To Linux
    Switch To Root User

    ${boot_menu}=    SSHLibrary.Execute Command    efibootmgr
    RETURN    ${boot_menu}

Measure Average Warmboot Time
    [Documentation]    Performs a measurement of average warmboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        # Using "Execute Command In Terimal" will cause the test to wait
        # for command prompt to appear before continuing but the prompt
        # will not appear again until we Login after reboot, so the test
        # would hang here and fail.
        # Sometimes it may take long to shutdown all systemd services,
        # so the waiting times have to be excessive to avoid false negatives.
        Write Into Terminal    rtcwake -m off -s 60

        Set DUT Response Timeout    300s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END
    ${average}=    Evaluate    ${average}/${iterations}
    RETURN    ${average}

Measure Average Reboot Time
    [Documentation]    Performs a measurement of average reboot
    ...    boot time
    [Arguments]    ${iterations}

    ${average}=    Set Variable    0
    Log To Console    \n

    FOR    ${index}    IN RANGE    0    ${iterations}
        Login To Linux
        Switch To Root User

        Execute Reboot Command
        Sleep    10s

        Login To Linux
        Switch To Root User
        ${boot_time}=    Get Boot Time From Cbmem
        Log To Console    (${index}) Boot time: ${boot_time} s)
        ${average}=    Evaluate    ${average}+${boot_time}
    END

    ${average}=    Evaluate    ${average}/${iterations}
    RETURN    ${average}
