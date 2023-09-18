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
NBT001.001 Netboot is available
    [Documentation]    Check whether netboot option exist, and if after
    ...    selection proper menu apperas.
    Skip If    not ${netboot_utilities_support}    NBT001.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT001.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Set DUT Response Timeout    20s
    Read From Terminal Until    Network Boot and Utilities
    Read From Terminal Until    Please Select an Option

NBT002.001 OS selection & utilities is available
    [Documentation]    Check whether wether selection & utilities is available,
    ...    and if after selection proper menu apperas.
    Skip If    not ${netboot_utilities_support}    NBT002.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT002.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=OS Selection & Utilities    checkpoint=Advanced    description_lines=2
    Set DUT Response Timeout    20s
    Read From Terminal Until    Press any key to continue to netboot.xyz

NBT003.001 iPXE boot is available
    [Documentation]    Check whether iPXE boot is available, and if after
    ...    selection iPXE menu appears.
    Skip If    not ${netboot_utilities_support}    NBT003.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT003.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=iPXE Boot    checkpoint=Advanced    description_lines=2
    Set DUT Response Timeout    20s
    Read From Terminal Until    Nothing to boot: No such file or directory

NBT004.001 iPXE shell is available
    [Documentation]    Check whether iPXE shell is available, and if after
    ...    selection iPXE shell appears.
    Skip If    not ${netboot_utilities_support}    NBT004.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT004.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=iPXE Shell    checkpoint=Advanced    description_lines=2
    Set DUT Response Timeout    20s
    Read From Terminal Until    You are now in iPXE shell.

NBT005.001 iPXE shell works correctly
    [Documentation]    Check whether iPXE shell works correctly by configuring
    ...    network interface and booting to selected adress.
    Skip If    not ${netboot_utilities_support}    NBT005.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT005.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=iPXE Shell    checkpoint=Advanced    description_lines=2
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
    Skip If    not ${netboot_utilities_support}    NBT006.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT006.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=Advanced    checkpoint=Advanced    description_lines=2
    Set DUT Response Timeout    20s
    Read From Terminal Until    Change Netboot iPXE Payload URL

NBT007.001 Change netboot URL option works correctly
    [Documentation]    Check whether it's possible to change netboot url, and
    ...    boot to it.
    Skip If    not ${netboot_utilities_support}    NBT007.001 not supported
    Skip If    not ${tests_in_firmware_support}    NBT007.001 not supported
    Power On
    Set DUT Response Timeout    60s
    Enter Boot Menu Tianocore
    Enter Submenu in Tianocore    option=Network Boot and Utilities
    Enter Submenu in Tianocore    option=Advanced    checkpoint=Advanced    description_lines=2
    Enter Submenu in Tianocore    option=Change Netboot iPXE Payload URL    checkpoint=Exit    description_lines=2
    Enter Submenu in Tianocore    option=Change Netboot iPXE Payload URL    checkpoint=Default    description_lines=3
    Set DUT Response Timeout    20s
    Read From Terminal Until    Enter url parameters:
    FOR    ${i}    IN RANGE    100
        Write Bare Into Terminal    ${BACKSPACE}    0.1
    END
    Write Bare Into Terminal    http://boot.3mdeb.com/dts.ipxe\n    0.1
    Enter Submenu in Tianocore    option=Apply and Exit    checkpoint=Default    description_lines=3
    Enter Submenu in Tianocore    option=iPXE Boot    checkpoint=Advanced    description_lines=2
    Read From Terminal Until    Nothing to boot: No such file or directory
