*** Settings ***
Library         Collections
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


*** Test Cases ***
Restore Disk Clonezilla
    ${clonezilla_tty}=    Get Envvar    CLONEZILLA_TTY    ${TRUE}
    Set Suite Variable    ${CLONEZILLA_TTY}    ${clonezilla_tty}

    ${source_image}=    Get Envvar    SOURCE_IMAGE
    Set Suite Variable    ${SOURCE_IMAGE}    ${source_image}

    ${target_disk}=    Get Envvar    TARGET_DISK
    Set Suite Variable    ${TARGET_DISK}    ${target_disk}

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
    IF    "${CLONEZILLA_TTY}" == "${EMPTY}"
        Write Bare Into Terminal    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${SOURCE_IMAGE}&disk=${TARGET_DISK}
    ELSE
        Write Bare Into Terminal
        ...    chain ${CLONEZILLA_IPXE_SERVER}/boot.ipxe?image=${SOURCE_IMAGE}&disk=${TARGET_DISK}&tty=${CLONEZILLA_TTY}
    END
    Press Enter

    ${msg}=    Catenate    \nThe test case ends now, but the disks are not restored yet.\n
    ...    The restoration will now begin.\n
    ...    After a successful restoration, the device will reboot.\n
    ...    You can monitor the progress on the video output,\n
    ...    or on the selected TTY, if it was provided (\${CLONEZILLA_TTY}=\"${CLONEZILLA_TTY}\")
    Log To Console    ${msg}

Manual Clonezilla
    ${clonezilla_tty}=    Get Envvar    CLONEZILLA_TTY    ${TRUE}
    Set Suite Variable    ${CLONEZILLA_TTY}    ${clonezilla_tty}

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

    IF    "${CLONEZILLA_TTY}" == "${EMPTY}"
        Write Bare Into Terminal    chain ${CLONEZILLA_IPXE_SERVER}/boot-manual.ipxe
    ELSE
        Write Bare Into Terminal    chain ${CLONEZILLA_IPXE_SERVER}/boot-manual.ipxe?tty=${CLONEZILLA_TTY}
    END
    Press Enter

    Log    Clonezilla booted in manual mode. Continue manually.    level=WARN
    Execute Manual Step    Clonezilla booted in manual mode. Continue manually.


*** Keywords ***
Get Envvar
    [Tags]    robot:private
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
