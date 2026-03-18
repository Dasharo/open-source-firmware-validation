*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
PVE001.001 Proxmox Virtual Environment stable installation on Hard Disk
    [Documentation]    Check whether Proxmox VE stable can be installed on the hard disk of the DUT.
    Execute Manual Step    [1/5] Prepare a Proxmox VE stable installation medium (USB)
    Execute Manual Step    [2/5] Power on the DUT and boot from the Proxmox VE installation medium
    Execute Manual Step    [3/5] Follow the Proxmox VE installer steps to complete the installation on the hard disk
    Execute Manual Step    [4/5] Reboot after installation completes
    Execute Manual Step    [5/5] Confirm Proxmox VE boots successfully from the hard disk after installation

PVE001.002 Boot Proxmox Virtual Environment stable from Hard Disk
    [Documentation]    Check whether Proxmox VE stable boots correctly from the hard disk.
    Execute Manual Step    [1/3] Power on the DUT with Proxmox VE installed on the hard disk
    Execute Manual Step    [2/3] Wait for Proxmox VE to boot
    Execute Manual Step    [3/3] Confirm Proxmox VE boots to the login prompt or web interface successfully
