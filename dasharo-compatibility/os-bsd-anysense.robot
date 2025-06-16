*** Settings ***
Library             Collections
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


*** Variables ***
${PFSENSE_PROMPT}=      [2.7.2-RELEASE][root@pfSense.home.arpa]/root


*** Test Cases ***
PFS001.502 Boot pfSense LTS CE (serial output) from disk after cold-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after cold-boot
    Power On
    # TBD

OPN001.503 Boot OPNsense (serial output) from disk after cold-boot
    [Documentation]    Boot OPNsense (serial output) from disk after cold-boot
    Power On
    Boot OPN
    # TBD

PFS002.502 Boot pfSense LTS CE (serial output) from disk after warm-boot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after warm-boot
    ...    does not use rtcwake!!!
    Power On
    Boot PfSense
    Enter Pf Sense Shell
    Write Into Terminal    poweroff
    Power On
    Boot PfSense

PFS003.502 Boot pfSense LTS CE (serial output) from disk after reboot
    [Documentation]    Boot pfSense LTS CE (serial output) from disk after reboot
    Power On
    Boot PfSense
    Enter Pf Sense Shell
    Write Into Terminal    reboot
    Boot PfSense

PFS004.502 Boot pfSense LTS CE (serial output) Installer into rescue shell
    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    ${output}=    Execute Command In Terminal    ls
    Should Contain    ${output}    COPYRIGHT
    Should Contain    ${output}    .profile

PFS005.502 Preseed pfSense Installer
    Power On
    Boot PfSense Installer
    Enter PfSense Rescue Shell
    Execute Command In Terminal
    ...    awk -v sq="'" -v dq='"' -v ROOT_LABEL=PFBOOT '/^NEWFS_ESP=/ { print "NEWFS_ESP=" sq "newfs_msdos -L " ROOT_LABEL " " dq "%s" dq sq; next; }; { print; }' /usr/libexec/bsdinstall/zfsboot > /tmp/zfsboot
    Execute Command In Terminal    mount -u /
    Execute Command In Terminal    mv /tmp/zfsboot /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    chmod +x /usr/libexec/bsdinstall/zfsboot
    Execute Command In Terminal    sync
    ${output}=    Execute Command In Terminal    grep PFBOOT /usr/libexec/bsdinstall/zfsboot
    Should Contain    ${output}    PFBOOT

# There's no OPN005.503, preseed requires another FreeBSD system

PFS006.502 Boot pfSense Installer
    Power On
    Boot PfSense Installer
    Execute Manual Step    Click OK to PASS, after test ends, connect to DUT via serial and continue.

OPN006.503 Boot OPNsense Installer
    Power On
    Boot OPNsense Installer
    Execute Manual Step    Click OK to PASS, after test ends, connect to DUT via serial and continue.


*** Keywords ***
Boot PfSense Installer
    [Documentation]    Run /EFI/BOOT/bootx64.efi file from PFEFI-labeled partition;
    ...    Select console type vt100 and accept the license
    Enter Boot From File
    Enter Volume In File Explorer    PFEFI
    Execute File In File Explorer    EFI
    Execute File In File Explorer    BOOT
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    Console type [vt100]:
    Write Into Terminal    vt100
    Read From Terminal Until    [Accept]
    Press Enter

Boot OPNsense Installer
    [Documentation]    Run /efi/boot/bootx64.efi file from OPNEFI-labeled partition;
    Enter Boot From File
    Enter Volume In File Explorer    OPNEFI
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    Read From Terminal Until    login:

Enter PfSense Shell
    Write Into Terminal    8
    Read From Terminal Until    ${PFSENSE_PROMPT}
    Set Prompt For Terminal    ${PFSENSE_PROMPT}

Enter PfSense Rescue Shell
    ${menu}=    Read From Terminal Until    <Cancel>
    # end would be 5 but it's 3 due to two empty lines
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    5    3
    Enter Submenu From Snapshot
    ...    ${construction}
    ...    Rescue Shell${SPACE_*_8}Launch a shell for rescue operations
    ...    "APP"
    Set Prompt For Terminal    \#

Enter OPN Sense Rescue Shell:
    Read From Terminal    FreeBSD/amd64 (OPNsense.localdomain) (ttyu0)
    Read From Terminal Until    login:
    Write Into Terminal    root
    Read From Terminal Until    Password:
    Write Into Terminal    opnsense
    Read From Terminal Until    Enter an option:
    Write Into Terminal    8

Boot PfSense
    [Documentation]    PFBOOT -> /efi/boot/bootx64.efi
    Enter Boot From File
    Enter Volume In File Explorer    PFBOOT
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
    Read From Terminal Until    Enter an option:

Boot OPN Sense
    Enter Boot From File
    Enter Volume In File Explorer    OPNBOOT
    Execute File In File Explorer    efi
    Execute File In File Explorer    boot
    Execute File In File Explorer    bootx64.efi
