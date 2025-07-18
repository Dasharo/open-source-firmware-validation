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
# - Flash an image onto the device using ${RTE_IP}:
#    SOURCE_IMAGE=1_windows_ubuntu TARGET_DISK=nvme0n1 ./scripts/run.sh util/preseeds.robot -- -t "Restore Disk*"
# - Launch clonezilla in manual mode over chosen serial console:
#    CLONEZILLA_TTY=ttyUSB0 ./scripts/run.sh util/preseeds.robot -- -t "Manual Restore*"
# - Upload the disk image from the ${RTE_IP} device onto the disks NFS:
#    ./scripts/run.sh util/preseeds -- -t "Upload Disk*"
#    The image will be saved using the current date.
#    Change the name on the NFS after uploading to make it stand out more


*** Variables ***
${CLONEZILLA_IPXE_SERVER}=      http://192.168.10.217:8080
${DISKS_NFS_IP}=                192.168.10.217
${DISKS_NFS_PATH}=              /srv/nfs/disk-images


*** Test Cases ***
Upload Disk Clonezilla
    Power On
    Boot Clonezilla
    Configure Clonezilla
    Upload Disk

Restore Disk Clonezilla
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

    # Wait for the restoration to finish
    Set DUT Response Timeout    40m    # More time might be needed, 40m is a guess
    Enter Setup Menu Tianocore

Manual Restore Disk Clonezilla
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
    IF    not (${optional} and ${status})
        Log To Console    Environment variable ${name} must be set.
        Fail    Environment variable ${name} is not set
    ELSE IF    ${status}
        ${var}=    Get Environment Variable    ${name}
        RETURN    ${var}
    END
    RETURN    ${EMPTY}

Boot Clonezilla
    [Tags]    robot:private
    ${clonezilla_host}=    %{CLONEZILLA_HOST}
    ${ipxe_entered}=    Run Keyword And Return Status    Enter IPXE
    IF    not ${ipxe_entered}    # It might just be disabled
        Set UEFI Option    NetworkBoot    ${TRUE}
        Power On
        Enter IPXE
    END
    Execute Command In Terminal
    ...    dhcp
    ...    timeout=5m
    Write Bare Into Terminal    chain ${clonezilla_host}/boot.ipxe
    Press Enter

Configure Clonezilla
    [Tags]    robot:private
    # Keyboard layout prompt
    ${screen}=    Read From Terminal Until    Keyboard configuration
    # Select keep the default keyboard layout
    Log To Console    ${screen}
    Press Enter

    ${screen}=    Read From Terminal Until    Start Clonezilla
    Log To Console    ${screen}
    # Start clonezilla
    ${screen}=    Read From Terminal Until    <Cancel>
    Log To Console    ${screen}
    # Select Start Clonezilla
    Press Enter

    ${screen}=    Read From Terminal Until    Clonezilla - Opensource Clone System
    Log To Console    ${screen}
    ${screen}=    Read From Terminal Until    <Cancel>
    Log To Console    ${screen}
    # Select device-image work with disks or partitions using images
    Press Enter

    # remote target of images
    ${screen}=    Read From Terminal Until    Mount Clonezilla image directory
    Log To Console    ${screen}
    # Automatic NFS attaching doesn't work
    Read From Terminal Until    Enter command line prompt
    Log To Console    ${screen}
    Press Key N Times    4    ${ARROW_DOWN}
    Press Enter
    Read From Terminal Until    Press "Enter" to continue
    Log To Console    ${screen}
    Press Enter

    Set Prompt For Terminal    root@debian:~#
    Execute Command In Terminal    mount -t nfs ${DISKS_NFS_IP}:${DISKS_NFS_PATH} /home/partimag
    Execute Command In Terminal    ls /home/partimag
    Write Bare Into Terminal    exit
    Press Enter

    # Choose Beginner mode - no need for advanced options
    ${screen}=    Read From Terminal Until    Clonezilla - Opensource Clone System
    Log To Console    ${screen}
    ${screen}=    Read From Terminal Until    Beginner
    Log To Console    ${screen}
    Press Enter

Upload Disk
    [Tags]    robot:private
    # Choose to save the whole disk not single partitions
    ${screen}=    Read From Terminal Until    savedisk
    Log To Console    ${screen}
    Press Enter

    ${screen}=    Read From Terminal Until    Input a name for the saved image to use
    Log To Console    ${screen}
    # Accept default image name
    Press Enter

    ${screen}=    Read From Terminal Until    Choose local disk as source
    Log To Console    ${screen}
    # Choose the first disk
    Press Enter

    ${screen}=    Read From Terminal Until    Choose the compression option
    Log To Console    ${screen}
    # default
    Press Enter

    ${screen}=    Read From Terminal Until    Choose if you want to check and repair
    Log To Console    ${screen}
    # dont check filesystems
    Press Enter

    ${screen}=    Read From Terminal Until    do you want to check if the image is restorable
    Log To Console    ${screen}
    # dont perform checks
    Press Key N Times    1    ${ARROW_DOWN}
    Press Enter

    ${screen}=    Read From Terminal Until    Do you want to encrypt the image
    Log To Console    ${screen}
    # no encryption (default)
    Press Enter

    ${screen}=    Read From Terminal Until    do not copy log files
    Log To Console    ${screen}
    # do not save - the netbooted fs has no free space
    Press Key N Times    1    ${ARROW_DOWN}
    Press Enter

    ${screen}=    Read From Terminal Until    action to perform when everything is finished
    Log To Console    ${screen}
    ${screen}=    Read From Terminal Until    choose
    Log To Console    ${screen}
    # will show a prompt for what to do after it finishes, will allow robot to
    # detect if upload succeeded
    Press Enter

    ${screen}=    Read From Terminal Until    Press "Enter" to continue
    Log To Console    ${screen}
    Press Enter

    ${screen}=    Read From Terminal Until    Are you sure you want to continue
    Log To Console    ${screen}
    Write Bare Into Terminal    y
    Press Enter

    ${screen}=    Set Variable    ${EMPTY}
    Set DUT Response Timeout    30m
    WHILE    "Now you can choose to" not in """${screen}"""
        Log To Console    ${screen}
        Press Enter
        ${screen}=    Read From Terminal Until Regexp    (Press "Enter" to continue)|(Now you can choose to:)
    END

    # Power off
    Log To Console    ${screen}
    Press Key N Times    2    ${ARROW_UP}
    Press Enter
    Read From Terminal Until    Will poweroff
