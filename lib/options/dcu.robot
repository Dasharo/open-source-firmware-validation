*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             OperatingSystem
Library             String


*** Keywords ***
Set UEFI Option
    [Documentation]    Set an UEFI option to a value.
    [Arguments]    ${option_name}    ${value}
    Run    git clone https://github.com/Dasharo/dcu
    # TODO: Remove once smmstore support is merged
    Run    cd dcu && git checkout smmstore > /dev/null 2>&1 && cd ..
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    Execute Linux Command    flashrom -p internal -r coreboot.rom --fmap -i FMAP -i SMMSTORE &> /dev/null
    SSHLibrary.Get File    coreboot.rom    dcu/coreboot.rom
    # TODO error handling
    Run    cd dcu && ./dcu v coreboot.rom --set "${option_name}" --value "${value}"
    SSHLibrary.Put File    dcu/coreboot.rom    coreboot.rom
    Execute Linux Command    flashrom -p internal -w coreboot.rom --fmap -i SMMSTORE --noverify-all &> /dev/null
    Power On
