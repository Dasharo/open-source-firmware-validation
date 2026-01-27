*** Settings ***
Documentation       Library for using fwupdmgr

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Keywords ***
Fwupd Get Version Linux
    ${out}=    Execute Command In Terminal    fwupdmgr --version | grep org.freedesktop.fwupd-efi
    Log To Console    ${out}
