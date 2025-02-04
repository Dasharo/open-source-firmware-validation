*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/common.robot

Suite Setup         CPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
CPP001.001 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu
    ${cmd}=    Set Variable    phoronix-test-suite pts/coremark
    ${result}=    Execute Linux Command    ${cmd}    3600

CPP001.002 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu

CPP001.003 Single Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

CPP001.004 Single Threaded CPU Benchmark (Windows) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows

CPP002.001 Multi Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power Cycle Into Ubuntu

CPP002.002 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Ubuntu

CPP002.003 Multi Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Power Cycle Into Windows

CPP002.004 Multi Threaded CPU Benchmark (Windows) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power Cycle Into Windows


*** Keywords ***
CPU Performance Suite Setup
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    # Install phoronix-test-suite
