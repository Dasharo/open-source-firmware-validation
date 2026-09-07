*** Settings ***
Library             Collections
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../lib/sd-wire.robot
Resource            ../lib/linux.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
Y003.1 Platform boots
    [Documentation]    This test verifies booting of the device.
    Variable Should Exist    ${DUT_PASSWORD}
    Power Cycle On
    Serial Root Login Linux    ${DUT_PASSWORD}

Y003.2 Basic Packages are installed
    [Documentation]    checks whether tar, time and chronyc utilities exist.
    Get Utility Version    tar
    Get Utility Version    time
    Get Utility Version    chronyc

Y003.3 USB devices are visible
    [Documentation]    check whether we can see a USB stick that's plugged in.
    ...    Also checks whether we mount/umount it and write/read.
    ${partition}=    TelnetLibrary.Execute Command
    ...    dmesg | grep -F "USB Mass Storage device detected" --context=10 | grep 'sd[^[:space:]]' | tail -1 | awk '{gsub(/[\\[\\]]/, "", $5); print $5}'
    ${partition}=    Get Line    ${partition}    0
    TelnetLibrary.Execute Command    mount /dev/${partition}1 /mnt
    TelnetLibrary.Execute Command    echo hi > /mnt/something.txt
    TelnetLibrary.Execute Command    umount /dev/${partition}*
    TelnetLibrary.Execute Command    mount /dev/${partition}1 /mnt
    ${output}=    TelnetLibrary.Execute Command    cat /mnt/something.txt
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    hi
    TelnetLibrary.Execute Command    rm /mnt/something.txt
    TelnetLibrary.Execute Command    umount /dev/${partition}*

Y003.4 Ethernet connection is supported
    [Documentation]    tests whether we have an internet connection
    Check Internet Connection On Linux
