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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
NET003.001 Net controller after reboot (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    Skip If    not ${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}    NET001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    FOR    ${ind}    IN RANGE    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp'
        Should Contain    ${network_status}    UP
    END

NET004.001 NET controller after suspend (Ubuntu 22.04)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    Skip If    not ${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}    NET001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Perform Suspend Test Using FWTS
    ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp'
    Should Contain    ${network_status}    UP
