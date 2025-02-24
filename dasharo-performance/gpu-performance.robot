*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/reference-values.robot
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/gpu.robot

Suite Setup         GPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
GPP001.001 GPU Performance Measure (Ubuntu) (AC)
    [Documentation]    Test GPU performance for Ubuntu on AC
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Run GPU Performance Benchmark On Ubuntu

GPP001.001 GPU Performance Measure (Ubuntu) (Battery)
    [Documentation]    Test GPU performance for Ubuntu on Battery
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Run GPU Performance Benchmark On Ubuntu

GPP001.001 GPU Performance Measure (Windows) (AC)
    [Documentation]    Test GPU performance for Windows on AC
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    # TODO: Remove PTS installation from tests once Login To Windows KWD
    # works outside of tests only.
    Detect Or Install Phoronix Test Suite On Windows
    Run GPU Performance Benchmark On Windows

GPP001.001 GPU Performance Measure (Windows) (Battery)
    [Documentation]    Test GPU performance for Windows on Battery
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    # TODO: Remove PTS installation from tests once Login To Windows KWD
    # works outside of tests only.
    Detect Or Install Phoronix Test Suite On Windows
    Run GPU Performance Benchmark On Windows


*** Keywords ***
GPU Performance Suite Setup
    [Documentation]    Load config and download tooling for both windows
    ...    ubuntu.
    Prepare Test Suite
    Skip If    not ${GPU_PERFORMANCE_TESTS_SUPPORT}
    ...    GPU Performance Tests not available for this platform
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power Cycle Into Ubuntu
        Execute Linux Command    mkdir ~/testing
        Detect Or Install Phoronix Test Suite On Ubuntu
        # unigine superposition takes 1,5GB so we give 10 minutes timeout for download
        Execute Linux Command    phoronix-test-suite install unigine-super    600
    END
    # TODO: Move package installation to here, once Login To Windows KWD
    # works outside of tests only.
    # IF    ${TESTS_IN_WINDOWS_SUPPORT}
    #    Power Cycle Into Windows
    #    Detect Or Install Phoronix Test Suite On Windows
    # END
