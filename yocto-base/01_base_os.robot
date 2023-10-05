*** Settings ***
Library             Collections
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../sonoff-rest-api/sonoff-api.robot
Resource            ../../rtectrl-rest-api/rtectrl.robot
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../lib/sd-wire.robot
Resource            ../lib/linux.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
Boot
    [Documentation]    This test aims to see whether the device can boot.
    Variable Should Exist    ${DUT_PASSWORD}
    Sonoff Power Off
    Sleep    5s
    Sonoff Power On
    Serial Root Login Linux    ${DUT_PASSWORD}
    ${output}=    Telnet.Execute Command    echo hi
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    hi
    IF    "${output}" != "hi"
        Fatal Error
    END

Utilities
    [Documentation]    checks whether tar, time and chronyc utilities exist.
    Get Utility Version    tar
    Get Utility Version    time
    Get Utility Version    chronyc

USB
    [Documentation]    check whether we can see a USB stick that's plugged in.
    ...    Also checks whether we mount/umount it and write/read.
    ${output}=    Telnet.Execute Command    lsblk | grep sda | wc -l
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    2
    Telnet.Execute Command    mount /dev/sda1 /mnt
    Telnet.Execute Command    echo hi > /mnt/something.txt
    Telnet.Execute Command    umount /dev/sda*
    Telnet.Execute Command    mount /dev/sda1 /mnt
    ${output}=    Telnet.Execute Command    cat /mnt/something.txt
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    hi
    Telnet.Execute Command    rm /mnt/something.txt
    Telnet.Execute Command    umount /dev/sda*

Ethernet
    [Documentation]    tests whether we have an internet connection
    ${output}=    Telnet.Execute Command    ping 8.8.8.8 -c 5 | grep -F " 0% packet loss" | wc -l
    ${output}=    Get Line    ${output}    0
    Should Be Equal As Strings    ${output}    1
