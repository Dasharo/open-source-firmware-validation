*** Settings ***
Library             Collections
Library             DateTime
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    '${ENV_ID_PFSENSE}' not in ${TESTED_LINUX_DISTROS}    pfSense tests not supported
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method

Default Tags        semiauto


*** Test Cases ***
PFS001.502 Install operating system on disk (pfSense)
    [Documentation]    Install pfSense LTS CE (serial output) from preseeded
    ...    USB stick on disk. Refer to test case PFS006.502 for preseed.
    ...
    ...    Previous IDs: PFS001.001
    Power On
    Boot PfSense Installer
    VAR    ${installer_message}=
    ...    Click OK, after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    ...    separator=${SPACE}
    Pause Execution    ${installer_message}

PFS002.502 Boot operating system from disk (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk.
    ...    This test depends on semi-manual OS installation, thus it's
    ...    marked as semiauto.
    ...
    ...    Previous IDs: PFS001.002
    Power On
    Boot PfSense

PFS003.502 Boot operating system from disk after cold-boot (pfSense)
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    ...    This test depends on semi-manual OS installation, thus it's
    ...    marked as semiauto.
    ...
    ...    Previous IDs: BPS001.001
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
    ...    This test depends on semi-manual OS installation, thus it's
    ...    marked as semiauto.
    ...
    ...    Previous IDs: BPS002.001
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
    ...    This test depends on semi-manual OS installation, thus it's
    ...    marked as semiauto.
    ...
    ...    Previous IDs: BPS003.001
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
    ...    This test depends on semi-manual OS installatio media preparation,
    ...    thus it's marked as semiauto.
    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    ${output}=    Execute Command In Terminal    ls
    Should Contain    ${output}    COPYRIGHT
    Should Contain    ${output}    .profile
