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
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
# This must be in Test Setup, not Suite Setup, because of a known problem
# with QEMU: https://github.com/Dasharo/open-source-firmware-validation/issues/132
Test Setup          Run Keywords    Make Sure That Network Boot Is Enabled    AND    Restore Initial DUT Connection Method


*** Test Cases ***
DTS-2 NovaCustom Dasharo v1.7.2
    [Documentation]    This test aims to verify that Dasharo v1.7.2 on NV4x_PZ
    ...    eligible for updates to heads with heads DES and regular update
    ...    works as expected
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS005.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS005.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Write Into Terminal    9
    Read From Terminal Until Regexp    bash-\\d\\.\\d#

    # We have to do this so that dts-environment doesnt ruin our mock exports
    # I am putting this in a script to break up the command and escape
    # robotframeworks variable expansion. Unfortunately running this as one
    # command is impossible.
    # This could be removed once the new dts release contains this change
    # (PR for this is submitted already)
    Write Into Terminal    echo -n "#" > fix.sh
    Write Into Terminal    echo -n "!" >> fix.sh
    Write Into Terminal    echo -n "/" >> fix.sh
    Write Into Terminal    echo "bin/bash" >> fix.sh
    Write Into Terminal    echo -ne "sed -i 's/^\\\\([^=[:space:]]*\\\\)=\\\\(.*\\\\)$/\\\\1=\\\\" >> fix.sh
    Write Into Terminal    echo -n "$" >> fix.sh
    Write Into Terminal    echo -n "{" >> fix.sh
    Write Into Terminal    echo -ne "\\\\1:=\\\\2}/' /usr/sbin/dts-environment.sh" >> fix.sh
    Write Into Terminal    echo "" >> fix.sh
    Write Into Terminal    chmod 755 fix.sh
    Write Into Terminal    ./fix.sh
    ${out}=    Read From Terminal Until Regexp    bash-\\d\\.\\d#
    Log    ${out}

    ${out}=    Write Into Terminal    export BOARD_VENDOR="Notebook"
    ${out}=    Write Into Terminal    export SYSTEM_MODEL="NV4xPZ"
    ${out}=    Write Into Terminal    export BOARD_MODEL="NV4xPZ"
    ${out}=    Write Into Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2"
    ${out}=    Write Into Terminal    export TEST_DES=y
    ${out}=    Write Into Terminal    export BIOS_VENDOR="3mdeb"

    ${out}=    Write Into Terminal    echo $BIOS_VERSION
    ${out}=    Read From Terminal Until Regexp    bash-\\d\\.\\d#
    Log    ${out}

    ${out}=    Write Into Terminal    /usr/sbin/dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    5
    Log    ${out}

    ${out}=    Read From Terminal Until    Would you like to switch to Dasharo heads firmware? (Y|n)
    # test fails here, because it doesnt have the right cloud keys
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

    ${out}=    Read From Terminal Until    Press any key to continue
    Write Into Terminal    1
    Log    ${out}

