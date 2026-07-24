*** Settings ***
Library             Collections
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         CPP Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Variables ***
${RUNS_AMOUNT}=                 4
${BASELINE_RUNS_AMOUNT}=        10
${CPP_TESTS_INTERVAL}=          5
${CPP_TESTS_TIMEOUT}=           3600
${CPP_TEST_FOR_BASELINE}=       ${FALSE}


*** Test Cases ***
CPP001.201 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.201 not supported
    Skip If    ${LAPTOP_PLATFORM} and not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Run Supported Benchmarks    singlecore    ${ENV_ID_UBUNTU}

CPP002.201 Multi Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP002.201 not supported
    Skip If    ${LAPTOP_PLATFORM} and not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Run Supported Benchmarks    multicore    ${ENV_ID_UBUNTU}

CPP003.201 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP003.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is connected to AC
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Run Supported Benchmarks    singlecore    ${ENV_ID_UBUNTU}

CPP004.201 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP004.201 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is connected to AC
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Run Supported Benchmarks    multicore    ${ENV_ID_UBUNTU}

CPP001.301 Single Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Windows, while connected to power supply.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP001.301 not supported
    Skip If    ${LAPTOP_PLATFORM} and not ${AC_CONNECTED}    The platform is not connected to AC
    # Power On
    Boot And Login To Windows
    Run Supported Benchmarks    singlecore    ${ENV_ID_WINDOWS}

CPP002.301 Multi Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Windows, while connected to power supply.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP002.301 not supported
    Skip If    ${LAPTOP_PLATFORM} and not ${AC_CONNECTED}    The platform is not connected to AC
    # Power On
    Boot And Login To Windows
    Run Supported Benchmarks    multicore    ${ENV_ID_WINDOWS}

CPP003.301 Single Threaded CPU Benchmark (Windows) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Windows, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP003.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is connected to AC
    Skip If Battery Level Below 30 Percent In Windows
    # Power On
    Boot And Login To Windows
    Run Supported Benchmarks    singlecore    ${ENV_ID_WINDOWS}

CPP004.301 Multi Threaded CPU Benchmark (Windows) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Windows, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP004.301 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is connected to AC
    Skip If Battery Level Below 30 Percent In Windows
    # Power On
    Boot And Login To Windows
    Run Supported Benchmarks    multicore    ${ENV_ID_WINDOWS}


*** Keywords ***
Check Battery Percentage In Windows
    [Documentation]    Keyword check the battery percentage in Windows OS.
    ${percentage}=    Execute Command In Terminal    (Get-WmiObject win32_battery).estimatedChargeRemaining
    RETURN ${percentage}

Skip If Battery Level Below 30 Percent In Windows
    ${battery_percentage}=    Check Battery Percentage In Windows
    IF    ${battery_percentage} < 30
        Log To Console    \n Skipping the test - Battery is too low.
        Skip
    END

CPP Suite Setup
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    Check Power Supply
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Detect Or Install Phoronix Test Suite On Ubuntu
    # Set DynamicRunCount to FALSE to prevent unstable run time
    Execute Linux Command
    ...    perl -pi -e 's|<DynamicRunCount>.*?</DynamicRunCount>|<DynamicRunCount>FALSE</DynamicRunCount>|' /etc/phoronix-test-suite.xml
    # Install all tests on Ubuntu
    VAR    @{unique_tests}=    @{EMPTY}
    FOR    ${test}    IN    @{CPP_BENCHMARKS}
        ${test_short_name}=    Get From Dictionary    ${test}    short_name
        IF    '${test_short_name}' not in ${unique_tests}
            Append To List    ${unique_tests}    ${test_short_name}
            ${result}=    Execute Command In Terminal
            ...    phoronix-test-suite install ${test_short_name}
            ...    timeout=120
            # Should Contain    ${result}    Installed:    Could not install ${test_name}
            Log To Console    ${test_short_name} is installed on Ubuntu\n
        END
    END
    Execute Linux Command    phoronix-test-suite install c-ray    300
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

    # configuration in Windows
    Boot And Login To Windows
    Detect Or Install Phoronix Test Suite On Windows
    Set Prompt For Terminal    PS C:\\>
    Execute Command In Terminal    cd C:\\
    # Install all tests on Windows
    VAR    @{unique_tests}=    @{EMPTY}
    FOR    ${test}    IN    @{CPP_BENCHMARKS}
        ${test_short_name}=    Get From Dictionary    ${test}    short_name
        IF    '${test_short_name}' not in ${unique_tests}
            Append To List    ${unique_tests}    ${test_short_name}
            ${result}=    Execute Command In Terminal
            ...    .\\phoronix-test-suite\\phoronix-test-suite install ${test_short_name}
            ...    timeout=120
            # Should Contain    ${result}    Installed:    Could not install ${test_name}
            Log To Console    ${test_short_name} is installed on Windows\n
        END
    END
    Write Into Terminal    .\\phoronix-test-suite\\phoronix-test-suite batch-setup
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
    # Read From Terminal Until Prompt
    Log To Console
    ...    The result of the benchmarks depends on the processor and
    ...    \nRAM in the device. Please make sure that the hardware under
    ...    \ntest is compatible with the one given in the reference values.\n

    # Date and hour of the start of the test the same for all the tests
    ${get_date}=    Get Current Date    result_format=%d%m%Y%H%M%S
    VAR    ${CURRENT_DATE}=    ${get_date}    scope=GLOBAL
    # ${laptop_platform}=    Check The Platform Is A Laptop

Run Supported Benchmarks
    [Documentation]    Runs all phoronix benchmarks and validates results by the given type
    [Arguments]    ${target_type}    ${chosen_os}    # singlecore / multicore

    VAR    ${test_name_to_path}=    cpuperformance
    VAR    ${test_name_to_path}=    ${test_name_to_path}    ${CURRENT_DATE}    separator=${EMPTY}

    VAR    @{unique_tests}=    @{EMPTY}
    VAR    ${runs}=    ${RUNS_AMOUNT}
    IF    '${CPP_TEST_FOR_BASELINE}' == '${TRUE}'
        VAR    ${runs}=    ${BASELINE_RUNS_AMOUNT}
    END
    FOR    ${test}    IN    @{CPP_BENCHMARKS}
        ${type}=    Get From Dictionary    ${test}    type
        ${test_name_short}=    Get From Dictionary    ${test}    short_name
        IF    '${test_name_short}' not in ${unique_tests}
            Append To List    ${unique_tests}    ${test_name_short}
            IF    '${type}' == '${target_type}'
                Log To Console    \nStarting test: ${test_name_short}...\n
                IF    '${chosen_os}' == '${ENV_ID_WINDOWS}'
                    Set Prompt For Terminal    PS C:\\>
                    Execute Command In Terminal    cd C:\\
                    Execute Command In Terminal    \$env:FORCE_TIMES_TO_RUN=${runs}
                    ${result}=    Execute Command In Terminal
                    ...    .\\phoronix-test-suite\\phoronix-test-suite batch-run ${test_name_short} TEST_RESULTS_NAME=${test_name_to_path}
                    ...    timeout=${CPP_TESTS_TIMEOUT}
                    Should Not Contain    ${result}    The batch mode must first be configured.
                ELSE
                    Execute Command In Terminal    export FORCE_TIMES_TO_RUN=${runs}
                    ${result}=    Execute Command In Terminal
                    ...    phoronix-test-suite batch-run ${test_name_short} TEST_RESULTS_NAME=${test_name_to_path}
                    ...    timeout=${CPP_TESTS_TIMEOUT}
                    Should Not Contain    ${result}    The batch mode must first be configured.
                END
                Log To Console    \n${test_name_short} finished! Sleeping for ${CPP_TESTS_INTERVAL}s before next test\n
                Sleep    ${CPP_TESTS_INTERVAL}
            END
        END
    END
    Skip If    ${unique_tests} == @{EMPTY}    No ${target_type} tests supported for this platform

    VAR    ${any_failed}=    ${FALSE}
    VAR    @{errors}=    @{EMPTY}
    FOR    ${benchmark}    IN    @{CPP_BENCHMARKS}
        ${type}=    Get From Dictionary    ${benchmark}    type
        IF    '${type}' == '${target_type}'
            ${result}    ${msg}=    Validate A Result    ${test_name_to_path}    ${benchmark}    ${chosen_os}
            IF    not $result
                VAR    ${any_failed}=    ${TRUE}
                Append To List    ${errors}    ${msg}
            END
        END
    END

    IF    '${CPP_TEST_FOR_BASELINE}' == '${TRUE}'
        Skip    New baseline results
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
    [Arguments]    ${test_name_to_path}    ${benchmark_dict}    ${chosen_os}
    ${phoronix_test_name}=    Get From Dictionary    ${benchmark_dict}    name
    ${ref_score}=    Get From Dictionary    ${benchmark_dict}    score
    ${scale}=    Get From Dictionary    ${benchmark_dict}    scale
    ${deviation}=    Get From Dictionary    ${benchmark_dict}    dev
    ${deviation_percent}=    Evaluate    float(${deviation})*100
    ${lower_bound}=    Evaluate    ${ref_score} * (1 - ${deviation})
    ${higher_bound}=    Evaluate    ${ref_score} * (1 + ${deviation})
    IF    '${chosen_os}' == '${ENV_ID_WINDOWS}'
        ${raw_values}=    Read The Results Windows
        ...    ${PTS_RESULTS_DIR_WINDOWS}
        ...    ${test_name_to_path}
        ...    ${phoronix_test_name}
    ELSE
        ${raw_values}=    Read The Results Linux
        ...    ${PTS_RESULTS_DIR_LINUX}
        ...    ${test_name_to_path}
        ...    ${phoronix_test_name}
    END

    ${num_list}=    Split String    ${raw_values}    separator=:
    IF    '${CPP_TEST_FOR_BASELINE}' == '${TRUE}'
        Generate Test Baseline Config    ${num_list}    ${benchmark_dict}
    END

    Log To Console    \nResults of ${phoronix_test_name}:
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

Read The Results Linux
    [Arguments]    ${perf_results_path_ubuntu}    ${test_name_to_path}    ${test_description}
    VAR    ${awk_commmand}=
    ...    awk -F '[<>]' '/<Description>${test_description}<\\/Description>/
    ...    {found=1} found && /<RawString>/
    ...    {print $3; found=0}' ${perf_results_path_ubuntu}/${test_name_to_path}/composite.xml
    ...    separator=${SPACE}
    ${test_result_values}=    Execute Command In Terminal    ${awk_commmand}
    RETURN    ${test_result_values}

Read The Results Windows
    [Arguments]    ${perf_results_path_windows}    ${test_name_to_path}    ${test_description}
    VAR    ${read_command}=
    ...    [xml]\$xml = Get-Content '${perf_results_path_windows}\\${test_name_to_path}\\composite.xml';
    ...    (\$xml.PhoronixTestSuite.Result | Where-Object \{\$_.Description -eq '${test_description}'\}).Data.Entry.RawString
    ${test_result_values}=    Execute Command In Terminal    ${read_command}
    Log To Console    ${test_result_values} - ${test_description} - ${read_command}
    ${test_result_values}=    Fetch From Right    ${test_result_values}    >> \r\n
    RETURN    ${test_result_values}
    # RETURN    123456

Generate Test Baseline Config
    [Arguments]    ${baseline_scores}    ${benchmark_dict}
    ${test_full_name}=    Get From Dictionary    ${benchmark_dict}    name
    ${test_short_name}=    Get From Dictionary    ${benchmark_dict}    short_name
    ${test_scale}=    Get From Dictionary    ${benchmark_dict}    scale
    ${test_dev}=    Get From Dictionary    ${benchmark_dict}    dev
    ${test_type}=    Get From Dictionary    ${benchmark_dict}    type

    ${baseline_score_avg}=    Evaluate    round(sum(list(map(float, ${baseline_scores})))/len(${baseline_scores}),2)
    ${baseline_score_dev}=    Evaluate    statistics.stdev(list(map(float,${baseline_scores})))
    ${baseline_score_dev}=    Evaluate    round(${baseline_score_dev}/${baseline_score_avg}+0.05, 2)

    Log To Console    New baseline config for ${test_short_name} -> ${test_full_name}
    Log To Console    \&\{BASELINE_TEST_NAME\}\=
    Log To Console    ...\t\tname=${test_full_name}
    Log To Console    ...\t\tshort_name=${test_short_name}
    Log To Console    ...\t\tscore=${baseline_score_avg}
    Log To Console    ...\t\tscale=${test_scale}
    Log To Console    ...\t\tdev=${baseline_score_dev}
    Log To Console    ...\t\ttype=${test_type}\n
