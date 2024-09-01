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
...                     AND
...                     Upload Required Files
Suite Teardown      Run Keywords
...                     Flash Firmware If Not QEMU
...                     AND
...                     Log Out And Close Connection


*** Test Cases ***
CUP001.001 Capsule Update With Wrong Keys
    [Documentation]    This test aims to verify...
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${original_bios_version}=    Extract BIOS Version    ${out}

    Start Update Process    wrong_cert.cap
    Sleep    60s

    Execute UEFI Shell Command    reset
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${updated_bios_version}=    Extract BIOS Version    ${out}

    Should Be Equal    ${original_bios_version}    ${updated_bios_version}

CUP001.001 Capsule Update With Wrong GUID
    [Documentation]    This test aims to verify...
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${original_bios_version}=    Extract BIOS Version    ${out}

    Start Update Process    invalid_guid.cap
    Sleep    60s

    Execute UEFI Shell Command    reset
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>
    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${updated_bios_version}=    Extract BIOS Version    ${out}

    Should Be Equal    ${original_bios_version}    ${updated_bios_version}

CUP003.001 Capsule Update
    [Documentation]    This test aims to verify if Capsule Update process works.

    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

    ${out}=    Execute UEFI Shell Command    smbiosview -t 0
    ${original_bios_version}=    Extract BIOS Version    ${out}

    Start Update Process    max_fw_ver.cap

    ${out}=    Read From Terminal Until
    ...    (The platform will automatically reboot and disable Firmware Update Mode

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

Upload Required Files
    ${file_name}=    Get File Name Without Extension    ${CAPSULE_FW_FILE}

    Check If Capsule File Exists    ../edk2/${file_name}_max_fw_ver.cap
    Check If Capsule File Exists    ../edk2/${file_name}_wrong_cert.cap
    Check If Capsule File Exists    ../edk2/${file_name}_invalid_guid.cap

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

    Log To Console    Sending ./dasharo-stability/capsule-update-files/CapsuleApp.efi
    Send File To DUT    ./dasharo-stability/capsule-update-files/CapsuleApp.efi    /capsule_testing/CapsuleApp.efi
    Log To Console    Sending ../edk2/${file_name}_max_fw_ver.cap
    Send File To DUT    ../edk2/${file_name}_max_fw_ver.cap    /capsule_testing/max_fw_ver.cap
    Log To Console    Sending ../edk2/${file_name}_wrong_cert.cap
    Send File To DUT    ../edk2/${file_name}_wrong_cert.cap    /capsule_testing/wrong_cert.cap
    Log To Console    Sending ../edk2/${file_name}_invalid_guid.cap
    Send File To DUT    ../edk2/${file_name}_invalid_guid.cap    /capsule_testing/invalid_guid.cap

    Execute Command In Terminal    sync

Start Update Process
    [Arguments]    ${capsule_file}
    Execute UEFI Shell Command    FS0:
    ${out}=    Execute UEFI Shell Command    cd capsule_testing
    Should Not Contain    ${out}    is not a directory.
    ${out}=    Execute UEFI Shell Command    CapsuleApp.efi ${capsule_file}
    Should Not Contain    ${out}    is not recognised
    Should Not Contain    ${out}    Command Error Status
    Should Not Contain    ${out}    is not a valid capsule.

Get File Name Without Extension
    [Arguments]    ${file_path}
    ${base_name}=    Split String    ${file_path}    /
    ${file_name}=    Get From List    ${base_name}    -1
    ${file_name}=    Split String    ${file_name}    .
    ${result}=    Get From List    ${file_name}    0
    RETURN    ${result}

Check If Capsule File Exists
    [Arguments]    ${file_path}
    ${file_exists}=    OperatingSystem.File Should Exist    ${file_path}
    IF    '${file_exists}' == 'False'
        Fail
        ...    File ${file_path} does not exist!/nTo create capsule files required for this test run: 'sudo bash
        ...    ./scripts/capsules/capsule_update_tests.sh <capsule_file>' and start the test again.
    END
