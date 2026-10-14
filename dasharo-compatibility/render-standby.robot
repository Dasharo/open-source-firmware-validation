*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${RENDER_STANDBY_SUPPORT}    Render Standby not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
RSB001.201 Render Standby option is applied by firmware (Ubuntu)
    [Documentation]    Enable Render Standby and check in the coreboot log
    ...    that the value was passed to the FSP.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    RSB001.201 not supported

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    Set Render Standby Efivar    ${TRUE}

    Execute Reboot Command
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal    cbmem -1 | grep "IGD Render Standby"
    Should Contain    ${out}    IGD Render Standby: enabled

RSB002.201 Render Standby can be disabled (Ubuntu)
    [Documentation]    Check whether disabling RenderStandby EFI variable,
    ...    affects rc6 state in the OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    RSB002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Render Standby Efivar    ${FALSE}

    Execute Reboot Command
    Login To Linux
    Switch To Root User

    ${state}=    Get Render Standby State
    Should Be Equal    ${state}    ${FALSE}

RSB003.201 Render Standby can be enabled (Ubuntu)
    [Documentation]    Check whether enabling RenderStandby EFI variable,
    ...    affects rc6 state in the OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    RSB003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Set Render Standby Efivar    ${TRUE}

    Execute Reboot Command
    Login To Linux
    Switch To Root User

    ${state}=    Get Render Standby State
    Should Be Equal    ${state}    ${TRUE}


*** Keywords ***
Set Render Standby Efivar
    [Documentation]    Set Render Standby to enabled/disabled via Linux Shell
    [Arguments]    ${enabled}

    ${var_file_name}=    Execute Linux Command
    ...    ls /sys/firmware/efi/efivars -l | grep "RenderStandby" | awk '{print $NF}'
    Should Not Be Empty    ${var_file_name}    RenderStandby EFI variable not present in efivarfs
    VAR    ${var_file_path}=    /sys/firmware/efi/efivars/    ${var_file_name}    separator=${EMPTY}

    Execute Command In Terminal    chattr -i ${var_file_path}
    IF    ${enabled}
        VAR    ${byte}=    01
    ELSE
        VAR    ${byte}=    00
    END
    Execute Command In Terminal
    ...    printf '\\x07\\x00\\x00\\x00\\x${byte}' | tee ${var_file_path}

    ${out}=    Execute Linux Command
    ...    cat ${var_file_path} |tail -c 1 |xxd -ps
    IF    ${enabled}
        Should Be Equal As Strings    ${out}    01
    ELSE
        Should Be Equal As Strings    ${out}    00
    END

Get Render Standby State
    [Documentation]    Set Render Standby to enabled/disabled via Linux Shell
    ${out}=    Execute Command In Terminal
    ...    cat /sys/class/drm/card*/power/rc6_enable
    IF    '${out}' == '1'    RETURN    ${TRUE}    ELSE    RETURN    ${FALSE}
