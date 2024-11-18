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
...                     Prepare Test Suite
...                     Skip If    not ${BUILD_ON_NEWLY_INSTALLED_OS_SUPPORT}
...                     Install Ubuntu From Connected Drive
Suite Teardown      Run Keywords
...                     Log Out And Close Connection

*** Test Cases ***
BNO001.001 Build on a Newly installed OS (Ubuntu)
    [Documentation]    Check if the binary will be built and work properly
    ...    on a fresh install of Ubuntu

    Power On
    Boot System Or From Connected Disk    ubuntu

    Execute Command In Terminal    git clone https://github.com/Dasharo/coreboot
    ${out}=    Execute Command In Terminal    cd coreboot; ./build.sh ${COREBOOT_BUILD_WRAPPER_SUBCOMMAND}; cd ..;

    # The cbfs map being printed should implies that the build was successful  
    Should Contain   ${out}    FMAP REGION: COREBOOT

BBO001.002 Boot with firmare built from source (Ubuntu)
    [Documentation]    Check if the binary will be built and work properly
    ...    on Windows

    Power On
    Boot System Or From Connected Disk    ubuntu
    Flash Firmware    ./coreboot/coreboot.rom
    Execute Reboot Command

    Login To Linux


*** Keywords ***
Install Ubuntu From Connected Drive
    [Documentation]    Installs ubuntu from a drive connected by `scripts/ci/run_qemu.sh os_install`
    ...    which is called in `scripts/ci/qemu-build-test.sh`

    Power On
    Enter UEFI Shell
    Execute UEFI Shell Command    FS0:
    Execute UEFI Shell Command    cd EFI
    Execute UEFI Shell Command    cd boot
    Execute UEFI Shell Command    grubx64.efi
    Sleep     600s    # wait for the installation to complete
    