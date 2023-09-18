*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Variables ***
${golden_logo_sha256sum}    f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513


*** Test Cases ***
LCM001.001 Ability to replace logo in existing firmware image
    [Documentation]    Check whether the DUT is configured properly to use
    ...    a custom boot logo.
    Skip If    not ${custom_logo_support}    LCM001.001 not supported
    Skip If    not ${tests_in_firmware_support}    LCM001.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Launch to DTS Shell
    Download File    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download    /tmp/logo.bmp
    Replace logo in firmware    /tmp/logo.bmp
    Write Into Terminal    poweroff

LCM001.002 Check replaced logo in existing firmware image
    [Documentation]    Check if the custom logo is displayed
    Skip If    not ${custom_logo_support}    LCM001.002 not supported
    Skip If    not ${tests_in_firmware_support}    LCM001.002 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    Execute Command In Terminal    sha256sum /sys/firmware/acpi/bgrt/image
    Should Contain    ${out}    ${golden_logo_sha256sum}
