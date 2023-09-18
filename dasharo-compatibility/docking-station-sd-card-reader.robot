*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DSD001.001 Docking Station SD Card reader detection (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    DSD001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSD001.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${disks}=    Identify Disks In Linux
    Should Match    str(${disks})    pattern=*SD*
    Exit From Root User

DSD001.002 Docking Station SD Card reader detection (Windows 11)
    [Documentation]    Check whether the SD Card reader is enumerated correctly
    ...    and can be detected from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    DSD001.001 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSD001.001 not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal
    ...    Get-PnpDevice -Status "OK" -Class "DiskDrive" | ForEach-Object { $_.FriendlyName }
    @{lines}=    Split To Lines    ${out}
    FOR    ${disk}    IN    @{lines}
        ${disk}=    Replace String Using Regexp    ${disk}    ${SPACE}+    ${SPACE}
        TRY
            Should Contain Any    ${disk}    ${DOCKING_STATION_MODEL_1}    ${DOCKING_STATION_MODEL_2}
        EXCEPT
            Log    ${disk} is not SD Card
        END
    END

DSD002.001 Docking Station SD Card read/write (Ubuntu 20.04)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    DSD002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DSD002.001 not supported
    Power On
    Login To Linux
    Switch To Root User
    ${path}=    Identify Path To SD Card In Linux
    FOR    ${disk}    IN    @{path}
        Check Read Write To External Drive In Linux    ${disk}
    END
    Exit From Root User

DSD002.002 Docking Station SD Card read/write (Windows 11)
    [Documentation]    Check whether the SD Card reader is initialized correctly
    ...    and can be used from the operating system.
    Skip If    not ${DOCKING_STATION_SD_CARD_READER_SUPPORT}    DSD002.001 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    DSD002.001 not supported
    Power On
    Login To Windows
    ${drive_letter}=    Identify Path To SD Card In Windows
    Check Read Write To External Drive In Windows    ${drive_letter}
