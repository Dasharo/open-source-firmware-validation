*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Test Cases ***
PFS002.001 pfSense stable (VGA output) installation on Hard Disk
    [Documentation]    Check whether pfSense stable with VGA output can be installed on the hard disk.
    [Tags]    semiauto
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Execute Manual Step    [1/5] Prepare a pfSense stable installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the pfSense installation medium
    Execute Manual Step    [3/5] Follow the pfSense installer steps to complete the installation on the hard disk
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm pfSense boots successfully from the hard disk via VGA output

PFS002.002 Boot pfSense stable (VGA output) from Hard Disk
    [Documentation]    Check whether pfSense stable with VGA output boots correctly from the hard disk.
    [Tags]    semiauto
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Execute Manual Step    [1/3] Power on the DUT with pfSense installed on the hard disk
    Execute Manual Step    [2/3] Wait for pfSense to boot
    Execute Manual Step    [3/3] Confirm pfSense boots to the console/login screen via VGA output

PFS001.502 Install operating system on disk (pfSense)
    [Documentation]    Install pfSense LTS CE (serial output) from preseeded
    ...    USB stick on disk. Refer to test case PFS006.502 for preseed.
    [Tags]    semiauto
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Power On
    Boot PfSense Installer
    VAR    ${installer_message}=
    ...    Click OK, after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    ...    separator=${SPACE}
    Pause Execution    ${installer_message}

PFS002.502 Boot operating system from disk (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk.
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Power On
    Boot PfSense

PFS003.502 Boot operating system from disk after cold-boot (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    VAR    @{supported_power_ctrls}=    RteCtrl    sonoff
    Skip If    '${POWER_CTRL}' not in ${supported_power_ctrls}
    Execute Cold Boot
    ${start_date}=    Get Current Date
    Boot PfSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

PFS004.502 Boot operating system from disk after warm-boot (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after warm-boot
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Power On
    Boot PfSense
    Enter PfSense Shell
    Write Into Terminal    poweroff
    Power On
    ${start_date}=    Get Current Date
    Boot PfSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Warm boot duration in seconds: ${delta_time}

PFS005.502 Boot operating system from disk after reboot (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after reboot
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Power On
    Boot PfSense
    Enter PfSense Shell
    Write Into Terminal    reboot
    ${start_date}=    Get Current Date
    Boot PfSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}

PFS006.502 Preseed operating system installer (pfSense)
    [Documentation]    Please use linux fatlabel program to rename ESP partition of
    ...    pfSense installer to PFEFI.
    ...    This test depends on semi-manual OS installatio media preparation,
    ...    thus it's marked as semiauto.
    [Tags]    semiauto
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    VAR    ${pfefi_message}=
    ...    Rename ESP partition of pfSense
    ...    serial installer to PFEFI.\nOn Linux: (sudo) fatlabel /dev/sdX1
    ...    PFEFI
    ...    separator=${SPACE}
    Execute Manual Step    ${pfefi_message}
    Execute Manual Step    Connect pfSense serial installer USB stick to DUT.

    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    VAR    ${awk_args}=
    ...    -v sq="'" -v dq='"'
    ...    -v ROOT_LABEL=PFBOOT '/^NEWFS_ESP=/ { print "NEWFS_ESP="
    ...    sq "newfs_msdos -L " ROOT_LABEL " " dq "%s" dq sq; next; };
    ...    { print; }'
    ...    separator=${SPACE}
    Execute Command In Terminal
    ...    awk ${awk_args} /usr/libexec/bsdinstall/zfsboot > /tmp/zfsboot
    Execute Command In Terminal    mount -u /
    Execute Command In Terminal    mv --force /tmp/zfsboot /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    chmod +x /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    sync
    ${output}=    Execute Command In Terminal    grep PFBOOT /usr/libexec/bsdinstall/zfsboot
    Should Contain    ${output}    PFBOOT

PFS007.502 Boot operating system installer into rescue shell (pfSense)
    [Documentation]    Boot installer into rescue shell.
    Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_BSD_DISTROS}
    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    ${output}=    Execute Command In Terminal    ls
    Should Contain    ${output}    COPYRIGHT
    Should Contain    ${output}    .profile
