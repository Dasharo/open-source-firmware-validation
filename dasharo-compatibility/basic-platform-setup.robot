*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
BPS001.001 Power Control - Power On and Serial output
    [Documentation]    Verifies if the DUT can be turned On and if the serial output can be read.
    Power On
    Sleep    60s
    ${out}=    Read From Terminal
    Should Not Be Empty    ${out}

BPS001.002 Power Control - Power Off
    [Documentation]    This test verifies if the DUT can be powered down.
    Power On
    Sleep    60s
    ${out}=    Read From Terminal
    Should Not Be Empty    ${out}
    Power Cycle Off
    Sleep    30s
    ${out}=    Read From Terminal
    Should Be Empty    ${out}

BPS002.001 Boot to OS - Ubuntu
    [Documentation]    This test verifies if platform can be booted to Ubunto and if correct credentials are set.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

BPS002.002 Boot to OS - Windows
    [Documentation]    This test verifies if platform can be booted to Windows, if SSH server is enabled and if correct credentials are set.
    Power On
    Login To Windows

BPS003.001 External flashing
    [Documentation]    This test verifies if flashrom can detect the die.
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Flashrom From Cloud
    ${out_flashrom}=    Execute Command In Terminal    flashrom -p internal
    Should Contain    ${out_flashrom}    Found chipset
