*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...    Make Sure That Network Boot Is Enabled    AND
...    Restore Initial DUT Connection Method
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DTS-2 NovaCustom Dasharo v1.7.2
    [Documentation]    This test aims to verify that Dasharo v1.7.2 on NV4x_PZ
    ...    eligible for updates to heads with heads DES and regular update
    ...    works as expected
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS005.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS005.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    # ssh server has to be turned on, in order to be able to scp the scripts
    Write Into Terminal    8
    Read From Terminal Until    Enter an option:
    Write Into Terminal    9
    Set Prompt For Terminal    bash-5.1#
    Read From Terminal Until Prompt

    # Variable Should Exist    ${scripts}
    # example value of scripts variable (should be passed through command line
    # when running the test):
    ${scripts}=    Set Variable    /home/wgrzywacz/dts-scripts

    ${arguments}=    Create List    -o
    ...        StrictHostKeyChecking=no
    ...        -o
    ...        UserKnownHostsFile=/dev/null
    ...        -O
    ...        -P
    ...        5222
    ...        ${scripts}/unit-tests/dts-boot
    ...        ${scripts}/include/dts-functions.sh
    ...        ${scripts}/include/dts-environment.sh
    ...        ${scripts}/reports/dasharo-hcl-report
    ...        ${scripts}/reports/touchpad-info
    ...        ${scripts}/scripts/cloud_list
    ...        ${scripts}/scripts/dasharo-deploy
    ...        ${scripts}/scripts/dts
    ...        ${scripts}/scripts/ec_transition
    ...        ${scripts}/dts-profile.sh
    ...        root@127.0.0.1:/usr/sbin/
    ${output}=    Run Process    scp    @{arguments}    shell=True
    Log    ${output}

    ${out}=    Write Into Terminal    export BOARD_VENDOR="Notebook"
    ${out}=    Write Into Terminal    export SYSTEM_VENDOR="Notebook"
    ${out}=    Write Into Terminal    export SYSTEM_MODEL="NV4xPZ"
    ${out}=    Write Into Terminal    export BOARD_MODEL="NV4xPZ"
    ${out}=    Write Into Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2"
    ${out}=    Write Into Terminal    export TEST_DES=y
    ${out}=    Write Into Terminal    export BIOS_VENDOR="3mdeb"
    ${out}=    Write Into Terminal    export SE_credential_file="/cloud-pass"
    ${out}=    Write Into Terminal    export HAVE_EC="false"

    ${out}=    Write Into Terminal    /usr/sbin/dts-boot

    ${out}=    Read From Terminal Until    K to stop SSH server
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Would you like to switch to Dasharo heads firmware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Are you sure you want to proceed with update? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Does it match your actual specification? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Do you want to update Dasharo firmware on your hardware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Press enter to continue
    Write Into Terminal    1
    Log    ${out}

    ${out}=    Read From Terminal Until    Press ENTER to continue.
    Write Into Terminal    1
    Log    ${out}

