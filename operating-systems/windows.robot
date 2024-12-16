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
WIOS001.001 Windows 11 is installable
    [Documentation]    Try to install Windows 11 via netboot.xyz with custom
    ...    preseed.
    Power On

    # Boot to netboot.xyz:
    # 1. Make sure Network stack is enabled
    Make Sure That Network Boot Is Enabled
    # 2. Boot to netboot.xyz
    Boot To Netboot.Xyz

    # Install Windows:
    # 1. Select Windows installation:
    Sleep    30s
    Press Key N Times And Enter    3    ${ARROW_DOWN}
    Sleep    10s
    # 2. Type in base URL with preseed data:
    Press Key N Times And Enter    2    ${ARROW_DOWN}
    Write Into Terminal    http://${PRESEED_SERVER_IPADDRESS}/windows-pe
    Press Enter
    Sleep    2s
    Press Enter
    # 3. Load Windows Installer:
    Press Enter
    # From this point, a custom setup image is bein launched. There is no
    # communication with the image, because Windows Desktop does not provide
    # either serial or SSH output during installation. A user has to check
    # Windows IP after the installation is complete and only then connect.
