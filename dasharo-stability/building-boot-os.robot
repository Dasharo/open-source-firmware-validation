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
...                     AND
...                     Skip If    not ${BUILD_ON_NEWLY_INSTALLED_OS_SUPPORT}
...                     AND
...                     Install Ubuntu From Connected Drive
Suite Teardown      Run Keywords
...                     Log Out And Close Connection

*** Test Cases ***
BNO001.001 Build on a Newly installed OS
    [Documentation]    Check if the ns5x-tgl binary will be built
    ...    properly on a fresh install of Ubuntu

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux

    Switch To Root User
    Install Package    git
    Install Docker Packages

    Build Qemu

BNO002.001 Build NS5x-tgl on a Newly installed OS
    [Documentation]    Check if the qemu binary will be built properly
    ...    on a fresh install of Ubuntu

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux

    Switch To Root User
    Install Package    git
    Install Docker Packages

    Build Novacustom Ns5x-tgl  

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
    Sleep     15m    # wait 15m for the installation to complete

Build Qemu
    [Documentation]    Build the firmware for qemu

    Execute Command In Terminal    rm -rf coreboot
    Execute Command In Terminal    git clone https://github.com/Dasharo/coreboot
    ...    5m
    
    Execute Command In Terminal    cd coreboot; git switch dasharo; cd ..
    ${out}=    Execute Command In Terminal    cd coreboot; ./build.sh qemu; cd ..
    ...    120m

    Should Contain    ${out}    FMAP REGION: COREBOOT
    ${out}=    Execute Command In Terminal    ls coreboot/qemu_q35*.rom
    Should Not Contain    ${out}    No such file

Build Novacustom Ns5x-tgl
    [Documentation]    Build the firmware for ns5x-tgl

    Execute Command In Terminal    rm -rf coreboot
    Execute Command In Terminal    rm -rf ec

    Execute Command In Terminal    git clone https://github.com/Dasharo/coreboot
    ...    5m
    Execute Command In Terminal    git clone https://github.com/dasharo/ec
    ...    5m
    
    Execute Command In Terminal    cd ec; git switch ns5x_tgl_v1.5.2 ; cd ..
    ...    5m
    Execute Command In Terminal    cd ec; git submodule update --init --recursive --checkout; cd ..
    ...    5m
    ${out}=    Execute Command In Terminal    cd ec; EC_BOARD_VENDOR=novacustom EC_BOARD_MODEL=ns5x_tgl ./build.sh; cd ..
    ...    15m

    ${out}=    Execute Command In Terminal    ls ec/novacustom_ns5x_tgl_ec.rom
    Should Contain    ${out}    novacustom_ns5x_tgl_ec.rom
    Execute Command In Terminal    cp ec/novacustom_ns5x_tgl_ec.rom coreboot/ec.rom

    Execute Command In Terminal    cd coreboot; git switch ns5x_tgl_v1.5.2 ; cd ..
    ...    5m
    Execute Command In Terminal    cd coreboot; git submodule update --init --recursive --checkout; cd ..
    ...    5m

    ${docker_command}=    Set Variable
    ...    /bin/bash -c "make distclean && cp configs/config.novacustom_ns5x_tgl .config && make olddefconfig && make"
    ${out}=    Execute Command In Terminal
    ...    cd coreboot; docker run --rm -it -u $UID -v $PWD:/home/coreboot/coreboot -w /home/coreboot/coreboot coreboot/coreboot-sdk:2023-11-24_2731fa619b ${docker_command}; cd ..
    ...    30m
    Should Contain    ${out}    FMAP REGION: COREBOOT
    ${out}=    Execute Command In Terminal    ls build/coreboot.rom
    Should Not Contain    ${out}    No such file
