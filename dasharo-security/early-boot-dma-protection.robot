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
EDP001.001 Enable early Boot DMA Protection support
    [Documentation]    This test aims to verify that the early boot DMA
    ...    protection might be activated and if the change is properly
    ...    recognized by the OS
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    EDP001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EDP001.001 not supported
    Skip If    not ${EARLY_BOOT_DMA_SUPPORT}    EDP001.001 not supported
    Power On
    Enter Dasharo System Features
    Enter Submenu In Tianocore    Dasharo Security Options
    ${dma_enabled}=    Check If Tianocore Setting Is Enabled In Current Menu    Early boot DMA Protection
    # Refresh the screen
    Press Key N Times    1    ${F10}
    Press Key N Times    1    ${ESC}
    IF    not ${dma_enabled}
        Enter Submenu In Tianocore    Early boot DMA Protection    ESC to exit    3
        Save Changes And Reset    3    4
    ELSE
        Log    Reboot
        Press Key N Times    2    ${ESC}
        Press Key N Times And Enter    4    ${ARROW_DOWN}
    END
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${cbmem_output}=    Execute Command In Terminal    cbmem -1 | grep --color=never DMA
    Should Contain    ${cbmem_output}    Successfully enabled VT-d PMR DMA protection

EDP002.001 Disable early Boot DMA Protection support
    [Documentation]    This test aims to verify that the early boot DMA
    ...    protection might be deactivated and if the change is properly
    ...    recognized by the OS
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    EDP002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    EDP002.001 not supported
    Skip If    not ${EARLY_BOOT_DMA_SUPPORT}    EDP001.001 not supported
    Power On
    Enter Dasharo System Features
    Enter Submenu In Tianocore    Dasharo Security Options
    ${dma_enabled}=    Check If Tianocore Setting Is Enabled In Current Menu    Early boot DMA Protection
    # Refresh the screen
    Press Key N Times    1    ${F10}
    Press Key N Times    1    ${ESC}
    IF    ${dma_enabled}
        Enter Submenu In Tianocore    Early boot DMA Protection    ESC to exit    3
        Save Changes And Reset    3    4
    ELSE
        Log    Reboot
        Press Key N Times    2    ${ESC}
        Press Key N Times And Enter    4    ${ARROW_DOWN}
    END
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Get Cbmem From Cloud
    ${cbmem_output}=    Execute Command In Terminal    cbmem -1 | grep --color=never DMA
    Should Not Contain    ${cbmem_output}    Successfully enabled VT-d PMR DMA protection
