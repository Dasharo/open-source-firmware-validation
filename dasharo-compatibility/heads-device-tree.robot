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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${DEVICE_TREE_SUPPORT}    heads devicetree tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DVT001.001 Node with coreboot existst
    [Documentation]    Check whether the node with the coreboot exists in
    ...    Device Tree.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DVT001.001 not supported
    Power On
    Detect Heads Main Menu
    Enter Heads Recovery Shell
    ${coreboot_node}=    Execute Linux Command    xxd /sys/firmware/devicetree/base/firmware/coreboot/compatible
    Should Not Contain    ${coreboot_node}    No such file or directory

DVT002.001 Memory for coreboot is reserved
    [Documentation]    Check whether the memory for coreboot is reserved.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DVT002.001 not supported
    Power On
    Detect Heads Main Menu
    Enter Heads Recovery Shell
    ${coreboot_region}=    Execute Linux Command    xxd /sys/firmware/devicetree/base/firmware/coreboot/reg
    Should Not Contain    ${coreboot_region}    No such file or directory
    ${reserved_ranges}=    Execute Linux Command    xxd /sys/firmware/devicetree/base/reserved-memory/ranges
