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
Resource            ../lib/netbootxyz-lib.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
UBOS001.001 Ubuntu 22.04 is installable
    [Documentation]    Try to install ubuntu via netboot.xyz with custom
    ...    preseed.
    Power On

    # Boot to netboot.xyz:
    # 1. Make sure Network stack is enabled
    Make Sure That Network Boot Is Enabled
    # 2. Boot to netboot.xyz
    Boot To Netboot.Xyz

    # Select ubuntu installation with preseed:
    # 1. Choose Linux Network installs
    Sleep    30s
    Press Key N Times And Enter    1    ${ARROW_DOWN}
    Sleep    10s
    # 2. Choose Ubuntu installation
    Press Key N Times And Enter    27    ${ARROW_DOWN}
    # 3. Chose Ubuntu 22.04:
    Press Key N Times And Enter    2    ${ARROW_DOWN}
    # 4. Choose Ubuntu installation with preseed
    Press Key N Times And Enter    2    ${ARROW_DOWN}

    # Type in HTTP server ip with preseed data:
    Write Into Terminal    http://${PRESEED_SERVER_IPADDRESS}
    Press Enter

    # Wait for Ubuntu to be installed:
    # 1. Increase timeout, installation can take a while
    Set DUT Response Timeout    120m
    # 2. Verify that Ubuntu has been installed
    Read From Terminal Until    ${UBUNTU_HOSTNAME} login:
