*** Settings ***
Library         DateTime
Library         Dialogs
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../lib/clonezilla.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
# Test suite used to quickly flash disk images with preinstalled OSes.
# An environment variables must be set prior to running it:
# Optional:
# - CLONEZILLA_TTY
# Example usage:
# - Launch clonezilla in manual mode over chosen serial console (for restore or upload):
#    CLONEZILLA_TTY=ttyUSB0 ./scripts/run.sh util/restore-disk-manual.robot


*** Test Cases ***
Restore Disk Manually Clonezilla
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
