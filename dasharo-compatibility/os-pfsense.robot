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
Suite Teardown      Run Keywords
...                     Log Out And Close Connection
Test Setup          Run Keyword
...                     Restore Initial DUT Connection Method


*** Test Cases ***
PFS001.502 Install pfSense LTS CE (serial output) on disk
    [Documentation]    Install pfSense LTS CE (serial output) from preseeded
    ...    USB stick on disk. Refer to test case PFS006.502 for preseed.
    Power On
    Boot PfSense Installer
    ${installer_message}=    Catenate    Click OK, after test execution ends,
    ...    connect to DUT via serial and continue manual installation.
    Pause Execution    ${installer_message}

PFS002.502 Boot pfSense LTS CE (serial output) from disk
    [Documentation]    Boot pfSense LTS CE (serial output) from disk.
    Power On
    Boot PfSense

PFS003.502 Boot pfSense LTS CE (serial output) from disk after cold-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    @{supported_power_ctrls}=    Create List    RteCtrl    sonoff
    Skip If    '${POWER_CTRL}' not in ${supported_power_ctrls}
    Power On
    Set UEFI Option    PowerStateAfterPowerAcLoss    Powered On
    Sleep    2
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu Off
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff Off
    END
    Sleep    12
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu On
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff On
    END
    ${start_date}=    Get Current Date
    Boot PfSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Cold boot duration in seconds: ${delta_time}

PFS004.502 Boot pfSense LTS CE (serial output) from disk after warm-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after warm-boot
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

PFS005.502 Boot pfSense LTS CE (serial output) from disk after reboot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after reboot
    Power On
    Boot PfSense
    Enter PfSense Shell
    Write Into Terminal    reboot
    ${start_date}=    Get Current Date
    Boot PfSense
    ${end_date}=    Get Current Date
    ${delta_time}=    Subtract Date From Date    ${end_date}    ${start_date}
    Log To Console    Reboot duration in seconds: ${delta_time}

PFS006.502 Preseed pfSense Installer
    [Documentation]    Please use linux fatlabel program to rename ESP partition of
    ...    pfSense installer to PFEFI.
    ${pfefi_message}=    Catenate    SEPARATOR=${SPACE}    Rename ESP partition of pfSense
    ...    serial installer to PFEFI.\nOn Linux: (sudo) fatlabel /dev/sdX1    PFEFI
    Execute Manual Step    ${pfefi_message}
    Execute Manual Step    Connect pfSense serial installer USB stick to DUT.

    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    ${awk_args}=    Catenate    SEPARATOR=${SPACE}    -v sq="'" -v dq='"'
    ...    -v ROOT_LABEL=PFBOOT '/^NEWFS_ESP=/ { print "NEWFS_ESP="
    ...    sq "newfs_msdos -L " ROOT_LABEL " " dq "%s" dq sq; next; };
    ...    { print; }'
    Execute Command In Terminal
    ...    awk ${awk_args} /usr/libexec/bsdinstall/zfsboot > /tmp/zfsboot
    Execute Command In Terminal    mount -u /
    Execute Command In Terminal    mv /tmp/zfsboot /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    chmod +x /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    sync
    ${output}=    Execute Command In Terminal    grep PFBOOT /usr/libexec/bsdinstall/zfsboot
    Should Contain    ${output}    PFBOOT

PFS007.502 Boot pfSense LTS CE (serial output) Installer into rescue shell
    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    ${output}=    Execute Command In Terminal    ls
    Should Contain    ${output}    COPYRIGHT
    Should Contain    ${output}    .profile
