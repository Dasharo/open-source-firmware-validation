*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    Capsule Update not supported
...                     AND
...                     Flash Firmware If Not QEMU
Suite Teardown      Run Keywords
...                     Flash Firmware If Not QEMU
...                     AND
...                     Log Out And Close Connection


*** Test Cases ***
CUP001.001 Capsule Update (Ubuntu)
    [Documentation]    This test aims to verify if Capsule Update process works.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    Set Prompt For Terminal    root@${UBUNTU_HOSTNAME}:/home#
    Execute Command In Terminal    cd ..
    Set Prompt For Terminal    root@${UBUNTU_HOSTNAME}:/#
    Execute Command In Terminal    cd ..
    Execute Command In Terminal    rm -r capsule_testing
    Execute Command In Terminal    mkdir capsule_testing
    Execute Command In Terminal    chmod 777 capsule_testing

    Send File To DUT    ./dasharo-stability/capsule-update-files/CapsuleApp.efi    /capsule_testing/CapsuleApp.efi
    Send File To DUT    ${CAPSULE_FW_FILE}    /capsule_testing/dasharo.cap

    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${original_bios_version}=    Extract BIOS Version    ${out}
    Execute UEFI Shell Command    FS0:
    Execute UEFI Shell Command    cd capsule_testing
    Execute UEFI Shell Command    CapsuleApp.efi dasharo.cap

    ${out}=    Read From Terminal Until    seconds.)

    ${digit}=    Get Key To Press    ${out}
    Write Bare Into Terminal    ${digit}

    Set DUT Response Timeout    120s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${updated_bios_version}=    Extract BIOS Version    ${out}

    Should Not Be Equal    ${original_bios_version}    ${updated_bios_version}


*** Keywords ***
Flash Firmware If Not QEMU
    IF    '${CONFIG}' != 'qemu'    Flash Firmware    ${FW_FILE}

Get Key To Press
    [Arguments]    ${text}
    ${matches}=    Get Regexp Matches    ${text}    [0-9]
    ${digit}=    Set Variable    ${matches[0]}
    Log    Found digit: ${digit}
    RETURN    ${digit}

Extract BIOS Version
    [Arguments]    ${text}
    ${lines}=    Split To Lines    ${text}
    ${bios_version}=    Set Variable    None
    FOR    ${line}    IN    @{lines}
        IF    'BIOS Version' in '${line}'
            ${bios_version}=    Set Variable    ${line}
        END
    END
    RETURN    ${bios_version}
