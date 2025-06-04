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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${SYSFS_PREFIX}=    /sys/bus/acpi/devices


*** Test Cases ***
ACPT001.201 SuperIO UART presence in sysfs ACPI tree (Ubuntu)
    [Documentation]    Test verifies presence of SIO ACPI entries in sysfs.
    ...    Platform config must contain SIO_NODE, SIO_SER_NODE, SIO_SCOPE
    ...    and SIO_SER_SCOPE variables.
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${path_sio}=    Catenate    SEPARATOR="/"    ${SYSFS_PREFIX}    ${SIO_NODE}    path
    ${path_sio_ser}=    Catenate    SEPARATOR="/"    ${SYSFS_PREFIX}    ${SIO_SER_NODE}    path
    ${out_sio}=    Execute Command In Terminal    cat ${path_sio}
    ${out_sio_ser}=    Execute Command In Terminal    cat ${path_sio_ser}
    Should Contain    ${out_sio}    ${SIO_SCOPE}
    Should Contain    ${out_sio_ser}    ${SIO_SER_SCOPE}
