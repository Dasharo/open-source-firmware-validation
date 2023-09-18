*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
FLB001.001 Firmware locally build (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether there is a possibility
    ...    to build firmware on the local machine, based on
    ...    `Build manual` procedure dedicated to the platform.
    Skip If    not ${firmware_building_support}    FLB001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    FLB001.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Install Docker Packages
    Build Firmware From Source

FLB002.001 Flash locally built firmware (Ubuntu 22.04)
    [Documentation]    This test aims to verify whether there is a possibility
    ...    to flash the locally built firmware to the DUT.
    Skip If    not ${firmware_building_support}    FLB002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    FLB002.001 not supported
    Power On
    Login to Linux
    Switch to root user
    Get flashrom from cloud
    Write Into Terminal    flashrom -p internal -w ../coreboot/build/coreboot.rom --ifd -i bios
    ${flash_result}=    Read From Terminal Until Prompt
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
