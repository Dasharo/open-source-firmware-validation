*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
DSD001.001 Docking Station SD Card reader detection (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${docking_station_sd_card_reader_support}    DSD001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DSD001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${disks}=    Identify Disks in Linux
    Should Match    str(${disks})    pattern=*SD*
    Exit from root user

DSD001.002 Docking Station SD Card reader detection (Windows 11)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${docking_station_sd_card_reader_support}    DSD001.001 not supported
    Skip If    not ${tests_in_windows_support}    DSD001.001 not supported
    Power On
    Login to Windows
    ${out}=    Execute Command in Terminal
    ...    Get-PnpDevice -Status "OK" -Class "DiskDrive" | ForEach-Object { $_.FriendlyName }
    @{lines}=    Split To Lines    ${out}
    FOR    ${disk}    IN    @{lines}
        ${disk}=    Replace String Using Regexp    ${disk}    ${SPACE}+    ${SPACE}
        TRY
            Should Contain Any    ${disk}    ${docking_station_model_1}    ${docking_station_model_2}
        EXCEPT
            Log    ${disk} is not SD Card
        END
    END

DSD002.001 Docking Station SD Card read/write (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${docking_station_sd_card_reader_support}    DSD002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DSD002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    ${path}=    Identify Path To SD Card in linux
    FOR    ${disk}    IN    @{path}
        Check Read Write To External Drive in linux    ${disk}
    END
    Exit from root user

DSD002.002 Docking Station SD Card read/write (Windows 11)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${docking_station_sd_card_reader_support}    DSD002.001 not supported
    Skip If    not ${tests_in_windows_support}    DSD002.001 not supported
    Power On
    Login to Windows
    ${drive_letter}=    Identify Path To SD Card in Windows
    Check Read Write To External Drive in Windows    ${drive_letter}
