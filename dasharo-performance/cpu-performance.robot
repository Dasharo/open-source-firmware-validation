*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../lib/performance/reference-values.robot
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         CPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
CPP001.001 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
#    TODO: Delete, we install PTS during Suite Setup
#    Detect Or Install Phoronix Test Suite (Ubuntu)
    Log To Console    Test start
    Run C-Ray Single-thread 4K Render    # na dole

# CPP001.002 Single Threaded CPU Benchmark (Ubuntu) (Battery)
#    [Documentation]    Test single threaded performance using phoronix
#    ...    test suite, for Ubuntu, while powered by inbuilt battery.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#    Skip If    not ${BATTERY_PRESENT}    Battery not present
#    Power Cycle Into Ubuntu

# CPP001.003 Single Threaded CPU Benchmark (Windows) (AC)
#    [Documentation]    Test single threaded performance using phoronix
#    ...    test suite, for Windows, while connected to power supply.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#    Power Cycle Into Windows

# CPP001.004 Single Threaded CPU Benchmark (Windows) (Battery)
#    [Documentation]    Test single threaded performance using phoronix
#    ...    test suite, for Windows, while powered by inbuilt battery.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#    Skip If    not ${BATTERY_PRESENT}    Battery not present
#    Power Cycle Into Windows

# CPP002.001 Multi Threaded CPU Benchmark (Ubuntu) (AC)
#    [Documentation]    Test multi threaded performance using phoronix
#    ...    test suite, for Ubuntu, while connected to power supply.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#    Power Cycle Into Ubuntu

# CPP002.002 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
#    [Documentation]    Test multi threaded performance using phoronix
#    ...    test suite, for Ubuntu, while powered by inbuilt battery.
#    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
#    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#    Skip If    not ${BATTERY_PRESENT}    Battery not present
#    Power Cycle Into Ubuntu

# CPP002.003 Multi Threaded CPU Benchmark (Windows) (AC)
#    [Documentation]    Test multi threaded performance using phoronix
#    ...    test suite, for Windows, while connected to power supply.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#    Power Cycle Into Windows

# CPP002.004 Multi Threaded CPU Benchmark (Windows) (Battery)
#    [Documentation]    Test multi threaded performance using phoronix
#    ...    test suite, for Windows, while powered by inbuilt battery.
#    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
#    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
#    Skip If    not ${BATTERY_PRESENT}    Battery not present
#    Power Cycle Into Windows


*** Keywords ***
CPU Performance Suite Setup
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power Cycle Into Ubuntu
        Detect Or Install Phoronix Test Suite On Ubuntu
        Execute Linux Command    phoronix-test-suite install compress-7zip    300
        Execute Linux Command    phoronix-test-suite install coremark    300
    END

Run C-Ray Single-thread 4K Render
    [Documentation]    Run C-Ray benchmark with 4K resolution and 1 thread
    ${test_name_1}=    Set Variable    nowanazwatestu
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results/
    ${result}=    Execute Command In Terminal
    ...    echo 1 | phoronix-test-suite batch-run pts/c-ray TEST_RESULTS_NAME=${test_name_1}
    ...    timeout=1800
    ${test_result_values}=    Execute Command In Terminal
    ...    awk -F '[<>]' '/<RawString/ && NF > 1 {print $3}' ${results_path_root}/${test_name_1}/composite.xml
    # ${TEST_AVERAGE}=    Execute Command In Terminal    awk -F '[<>]' '/<Value/ && NF > 1 {print $3}' ${RESULTS_PATH_ROOT}/${TEST_NAME_1}/composite.xml
    Log To Console    TestResutlValue: ${test_result_values}
    ${test_result_values}=    Set Variable    176.387:181.652:181.77
    ${test_state}=    Validate Results    ${test_result_values}
    Should Be Equal    ${test_state}    PASS

    # Would you like to save these test results (Y/n): y
    # Enter a name for the result file: hdRender1
    # Enter a unique name to describe this test run / configuration: typical

    # logs in: var/lib/phoronix-test-suite/test-results/

7-Zip Multi-thread Compression Average
    Execute Command In Terminal    phoronix-test-suite run pts/7zip --test compression --threads=auto
    Log    ${RESULT}

Validate Results
    [Arguments]    ${nums}
    ${ref_val}=    Convert To Number    ${HD_RAY}
    ${min}=    Evaluate    ${ref_val} * 0.9
    ${max}=    Evaluate    ${ref_val} * 1.1
    ${num_list}=    Split String    ${nums}    separator=:
    ${return_val}=    Set Variable    PASS

    ${qtty}=    Get Length    ${num_list}
    FOR    ${i}    IN RANGE    ${qtty}
        ${num}=    Convert To Number    ${num_list}[${i}]
        IF    ${num} < ${min} or ${num} > ${max}
            Log To Console    \nThe restult of test ${num} is out of range of (${min} - ${max}).
            ${return_val}=    Set Variable    FAIL
        END
    END
    RETURN    ${return_val}

    # ${sum}    Evaluate    sum(${num_list})
    # ${average}    Evaluate    ${sum} / len(${num_list})
    # [Return]    ${average}

Compare Values
    # ${lower_bound}=    Evaluate    0.9 * ${HD_RAY}
    # ${upper_bound}=    Evaluate    1.1 * ${HD_RAY}

    # Run Keyword If    ${HD_RAY} * 0.9 <= ${TEST_RESULT_VALUE}
    # ...    Keyword    @args
    # ...    ELSE IF    condition_in_py_expr
    # ...    Keyword    @args
    # ...    ELSE
    # ...    Keyword    @args
