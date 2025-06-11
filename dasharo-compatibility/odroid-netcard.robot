*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/performance/network.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
NETCARD001.201 Check Performance of 2.5G Wired Network Interface On Netcard (Ubuntu)
    [Documentation]    This test aims to verify the performance of Ethernet connection
    ...    on ODROID netcard
    Skip If    not ${ODROID_NETCARD_SUPPORT}    ODROID Netcard tests not supported

    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    Configure Network Interfaces For Testing    enp4s0    enp5s0
    Test Network Performance    2.35

    # Test second pair of network ports on netcard
    Configure Network Interfaces For Testing    enp6s0    enp7s0
    Test Network Performance    2.35
