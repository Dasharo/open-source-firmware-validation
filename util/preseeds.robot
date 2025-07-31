*** Settings ***
Library         Collections
Library         DateTime
Library         Dialogs
Library         OperatingSystem
Library         Process
Library         String
Library         Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library         SSHLibrary    timeout=90 seconds
Library         RequestsLibrary
# Library    ../osfv-scripts/osfv_cli/src/osfv/rf/rte_robot.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot
Resource        ../keys-and-keywords/ubuntu-keywords.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
# Test suite used to quickly flash disk images with preinstalled OSes.
# Two environment variables must be set prior to running it:
# - SOURCE_IMAGE
# - TARGET_DISK
# Optional:
# - CLONEZILLA_TTY
#
# Example usage:
# - Flash the `1_windows_ubuntu` image onto the `nvme0n1` disk on the device using ${RTE_IP}:
#    SOURCE_IMAGE=1_windows_ubuntu TARGET_DISK=nvme0n1 ./scripts/run.sh util/preseeds.robot -- -t "Restore Disk*"
# - The same, but redirect the Clonezilla's output onto ttyS0 if video output is not available:
#    SOURCE_IMAGE=1_windows_ubuntu TARGET_DISK=nvme0n1 CLONEZILLA_TTY=ttyS0 ./scripts/run.sh util/preseeds.robot -- -t "Restore Disk*"
# - Launch clonezilla in manual mode over chosen serial console (for restore or upload):
#    CLONEZILLA_TTY=ttyUSB0 ./scripts/run.sh util/preseeds.robot -- -t "Manual*"
#
#    Important: Don't run the whole test suite. Every test case is a
#    separate functionality and running them all after each other does not
#    make much sense, unless you know what you are doing.


*** Variables ***
${CLONEZILLA_IPXE_SERVER}=      http://192.168.10.217:8080
${DISKS_NFS_IP}=                192.168.10.217
${DISKS_NFS_PATH}=              /srv/nfs/disk-images
${TIME_LIMIT}=                  40m


*** Test Cases ***
Restore Disk Clonezilla
    ${clonezilla_tty}=    Get Envvar    CLONEZILLA_TTY    ${TRUE}
    ${source_image}=    Get Envvar    SOURCE_IMAGE
    ${target_disk}=    Get Envvar    TARGET_DISK

    Power On
    ${ipxe_entered}=    Run Keyword And Return Status    Enter IPXE
    IF    not ${ipxe_entered}    # It might just be disabled
        Set UEFI Option    NetworkBoot    ${TRUE}
        Power On
        Enter IPXE
    END
    Execute Command In Terminal
    ...    dhcp
    ...    timeout=5m
    IF    "${clonezilla_tty}" == "${EMPTY}"
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${source_image}&disk=${target_disk}
        ...    interval=0.5
    ELSE
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${source_image}&disk=${target_disk}&tty=${clonezilla_tty}
        ...    interval=0.5
    END
    Press Enter

    ${current_time}=    Get Current Date    result_format=epoch
    ${end_time}=    Add Time To Date    ${current_time}    ${TIME_LIMIT}    result_format=epoch
    WHILE    ${current_time} < ${end_time}
        ${out}=    Read From Terminal
        ${len}=    Get Length    ${out}
        IF    ${len} > 0    Log To Console    ${out}
        Sleep    1s
        # Platform rebooted
        IF    '${TIANOCORE_STRING}' in '''${out}'''
            Pass Execution    Flashing finished.
        END
    END
    VAR    ${msg}=    ${TIME_LIMIT} has passed and the device did not reboot.
    ...    Either flashing failed, wrong CLONEZILLA_TTY was given
    ...    (CLONEZILLA_TTY=${clonezilla_tty}), or it needs more time.
    ...    Verify manually.
    Fail    msg=${msg}

Manual Clonezilla
    ${clonezilla_tty}=    Get Envvar    CLONEZILLA_TTY    ${TRUE}

    Power On
    ${ipxe_entered}=    Run Keyword And Return Status    Enter IPXE
    IF    not ${ipxe_entered}    # It might just be disabled
        Set UEFI Option    NetworkBoot    ${TRUE}
        Power On
        Enter IPXE
    END
    Execute Command In Terminal
    ...    dhcp
    ...    timeout=5m

    IF    "${clonezilla_tty}" == "${EMPTY}"
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot-manual.ipxe
        ...    interval=0.5
    ELSE
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot-manual.ipxe?tty=${clonezilla_tty}
        ...    interval=0.5
    END
    Press Enter

    Log    Clonezilla booted in manual mode. Continue manually.    level=WARN
    Execute Manual Step    Clonezilla booted in manual mode. Continue manually.


*** Keywords ***
Get Envvar
    [Arguments]    ${name}    ${optional}=${FALSE}
    ${status}=    Run Keyword And Return Status    Get Environment Variable    ${name}
    IF    not (${optional} or ${status})
        Log To Console    Environment variable ${name} must be set.
        Fail    Environment variable ${name} is not set
    ELSE IF    ${status}
        ${var}=    Get Environment Variable    ${name}
        RETURN    ${var}
    END
    RETURN    ${EMPTY}
