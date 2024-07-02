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
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${ME_STATICALLY_DISABLED}    ME is not statically disabled for this platform
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
MES001.001 Check if ME is statically disabled
    [Documentation]    Check whether the Intel ME is disabled at build time.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE002.001 not supported
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Run Process    /usr/sbin/setpci    -s    16.0    40.L
    Should Not Be Equal As Strings    ${out.stdout}[3]    0
