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
EDP001.001 Enable early Boot DMA Protection support
    [Documentation]    This test aims to verify that the early boot DMA
    ...    protection might be activated and if the change is properly
    ...    recognized by the OS
    Skip If    not ${tests_in_firmware_support}    EDP001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    EDP001.001 not supported
    Skip If    not ${early_boot_dma_support}    EDP001.001 not supported
    Power On
    Enter Dasharo System Features
    Enter submenu in Tianocore    Dasharo Security Options
    ${dma_enabled}=    Check if Tianocore setting is enabled in current menu    Early boot DMA Protection
    # Refresh the screen
    Press key n times    1    ${F10}
    Press key n times    1    ${ESC}
    IF    not ${dma_enabled}
        Enter submenu in Tianocore    Early boot DMA Protection    ESC to exit    3
        Save changes and reset    3    4
    ELSE
        Log    Reboot
        Press key n times    2    ${ESC}
        Press key n times and enter    4    ${ARROW_DOWN}
    END
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Get cbmem from cloud
    ${cbmem_output}=    Execute Command In Terminal    cbmem -1 | grep --color=never DMA
    Should Contain    ${cbmem_output}    Successfully enabled VT-d PMR DMA protection

EDP002.001 Disable early Boot DMA Protection support
    [Documentation]    This test aims to verify that the early boot DMA
    ...    protection might be deactivated and if the change is properly
    ...    recognized by the OS
    Skip If    not ${tests_in_firmware_support}    EDP002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    EDP002.001 not supported
    Skip If    not ${early_boot_dma_support}    EDP001.001 not supported
    Power On
    Enter Dasharo System Features
    Enter submenu in Tianocore    Dasharo Security Options
    ${dma_enabled}=    Check if Tianocore setting is enabled in current menu    Early boot DMA Protection
    # Refresh the screen
    Press key n times    1    ${F10}
    Press key n times    1    ${ESC}
    IF    ${dma_enabled}
        Enter submenu in Tianocore    Early boot DMA Protection    ESC to exit    3
        Save changes and reset    3    4
    ELSE
        Log    Reboot
        Press key n times    2    ${ESC}
        Press key n times and enter    4    ${ARROW_DOWN}
    END
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Get cbmem from cloud
    ${cbmem_output}=    Execute Command In Terminal    cbmem -1 | grep --color=never DMA
    Should Not Contain    ${cbmem_output}    Successfully enabled VT-d PMR DMA protection
