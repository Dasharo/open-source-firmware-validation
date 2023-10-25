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
NBT001.001 Netboot is available
    [Documentation]    Check whether netboot option exist, and if after
    ...    selection proper menu apperas.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT001.001 not supported
    Power On
    Set DUT Response Timeout    60s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    Set DUT Response Timeout    20s
    Read From Terminal Until    Network Boot and Utilities
    Read From Terminal Until    Please Select an Option

NBT002.001 OS selection & utilities is available
    [Documentation]    Check whether whether selection & utilities is available,
    ...    and if after selection proper menu apperas.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT002.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu In Tianocore    option=Network Boot and Utilities
    Enter Submenu In Tianocore    option=OS Selection & Utilities    checkpoint=Advanced    description_lines=2
    Set DUT Response Timeout    60s
    Read From Terminal Until    About netboot.xyz

NBT003.001 iPXE boot is available
    [Documentation]    Check whether iPXE boot is available, and if after
    ...    selection iPXE menu appears.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT003.001 not supported
    Power On
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Boot
    Set DUT Response Timeout    60s
    Set DUT Response Timeout    20s
    Read From Terminal Until    Nothing to boot: No such file or directory

NBT004.001 iPXE shell is available
    [Documentation]    Check whether iPXE shell is available, and if after
    ...    selection iPXE shell appears.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT004.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT004.001 not supported
    Power On
    Set DUT Response Timeout    60s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
    Set DUT Response Timeout    20s
    Read From Terminal Until    You are now in iPXE shell.

NBT005.001 iPXE shell works correctly
    [Documentation]    Check whether iPXE shell works correctly by configuring
    ...    network interface and booting to selected address.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT005.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT005.001 not supported
    Power On
    Set DUT Response Timeout    60s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    iPXE Shell
    Set Prompt For Terminal    iPXE>
    Read From Terminal Until Prompt
    Write Into Terminal    dhcp net0
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    ok
    Set DUT Response Timeout    60s
    Write Bare Into Terminal    chain http://192.168.20.206:8000/menu.ipxe\n    0.1
    # chain http://boot.3mdeb.com/dts.ipxe
    Read From Terminal Until    iPXE boot menu

NBT006.001 Advanced option is available
    [Documentation]    Check whether advanced option is available, and if after
    ...    selection proper menu apperas.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT006.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT006.001 not supported
    Power On
    Set DUT Response Timeout    60s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    Advanced
    Set DUT Response Timeout    20s
    Read From Terminal Until    Change Netboot iPXE Payload URL

NBT007.001 Change netboot URL option works correctly
    [Documentation]    Check whether it's possible to change netboot url, and
    ...    boot to it.
    Skip If    not ${NETBOOT_UTILITIES_SUPPORT}    NBT007.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    NBT007.001 not supported
    Power On
    Set DUT Response Timeout    60s
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    Network Boot and Utilities
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    Advanced
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2    checkpoint=Exit
    Enter Submenu From Snapshot    ${ipxe_menu}    Change Netboot iPXE Payload URL
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=3    checkpoint=Reset to Default
    Enter Submenu From Snapshot    ${ipxe_menu}    Change Netboot iPXE Payload URL
    Set DUT Response Timeout    20s
    Read From Terminal Until    Enter url parameters:
    FOR    ${i}    IN RANGE    100
        Write Bare Into Terminal    ${BACKSPACE}    0.1
    END
    Write Bare Into Terminal    http://boot.3mdeb.com/dts.ipxe    0.1
    Press Enter
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=3    checkpoint=Reset to Default
    Enter Submenu From Snapshot    ${ipxe_menu}    Apply and Exit
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2
    Enter Submenu From Snapshot    ${ipxe_menu}    Advanced
    ${ipxe_menu}=    Get IPXE Boot Menu Construction    lines_top=2    checkpoint=Exit
    Enter Submenu From Snapshot    ${ipxe_menu}    Change Netboot iPXE Payload URL
    ${out}=    Read From Terminal Until    Reset to Default
    Should Contain    ${out}    http://boot.3mdeb.com/dts.ipxe
