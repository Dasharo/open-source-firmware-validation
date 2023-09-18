*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
LBT001.001 Debian stable installation on USB storage
    [Documentation]    Check whether Debian could be installed on USB storage
    ...    via iPXE.
    Skip If    not ${install_debian_usb_support}    LBT001.001 not supported
    Skip If    not ${tests_in_firmware_support}    LBT001.001 not supported
    Set Suite Variable    ${preseed}    preseed_debian_kgpe.cfg.usb
    Set Suite Variable    ${inter}    ens9
    Set Suite Variable    ${prev_test_status}    PASS
    Power On
    Enter iPXE
    Wait Until Keyword Succeeds    3x    2s    iPXE dhcp
    Telnet.Set Timeout    60
    # iPXE has a line length limit, so we need to use a variable
    Telnet.Write Bare
    ...    set kflags console=ttyS0,115200 earlyprint=serial,ttyS0,115200 auto=true hw-detect/load_firmware=false locale=en_US interface=${inter} hostname=debian domain=test url=http://${pxe_ip}:${http_port}/${preseed}\n
    ...    0.1
    Telnet.Write Bare
    ...    kernel http://ftp.nl.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux --- \${kflags}\n
    ...    0.1
    Telnet.Read Until    ok
    Telnet.Write Bare
    ...    initrd http://ftp.nl.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz\n
    ...    0.1
    Telnet.Read Until    ok
    Telnet.Write Bare    boot\n    0.1
    Log To Console    \n--- Setting up network connection ---\n
    Telnet.Set Timeout    120 s
    Telnet.Read Until    Network autoconfiguration has succeeded
    Log To Console    \n--- Partitioner ---\n
    Telnet.Set Timeout    5 min
    Telnet.Read Until    Starting up the partitioner
    Telnet.Read Until    Installing the base system
    Log To Console    \n--- Installing base system ---\n
    Telnet.Set Timeout    90 min
    Telnet.Read Until    Select and install software
    Log To Console    \n--- Installing software ---\n
    Telnet.Read Until    Installing GRUB boot loader
    Log To Console    \n--- Installing GRUB boot loader ---\n
    Telnet.Set Timeout    15 min
    Telnet.Read Until    Finishing the installation
    Telnet.Read Until    Sent SIGKILL to all processes
    [Teardown]    Run Keyword If Test Failed    Set Suite Variable    ${prev_test_status}    FAIL

LBT001.002 Boot Debian from USB
    [Documentation]    Check whether the DUT boots properly into Debian
    ...    installed on USB stick.
    Skip If    not ${install_debian_usb_support}    LBT001.002 not supported
    Skip If    not ${tests_in_firmware_support}    LBT001.002 not supported
    IF    '${prev_test_status}'=='FAIL'    FAIL    Install Debian FAILED
    Power On
    Boot from USB
    Serial root login Linux    debian

LBT002.001 Ubuntu LTS installation on USB storage
    [Documentation]    Check whether Ubuntu could be installed on USB storage
    ...    via iPXE.
    Skip If    not ${install_ubuntu_usb_support}    LBT002.001 not supported
    Skip If    not ${tests_in_firmware_support}    LBT002.001 not supported
    Set Suite Variable    ${preseed}    preseed_ubuntu_kgpe.cfg
    Set Suite Variable    ${inter}    ens9
    Set Suite Variable    ${prev_test_status}    PASS
    Power On
    Enter iPXE
    Wait Until Keyword Succeeds    3x    2s    iPXE dhcp
    Telnet.Set Timeout    60
    # iPXE has a line length limit, so we need to use a variable
    Telnet.Write Bare
    ...    set kflags console=ttyS0,115200 earlyprint=serial,ttyS0,115200 auto=true hw-detect/load_firmware=false locale=en_US interface=${inter} hostname=ubuntu domain=test url=http://${pxe_ip}:${http_port}/${preseed}\n
    ...    0.1
    Telnet.Write Bare
    ...    kernel http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/hwe-netboot/ubuntu-installer/amd64/linux --- \${kflags}\n
    ...    0.1
    Telnet.Read Until    ok
    Telnet.Write Bare
    ...    initrd http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/hwe-netboot/ubuntu-installer/amd64/initrd.gz\n
    ...    0.1
    Telnet.Read Until    ok
    Telnet.Write Bare    boot\n    0.1
    Log To Console    \n--- Setting up network connection ---\n
    Telnet.Set Timeout    120 s
    Telnet.Read Until    Network autoconfiguration has succeeded
    Log To Console    \n--- Partitioner ---\n
    Telnet.Set Timeout    10 min
    Telnet.Read Until    Starting up the partitioner
    Telnet.Read Until    Installing the base system
    Log To Console    \n--- Installing base system ---\n
    Telnet.Set Timeout    120 min
    Telnet.Read Until    Select and install software
    Log To Console    \n--- Installing software ---\n
    Telnet.Read Until    Installing GRUB boot loader
    Log To Console    \n--- Installing GRUB boot loader ---\n
    Telnet.Set Timeout    15 min
    Telnet.Read Until    Finishing the installation
    Telnet.Read Until    Sent SIGKILL to all processes
    [Teardown]    Run Keyword If Test Failed    Set Suite Variable    ${prev_test_status}    FAIL

LBT002.002 Boot Ubuntu from USB
    [Documentation]    Check whether the DUT boots properly into Ubuntu
    ...    installed on USB stick.
    Skip If    not ${install_ubuntu_usb_support}    LBT002.002 not supported
    Skip If    not ${tests_in_firmware_support}    LBT002.002 not supported
    IF    '${prev_test_status}'=='FAIL'    FAIL    Install Ubuntu LTS FAILED
    Power On
    Boot from USB
    Serial root login Linux    ubuntu
