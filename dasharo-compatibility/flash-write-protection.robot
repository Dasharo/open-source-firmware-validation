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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${HARDWARE_WP_SUPPORT}    Flash protection tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
HWP001.001 Hardware flash write protection support
    [Documentation]    Check whether the DUT support hardware write protection
    ...    mechanism.
    Power On
    Boot From USB
    Serial Root Login Linux    debian
    Check Write Protection Availability

HWP002.001 Hardware flash write protection enable / disable
    [Documentation]    Check whether there is a possibility to set and erase
    ...    hardware write protection on the DUT.
    Power On
    Boot From USB
    Serial Root Login Linux    debian
    Erase Write Protection
    Set Write Protection    0x00000000    ${FLASH_LENGTH}
    Check Write Protection Status
    Compare Write Protection Ranges    0x00000000    ${FLASH_LENGTH}
