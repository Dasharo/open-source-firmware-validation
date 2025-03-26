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
...                     Skip If    not ${ACPI_DRIVER_SUPPORT}    ACPI driver tests not supported
...                     AND
...                     Import Variables    ${CURDIR}/../platform-configs/${SENSORS_CONFIG_FILE}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

*** Variables ***
@{EXPECTED_OUTPUT}=    dasharo_acpi-acpi-0
...    Adapter: ACPI interface
...    CPU 0:
...    GPU 0:
...    CPU Package 0:
...    GPU 0:

*** Test Cases ***
ACP001.001 ACPI driver test (Ubuntu)
    [Documentation]    Tests if ACPI drivers can be recognised
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ACP001.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    ls /home/ubuntu
    # Should Contain    ${out}
    IF    "dasharo-acpi-dkms_0.0.1-1_amd64.deb" not in """${out}"""
        ${out}=    Execute Command In Terminal
        ...    wget https://github.com/Dasharo/osfv-test-data/blob/master/dasharo-driver/dasharo-acpi-dkms_0.0.1-1_amd64.deb -P /home/ubuntu
        ...    timeout=60s
        Should Contain    ${out}    saved
    END
    Detect Or Install Package    dkms
    Execute Command In Terminal    apt install ./dasharo-acpi-dkms_*.deb
    Execute Command In Terminal    modprobe dasharo-acpi
    Detect Or Install Package    lm-sensors
    ${out}=    Execute Command In Terminal    sensors
    Log To Console    \n\nOUT:\n${out}
    Should Contain All    ${out}    @{EXPECTED_OUTPUT}
