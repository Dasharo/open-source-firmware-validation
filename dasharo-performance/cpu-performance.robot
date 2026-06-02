*** Settings ***
Library             Collections
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         CPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Variables ***
${RUNS_AMOUNT}=     3


*** Test Cases ***
CPP001.201 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Run Supported Benchmarks    singlecore

CPP002.201 Multi Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP002.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Run Supported Benchmarks    multicore

CPP003.201 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP003.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Run Supported Benchmarks    singlecore

CPP004.201 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP004.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Run Supported Benchmarks    multicore


*** Keywords ***
CPU Performance Suite Setup
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    Check Power Supply
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Detect Or Install Phoronix Test Suite On Ubuntu
    # Set DynamicRunCount to FALSE to prevent unstable run time
    Execute Linux Command
    ...    perl -pi -e 's|<DynamicRunCount>.*?</DynamicRunCount>|<DynamicRunCount>FALSE</DynamicRunCount>|' /etc/phoronix-test-suite.xml
    Execute Linux Command    phoronix-test-suite install compress-7zip    300
    Execute Linux Command    phoronix-test-suite install coremark    300
    Write Into Terminal    phoronix-test-suite batch-setup
    Read From Terminal Until    Save test results when in batch mode
    Write Into Terminal    y
    Read From Terminal Until    Open the web browser automatically when in batch mode
    Write Into Terminal    n
    Read From Terminal Until    Auto upload the results to OpenBenchmarking.org
    Write Into Terminal    y
    Read From Terminal Until    Prompt for test identifier
    Write Into Terminal    n
    Read From Terminal Until    Prompt for test description
    Write Into Terminal    n
    Read From Terminal Until    Prompt for saved results file-name
    Write Into Terminal    n
    Read From Terminal Until    Run all test options
    Write Into Terminal    y
    Read From Terminal Until Prompt
    Log To Console    The result of the benchmarks depends on the processor and
    ...    RAM in the device. Please make sure that the hardware under test is
    ...    compatible with the one given in the reference values.

    # Date and hour of the start of the test the same for all the tests
    ${get_date}=    Get Current Date    result_format=%d%m%Y%H%M%S
    VAR    ${CURRENT_DATE}=    ${get_date}    scope=GLOBAL
    ${laptop_platform}=    Check The Platform Is A Laptop

Run Supported Benchmarks
    [Documentation]    Runs all phoronix benchmarks and validates results by the given type
    [Arguments]    ${target_type}    # singlecore / multicore

    VAR    ${test_name_to_path}=    cpuperformance
    VAR    ${test_name_to_path}=    ${test_name_to_path}    ${CURRENT_DATE}    separator=${EMPTY}

    IF    '${target_type}' == 'singlecore'
        Execute Command In Terminal    export FORCE_TIMES_TO_RUN=${RUNS_AMOUNT}
        ${result}=    Execute Command In Terminal
        ...    phoronix-test-suite batch-run pts/coremark TEST_RESULTS_NAME=${test_name_to_path}
        ...    timeout=1800
        Should Not Contain    ${result}    The batch mode must first be configured.
    ELSE IF    '${target_type}' == 'multicore'
        Execute Command In Terminal    export FORCE_TIMES_TO_RUN=${RUNS_AMOUNT}
        ${result}=    Execute Command In Terminal
        ...    phoronix-test-suite batch-run pts/compress-7zip TEST_RESULTS_NAME=${test_name_to_path}
        ...    timeout=1800
        Should Not Contain    ${result}    The batch mode must first be configured.
    END

    VAR    ${any_failed}=    ${FALSE}
    VAR    @{errors}=    @{EMPTY}
    FOR    ${benchmark}    IN    @{CPP_BENCHMARKS}
        ${type}=    Get From Dictionary    ${benchmark}    type
        IF    '${type}' == '${target_type}'
            ${result}    ${msg}=    Validate A Result    ${test_name_to_path}    ${benchmark}
            IF    not $result
                VAR    ${any_failed}=    ${TRUE}
                Append To List    ${errors}    ${msg}
            END
        END
    END

    IF    ${any_failed}
        Log    Some benchmarks have failed:    ERROR
        FOR    ${msg}    IN    @{errors}
            Log    ${msg}    ERROR
        END
        Fail    Some benchmarks have failed
    END

Validate A Result
    [Documentation]    Reads a benchmark result from the phoronix XML output and validates it
    ...    against the reference value.
    [Arguments]    ${test_name_to_path}    ${benchmark_dict}
    ${phoronix_test_name}=    Get From Dictionary    ${benchmark_dict}    name
    ${ref_score}=    Get From Dictionary    ${benchmark_dict}    score
    ${scale}=    Get From Dictionary    ${benchmark_dict}    scale
    ${deviation}=    Get From Dictionary    ${benchmark_dict}    dev
    ${deviation_percent}=    Evaluate    float(${deviation})*100
    ${lower_bound}=    Evaluate    ${ref_score} * (1 - ${deviation})
    ${higher_bound}=    Evaluate    ${ref_score} * (1 + ${deviation})

    ${raw_values}=    Read The Results
    ...    ${PTS_RESULTS_DIR_LINUX_ROOT}
    ...    ${test_name_to_path}
    ...    ${phoronix_test_name}

    Log To Console    \nResults of ${phoronix_test_name}:
    ${num_list}=    Split String    ${raw_values}    separator=:
    FOR    ${benchmark_score}    IN    @{num_list}
        ${benchmark_score}=    Convert To Number    ${benchmark_score}
        IF    '${scale}' == 'higher_is_better'
            ${fail_condition}=    Evaluate    ${benchmark_score} < ${lower_bound}
            ${too_good_condition}=    Evaluate    ${benchmark_score} > ${higher_bound}
        ELSE IF    '${scale}' == 'lower_is_better'
            ${fail_condition}=    Evaluate    ${benchmark_score} > ${higher_bound}
            ${too_good_condition}=    Evaluate    ${benchmark_score} < ${lower_bound}
        END

        IF    ${too_good_condition}
            VAR    ${msg}=    ${phoronix_test_name}: The measured score of ${benchmark_score}
            ...    is over ${deviation_percent}% better than reference value: ${ref_score}
            Log    ${msg}    WARN
            RETURN    ${TRUE}    ${msg}
        ELSE IF    ${fail_condition}
            VAR    ${msg}=    ${phoronix_test_name}: The measured score of ${benchmark_score}
            ...    is over ${deviation_percent}% worse then the reference value: ${ref_score}
            Log    ${msg}    ERROR
            RETURN    ${FALSE}    ${msg}
        ELSE
            Log To Console    ${benchmark_score}
        END
    END
    VAR    ${msg}=    ${phoronix_test_name}: The measured score of ${benchmark_score}
    ...    is acceptable for reference value of ${ref_score}
    Log    ${msg}    CONSOLE
    RETURN    ${TRUE}    ${msg}

Read The Results
    [Arguments]    ${perf_results_path_ubuntu}    ${test_name_to_path}    ${test_description}
    VAR    ${awk_commmand}=
    ...    awk -F '[<>]' '/<Description>${test_description}<\\/Description>/
    ...    {found=1} found && /<RawString>/
    ...    {print $3; found=0}' ${perf_results_path_ubuntu}/${test_name_to_path}/composite.xml
    ...    separator=${SPACE}
    ${test_result_values}=    Execute Command In Terminal    ${awk_commmand}
    RETURN    ${test_result_values}
