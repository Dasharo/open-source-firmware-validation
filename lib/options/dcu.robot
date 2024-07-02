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

Execute Warmboot Command
    [Documentation]    Executes a command that will cause a warmboot

    # Using "Execute Command In Terimal" will cause the test to wait
    # for command prompt to appear before continuing but the prompt
    # will not appear again until we Login after reboot, so the test
    # would hang here and fail.
    # Sometimes it may take long to shutdown all systemd services,
    # so the waiting times have to be excessive to avoid false negatives.
    Write Into Terminal    rtcwake -m off -s 20
    Set DUT Response Timeout    300s
    Sleep    20s

Execute Suspend And Wake Command
    [Documentation]    Suspends and then wakes up the device after some time

    # Using "Execute Command In Terimal" will cause the test to wait
    # for command prompt to appear before continuing but the prompt
    # will not appear again until we Login after reboot, so the test
    # would hang here and fail.
    # Sometimes it may take long to shutdown all systemd services,
    # so the waiting times have to be excessive to avoid false negatives.
    Write Into Terminal    rtcwake -m disk -s 20
    Set DUT Response Timeout    300s
    Sleep    20s
