*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../variables.robot
Resource            ../lib/zarhus-lib.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Prepare Zarhus OS
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
Test Setup          Run Keyword If    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     Restore Initial DUT Connection Method


*** Test Cases ***
ZHS001.206 Make sure that cukinia tests pass
    Boot Zarhus OS
    Execute Command In Terminal With Sudo    cukinia

ZHS002.206 Make sure that update works
    [Documentation]    Make sure that update via `otab update` works, updates
    ...    inactive partition, reboots into updated slot and keeps booting into
    ...    it on next reboot
    Depends On    "otab" in ${ZARHUS_FEATURES}
    Depends On Variable    \${ZARHUS_SWU_FILE}
    OperatingSystem.File Should Exist    ${ZARHUS_SWU_FILE}
    Boot Zarhus OS
    FOR    ${index}    IN RANGE    4
        Send File To DUT    ${ZARHUS_SWU_FILE}    /tmp/zarhus.swu    switch_root=${FALSE}
        ${current_part}=    Execute Command In Terminal    fw_printenv otab_part_current
        IF    "=A" in "${current_part}"
            VAR    ${next_part}=    B
        ELSE
            VAR    ${next_part}=    A
        END

        # Create file to verify update will remove them
        Execute Command In Terminal With Sudo
        ...    mount /dev/disk/by-label/boot_${next_part.lower()} /mnt
        Execute Command In Terminal With Sudo    touch /mnt/test
        Execute Command In Terminal With Sudo    umount /mnt
        Execute Command In Terminal With Sudo
        ...    mount /dev/disk/by-label/rootfs_${next_part.lower()} /mnt
        Execute Command In Terminal With Sudo    touch /mnt/test
        Execute Command In Terminal With Sudo    umount /mnt

        # Start update
        Set DUT Response Timeout    5m
        Execute Command In Terminal With Sudo    otab update /tmp/zarhus.swu
        ...    wait_for_prompt=${FALSE}
        Read From Terminal Until    The system will reboot now!
        Set DUT Response Timeout    1m
        Login To Zarhus OS

        # Verify update succeeded and that files created earlier are no longer there
        ${current_part}=    Execute Command In Terminal    fw_printenv otab_part_current
        Should Contain    ${current_part}    \=${next_part}
        Execute Command In Terminal Should Succeed    test ! -f /test
        Execute Command In Terminal Should Succeed    test ! -f /boot/test
        Boot Zarhus OS
        # Make sure we still boot into updated slot after reboot
        ${current_part}=    Execute Command In Terminal    fw_printenv otab_part_current
        Should Contain    ${current_part}    \=${next_part}
    END

ZHS003.206 Make sure that failed update rollbacks to working slot
    [Documentation]    Make sure that if Zarhus OS doesn't boot after update
    ...    then on next reboot we go back to using working slot
    Depends On    "otab" in ${ZARHUS_FEATURES}
    Depends On Variable    \${ZARHUS_SWU_FILE}
    OperatingSystem.File Should Exist    ${ZARHUS_SWU_FILE}
    Boot Zarhus OS
    Send File To DUT    ${ZARHUS_SWU_FILE}    /tmp/zarhus.swu    switch_root=${FALSE}
    ${current_part}=    Execute Command In Terminal    fw_printenv otab_part_current
    # Start update
    Set DUT Response Timeout    5m
    Execute Command In Terminal With Sudo    otab update /tmp/zarhus.swu
    ...    wait_for_prompt=${FALSE}
    Read From Terminal Until    The system will reboot now!
    Set DUT Response Timeout    1m
    # First one is printed during reboot/shutdown when entering initramfs
    Read From Terminal Until    Starting systemd-udevd
    Read From Terminal Until    Starting systemd-udevd
    # Power On should reboot before we boot into OS and confirm that update worked
    Boot Zarhus OS
    ${current_part2}=    Execute Command In Terminal    fw_printenv otab_part_current
    Should Be Equal    ${current_part}    ${current_part2}

ZHS004.206 Make sure that rollback works
    [Documentation]    Make sure that `otab rollback` will result in booting
    ...    into inactive slot after reboot.
    Depends On    "otab" in ${ZARHUS_FEATURES}
    Boot Zarhus OS
    ${current_part}=    Execute Command In Terminal    fw_printenv otab_part_current
    ${out}=    Execute Command In Terminal With Sudo    otab rollback
    Should Contain    ${out}    Success
    Boot Zarhus OS
    ${current_part2}=    Execute Command In Terminal    fw_printenv otab_part_current
    Should Not Be Equal    ${current_part}    ${current_part2}
