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

Default Tags        automated


*** Variables ***
@{EXPECTED_OUTPUT_1}=
...                         dasharo_acpi-isa-0000
...                         Adapter: ISA adapter
@{EXPECTED_OUTPUT_2}=
...                         dasharo_acpi-acpi-0
...                         Adapter: ACPI interface

@{EXPECTED_OUTPUTS}=        ${EXPECTED_OUTPUT_1}    ${EXPECTED_OUTPUT_2}
@{SUCCESS_OUTPUT}=
...                         Complete!
...                         already installed
...                         0 newly installed
...                         Upgrading: 0, Installing: 0, Removing: 0
...                         1 newly installed,


*** Test Cases ***
ACPI001.201 ACPI driver test (Ubuntu)
    [Documentation]    Tests if ACPI drivers can be recognised
    ...    Previous IDs: ACPI001.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ACP001.001 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    dpkg -s dasharo-acpi-dkms
    IF    "Status: install ok installed" not in """${out}"""
        Send File To DUT
        ...    ${TEST_DATA_DIR}/dasharo-driver/dasharo-acpi-dkms-0.9.1_amd64.deb
        ...    /home/ubuntu/dasharo-acpi-dkms.deb
        ${out}=    Execute Command In Terminal    apt install /home/ubuntu/dasharo-acpi-dkms.deb -y
        ...    timeout=60s
        Should Contain Any    ${out}    @{SUCCESS_OUTPUT}
    END
    Detect Or Install Package    dkms
    ${out}=    Execute Command In Terminal    modprobe dasharo-acpi
    IF    "modprobe: ERROR: could not insert 'dasharo_acpi'" in """${out}"""
        Log To Console    Rebuilding dasharo-acpi DKMS module due to modprobe failure
        Execute Command In Terminal    sudo dkms remove dasharo-acpi/0.9.1 --all
        Execute Command In Terminal    sudo dkms build dasharo-acpi/0.9.1
        Execute Command In Terminal    sudo dkms install dasharo-acpi/0.9.1
        ${out}=    Execute Command In Terminal    modprobe dasharo-acpi
    END
    Should Be Empty    ${out}
    Detect Or Install Package    lm-sensors
    ${out}=    Execute Command In Terminal    sensors
    Should Contain All From Any    ${out}    ${EXPECTED_OUTPUT_1}    ${EXPECTED_OUTPUT_2}

ACPI001.202 ACPI driver test (Fedora)
    [Documentation]    Tests if ACPI drivers can be recognised
    ...    Previous IDs: ACPI001.002
    # Skip If    not ${TEST_IN_FE} or    ACP001.002 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Command In Terminal    rpm -q dasharo-acpi-dkms
    # Should Contain    ${out}
    IF    "dasharo-acpi-dkms-0.0.1-1.x86_64" not in """${out}"""
        Send File To DUT
        ...    ${TEST_DATA_DIR}/dasharo-driver/dasharo-acpi-dkms-0.9.1.x86_64.rpm
        ...    /home/linux/dasharo-acpi-dkms.rpm
        ${out}=    Execute Command In Terminal    sudo dnf install /home/linux/dasharo-acpi-dkms.rpm -y
        ...    timeout=60s
        Should Contain Any    ${out}    @{SUCCESS_OUTPUT}
    END
    ${out}=    Execute Command In Terminal    sudo dnf install dkms -y
    ...    timeout=60s
    Should Contain Any    ${out}    @{SUCCESS_OUTPUT}
    ${out}=    Execute Command In Terminal    modprobe dasharo-acpi
    Should Be Empty    ${out}
    ${out}=    Execute Command In Terminal    sudo dnf install lm_sensors -y
    ...    timeout=60s
    Should Contain Any    ${out}    @{SUCCESS_OUTPUT}
    ${out}=    Execute Command In Terminal    sensors
    Should Contain All From Any    ${out}    ${EXPECTED_OUTPUT_1}    ${EXPECTED_OUTPUT_2}


*** Keywords ***
Should Contain All From Any
    [Arguments]    ${out}    @{expected_lists}
    FOR    ${expected_list}    IN    @{expected_lists}
        ${ok}=    Evaluate    all(word in """${out}""" for word in ${expected_list})
        IF    ${ok}    RETURN
    END
    Fail    Output did not match any expected list
