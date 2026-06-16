*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=9000 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${EXTRA_1_TB_DISK}    1TB burner disk needed
Suite Teardown      Run Keywords
...                     Kill DD Process If Running
...                     AND
...                     Unmount USB Device
...                     AND
...                     Log Out And Close Connection


*** Variables ***
${USB_MOUNT_POINT}=     /mnt/usb_test


*** Test Cases ***
UTS001.201 USB Stability Under 400GB Transfer (Ubuntu)
    [Documentation]    Verify the system remains stable and responsive while copying ~200GB
    ...    of data from a USB device to the Ubuntu system. This test is focused on detecting freezes or system hangs.
    [Tags]    semiauto
    Depends On    ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UTS001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Manual Step
    ...    DUT must have at least 400 GB free on the OS partition and a second disk (≥400 GB) connected via USB
    ${usb_mount}=    Mount USB Device If Needed
    Log To Console    Creating 400GB of test data on USB (single large file)...
    VAR    ${usb_file_path}=    ${usb_mount}/single_large_file.bin
    Execute Linux Command    dd if=/dev/zero of=${usb_file_path} count=819200000 status=progress    15000

    Sleep    3s
    Log To Console    Starting stability test: copying ~400GB of data from USB to DUT...
    VAR    ${dut_file_path}=    /tmp/stability_copy.bin
    Execute Linux Command    dd if=${usb_file_path} of=${dut_file_path} status=progress    15000

    Log To Console    Verifying copied data exists and size matches...
    ${usb_size}=    Execute Linux Command    stat -c %s ${usb_file_path}
    ${dut_size}=    Execute Linux Command    stat -c %s ${dut_file_path}
    Should Be Equal As Integers    ${usb_size}    ${dut_size}    Copied file size does not match original.

    Execute Linux Command    rm -f ${dut_file_path}
    Exit From Root User


*** Keywords ***
Mount USB Device If Needed
    [Documentation]    Mounts the USB device to the globally defined mount point.
    ${device}=    Identify USB Device Path
    VAR    ${partition}=    ${device}1
    Execute Linux Command    mkdir -p ${USB_MOUNT_POINT}
    Execute Linux Command    mount ${partition} ${USB_MOUNT_POINT}
    RETURN    ${USB_MOUNT_POINT}

Identify USB Device Path
    [Documentation]    Detect the most recently connected USB storage device.
    ${usb_disks}=    Execute Linux Command    lsblk -rpno NAME,TYPE,TRAN | grep 'disk usb' | awk '{print $1}'
    Should Not Be Empty    ${usb_disks}    No USB disks detected
    @{usb_disks}=    Split To Lines    ${usb_disks}

    VAR    ${selected_disk}=    NONE
    FOR    ${disk}    IN    @{usb_disks}
        ${partitions}=    Execute Linux Command    lsblk -nr ${disk} | grep part | awk '{print $1}'
        IF    '${partitions}' != ''
            VAR    ${selected_disk}=    ${disk}
        END
        IF    '${selected_disk}' != 'NONE'    BREAK
    END

    IF    '${selected_disk}' == 'NONE'
        Fail    No USB disk with partition found
    END
    RETURN    ${selected_disk}

Kill DD Process If Running
    [Documentation]    Checks for a running 'dd if=/dev/zero' process and kills it if found.
    Log To Console    Checking for any running 'dd if=/dev/zero' processes...
    ${pid_output}=    Execute Linux Command
    ...    ps aux | grep '[d]d if=/dev/zero'
    ${pids}=    Get Regexp Matches    ${pid_output}    ^\s*\S+\s+(\d+)    1

    IF    ${pids} != []
        Log To Console    Found 'dd if=/dev/zero' processes with PIDs: ${pids}
        FOR    ${pid}    IN    @{pids}
            Log To Console    Attempting to kill process with PID: ${pid}
            Execute Linux Command    kill -9 ${pid}
            Log To Console    Kill command sent for PID: ${pid}.
        END
    ELSE
        Log To Console    No 'dd if=/dev/zero' processes found.
    END

Unmount USB Device
    [Documentation]    Unmounts the globally defined USB mount point if it's mounted, and cleans up the mount directory.
    Log To Console    Attempting to unmount and clean ${USB_MOUNT_POINT}
    ${is_mounted}=    Run Keyword And Return Status    Execute Linux Command    mountpoint -q ${USB_MOUNT_POINT}
    IF    ${is_mounted}
        Log To Console    ${USB_MOUNT_POINT} is currently mounted. Unmounting...
        Execute Linux Command    umount ${USB_MOUNT_POINT}
        Log To Console    Umount command sent for ${USB_MOUNT_POINT}.
    ELSE
        Log To Console    ${USB_MOUNT_POINT} is not mounted. No unmount action needed.
    END
    Execute Linux Command    rm -rf ${USB_MOUNT_POINT}
    Log To Console    Remove mount point directory command sent for ${USB_MOUNT_POINT}.
