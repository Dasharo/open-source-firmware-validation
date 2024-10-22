*** Settings ***
Library             Collections
Library             Dialogs
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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
...                     Build And Flash
Suite Teardown      Run Keywords
...                     Log Out And Close Connection

*** Test Cases ***
BBO001.001 Build and Boot (Ubuntu)
    [Documentation]    Check if the binary will be built and work properly
    ...    on Ubuntu
    Power On
    Boot System Or From Connected Disk    ubuntu
    Flash Firmware    /tmp/coreboot.rom
    Execute Reboot Command

    Login To Linux

BBO001.002 Build and Boot (Windows)
    [Documentation]    Check if the binary will be built and work properly
    ...    on Windows
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}

    Power On
    Boot System Or From Connected Disk    ubuntu
    Flash Firmware    /tmp/coreboot.rom
    Execute Reboot Command

    Login To Windows
    

*** Keywords ***
Build And Flash
    Run    git clone https://github.com/Dasharo/dasharo-tools.git
    Run    cd coreboot; ./build.sh ${COREBOOT_BUILD_WRAPPER_SUBCOMMAND}; cd ..;


    