*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
SAT001.001 SATA should be visible from OS
    [Documentation]    This test aims to verify that SATA is detected from OS
    ...    by using smartctl and hwinfo.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    SAT001.002 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SAT001.002 not supported

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    Detect Or Install Package    smartmontools
    Detect Or Install Package    hwinfo

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n

    Log    ${disks}

    ${do_we_have_sata}=    Set Variable    ${FALSE}

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${out}=    String.Replace String    ${out}    \n    ${SPACE}
        Log    ${out}
        ${does_it_contain_sata}=    Evaluate    "SATA Version is:" in "${out}"
        IF    ${does_it_contain_sata}==True
            Set Variable    ${do_we_have_sata}    ${TRUE}
        END
    END

    Should Be Equal    ${do_we_have_sata}    ${TRUE}

    ${out}=    Execute Command In Terminal    sudo hwinfo --disk
    Log    ${out}
    Should Contain    ${out}    SATA controller
