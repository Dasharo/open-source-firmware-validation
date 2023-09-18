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
Resource            ../keys-and-keywords/heads-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
DVT001.001 Node with coreboot existst
    [Documentation]    Check whether the node with the coreboot exists in
    ...    Device Tree.
    Skip If    not ${device_tree_support}    DVT001.001 not supported
    Skip If    not ${tests_in_firmware_support}    DVT001.001 not supported
    Power On
    Detect Heads Main Menu
    Enter Heads Recovery Shell
    ${coreboot_node}=    Execute Linux command    xxd /sys/firmware/devicetree/base/firmware/coreboot/compatible
    Should Not Contain    ${coreboot_node}    No such file or directory

DVT002.001 Memory for coreboot is reserved
    [Documentation]    Check whether the memory for coreboot is reserved.
    Skip If    not ${device_tree_support}    DVT002.001 not supported
    Skip If    not ${tests_in_firmware_support}    DVT002.001 not supported
    Power On
    Detect Heads Main Menu
    Enter Heads Recovery Shell
    ${coreboot_region}=    Execute Linux command    xxd /sys/firmware/devicetree/base/firmware/coreboot/reg
    Should Not Contain    ${coreboot_region}    No such file or directory
    ${reserved_ranges}=    Execute Linux command    xxd /sys/firmware/devicetree/base/reserved-memory/ranges
