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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CAPSULE_UPDATE_SUPPORT}    Capsule Update not supported
...                     AND
...                     Flash Firmware If Not QEMU
Suite Teardown      Run Keywords
...                     Flash Firmware If Not QEMU
...                     AND
...                     Log Out And Close Connection


*** Test Cases ***
CUP001.001 Test
    [Documentation]    This test aims to verify...
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

    Install Docker Packages
    Detect Or Install Package    git
    Detect Or Install Package    unzip
    Detect Or Install Package    wget
    ${out}=    Execute Command In Terminal    rm -f coreboot
    Clone Git Repository    https://github.com/Dasharo/coreboot.git -b ${COREBOOT_REVISION} --depth 1

    Set Prompt For Terminal    root@${UBUNTU_HOSTNAME}:/home/${UBUNTU_USERNAME}/coreboot#
    Execute Command In Terminal    cd coreboot
    Execute Command In Terminal    echo "CONFIG_DRIVERS_EFI_FW_INFO=y" >> configs/${COREBOOT_CONFIG_FILE}
    Execute Command In Terminal    echo "CONFIG_DRIVERS_EFI_UPDATE_CAPSULES=y" >> configs/${COREBOOT_CONFIG_FILE}
    Execute Command In Terminal
    ...    sed -i 's/CONFIG_LOCALVERSION="v[^"]*"/CONFIG_LOCALVERSION="v99.99.99"/' configs/${COREBOOT_CONFIG_FILE}
    Execute Command In Terminal    ./build.sh ${COREBOOT_BUILD_PARAM}


*** Keywords ***
Flash Firmware If Not QEMU
    IF    '${CONFIG}' != 'qemu'    Flash Firmware    ${FW_FILE}
