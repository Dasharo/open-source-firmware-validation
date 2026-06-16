*** Settings ***
Library         DateTime
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../lib/clonezilla.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
# Test suite used to quickly flash disk images with preinstalled OSes using Clonezilla.
# Two environment variables must be set prior to running it:
# - SOURCE_IMAGE
# - TARGET_DISK
# Optional:
# - CLONEZILLA_TTY
#
# Example usage:
# - Flash the `1_windows_ubuntu` image onto the `nvme0n1` disk on the device using ${RTE_IP}:
#    SOURCE_IMAGE=1_windows_ubuntu TARGET_DISK=nvme0n1 ./scripts/run.sh util/restore-disk-auto.robot
# - The same, but redirect the Clonezilla's output onto ttyS0 if video output is not available:
#    SOURCE_IMAGE=1_windows_ubuntu TARGET_DISK=nvme0n1 CLONEZILLA_TTY=ttyS0 ./scripts/run.sh util/restore-disk-auto.robot


*** Test Cases ***
Restore Disk Clonezilla
    ${clonezilla_tty}=    Get Envvar    CLONEZILLA_TTY    optional=${TRUE}
    ${source_image}=    Get Envvar    SOURCE_IMAGE
    ${target_disk}=    Get Envvar    TARGET_DISK

    Power On
    Enter IPXE
    Execute Command In Terminal
    ...    dhcp
    ...    timeout=5m
    IF    "${clonezilla_tty}" == "${EMPTY}"
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${source_image}&disk=${target_disk}
        ...    interval=0.5
        Press Enter
        VAR    ${msg}=    Disk cloning has started.
        ...    No tty was configured - running clonezilla on the device's display.
        ...    No serial logs will be collected, so the process must be monitored manually.
        ...    The test case will end now.
        Log    ${msg}    level=WARN
        Execute Manual Step    ${msg}
    END
    Write Bare Into Terminal
    ...    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${source_image}&disk=${target_disk}&tty=${clonezilla_tty}
    ...    interval=0.5
    Press Enter

    ${current_time}=    Get Current Date    result_format=epoch
    ${end_time}=    Add Time To Date    ${current_time}    ${TIME_LIMIT}    result_format=epoch
    WHILE    ${current_time} < ${end_time}
        ${out}=    Read From Terminal
        ${len}=    Get Length    ${out}
        IF    ${len} > 0    Log To Console    ${out}
        Sleep    1s

        ${rebooted}=    Run Keyword And Return Status    Should Contain    ${out}    ${TIANOCORE_STRING}
        IF    ${rebooted}    Pass Execution    Flashing finished.
    END
    VAR    ${msg}=    ${TIME_LIMIT} has passed and the device did not reboot.
    ...    Either flashing failed, wrong CLONEZILLA_TTY was given
    ...    (CLONEZILLA_TTY=${clonezilla_tty}), or it needs more time.
    ...    Verify manually.
    Fail    msg=${msg}
