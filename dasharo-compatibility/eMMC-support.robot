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
MMC001.001 eMMC support (Ubuntu 22.04)
    [Documentation]    Check whether the eMMC driver is detected via the
    ...    Operating System.
    Skip If    not ${EMMC_SUPPORT}    MMC001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MMC001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    cat /sys/class/block/mmcblk0/device/name
    Should Contain    ${out}    ${E_MMC_NAME}
    Exit From Root User
