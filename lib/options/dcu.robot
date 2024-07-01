*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Resource            ../terminal.robot


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

Get Boot Time From Cbmem
    [Documentation]    Calculates boot time based on cbmem timestamps
    # fix for LT1000 and protectli platforms (output without tabs)
    Get Cbmem From Cloud
    ${out_cbmem}=    Execute Command In Terminal    cbmem -T
    Should Not Contain
    ...    ${out_cbmem}
    ...    Operation not permitted
    ...    msg=Cannot get cbmem log. Probably Secure Boot is enabled (kernel lockdown mode).
    ${lines}=    Split To Lines    ${out_cbmem}
    ${first_line}=    Get From List    ${lines}    0
    ${last_line}=    Get From List    ${lines}    -1
    ${first_timestamp}=    Get Timestamp From Cbmem Log    ${first_line}
    ${last_timestamp}=    Get Timestamp From Cbmem Log    ${last_line}
    ${boot_time}=    Evaluate    (${last_timestamp} - ${first_timestamp}) / 1000000
    RETURN    ${boot_time}

Get Timestamp From Cbmem Log
    [Documentation]    Returns timestamp from a single cbmem -T log line
    [Arguments]    ${line}
    ${columns}=    Split String    ${line}
    ${timestamp}=    Get From List    ${columns}    1
    RETURN    ${timestamp}
