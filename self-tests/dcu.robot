*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             FakerLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
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
Boot System Or From Connected Disk
    Skip If    '${OPTIONS_LIB}' != 'dcu'    DCU not supported

    Power On

    Dcu.Boot System Or From Connected Disk    ${OS_WINDOWS}
    Dcu.Login To Windows Via SSH    ${DEVICE_WINDOWS_USERNAME}    ${DEVICE_WINDOWS_PASSWORD}

    Power On
    Dcu.Boot System Or From Connected Disk    ${OS_UBUNTU}

    Login To Linux
    Switch To Root User
