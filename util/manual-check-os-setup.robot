*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# Library    ../osfv-scripts/osfv_cli/src/osfv/rf/rte_robot.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/ubuntu-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
OSS001.201 Boot to OS (Ubuntu)
    [Documentation]    This test verifies if platform with non-Dasharo firmware
    ...    can be booted to Ubuntu and if correct credentials are set.
    Power On
    Execute Manual Step    Boot to Ubuntu
    Login To Linux
    Switch To Root User

OSS001.301 Boot to OS (Windows 11)
    [Documentation]    This test verifies if platform with non-Dasharo firmware
    ...    can be booted to Windows, if SSH server is enabled and if correct
    ...    credentials are set.
    Power On
    Execute Manual Step    Boot to Windows
    Login To Windows Via SSH
