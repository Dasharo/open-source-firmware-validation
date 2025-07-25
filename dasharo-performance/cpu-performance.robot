*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         CPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Variables ***
${DEVIATION_UP}=        1.2    # acceptable deviation +/-20%
${DEVIATION_DOWN}=      0.8


*** Test Cases ***
CPP001.201 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.001 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${render_test_passed}=    Run C-Ray Single-thread Render
    ${coremark_test_passed}=    Run Coremark Single-thread
    Should Be True    ${render_test_passed}
    Should Be True    ${coremark_test_passed}

CPP001.202 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${render_test_passed}=    Run C-Ray Single-thread Render
    ${coremark_test_passed}=    Run Coremark Single-thread
    Should Be True    ${render_test_passed}
    Should Be True    ${coremark_test_passed}

CPP002.201 Multi Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${c_7zip_test_passed}=    7-Zip Multi-thread Compression And Decompression Average
    Should Be True    ${c_7zip_test_passed}

CPP002.202 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Skip If Battery Level Below 30 Percent
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${c_7zip_test_passed}=    7-Zip Multi-thread Compression And Decompression Average
    Should Be True    ${c_7zip_test_passed}


*** Keywords ***
CPU Performance Suite Setup
    [Tags]    robot:private
    Prepare Test Suite
    Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}
    Check Power Supply
    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Power On
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Detect Or Install Phoronix Test Suite On Ubuntu
        Execute Linux Command    phoronix-test-suite install c-ray    300
        Execute Linux Command    phoronix-test-suite install compress-7zip    300
        Execute Linux Command    phoronix-test-suite install coremark    300
    END
    Log To Console    The result of the benchmarks depends on the processor and
    ...    RAM in the device. Please make sure that the hardware under test is
    ...    compatible with the one given in the reference values.

    # Date and hour of the start of the test the same for all the tests
    ${get_date}=    Get Current Date    result_format=%d%m%Y%H%M%S
    VAR    ${CURRENT_DATE}=    ${get_date}    scope=GLOBAL
    ${laptop_platform}=    Check The Platform Is A Laptop
    VAR    ${1080p}=    Resolution: 1080p - Rays Per Pixel: 16=${EMPTY}    ${CRAY_1080_P_RENDER}    separator=${SPACE}
    VAR    ${4k}=    Resolution: 4K - Rays Per Pixel: 16=${EMPTY}    ${CRAY_4_K_RENDER}    separator=${SPACE}
    VAR    ${5k}=    Resolution: 5K - Rays Per Pixel: 16=${EMPTY}    ${CRAY_5_K_RENDER}    separator=${SPACE}
    VAR    @{SINGLE_THREAD_RES_TESTS}=    ${1080p}    ${4k}    ${5k}    scope=GLOBAL
    VAR    ${comp}=    Test: Compression Rating=${ZIP_MULTI_COMPRESSION}    separator=${SPACE}
    VAR    ${decomp}=    Test: Decompression Rating=${ZIP_MULTI_DECOMPRESSION}    separator=${SPACE}
    VAR    @{MULTI_THREAD_TESTS}=    ${comp}    ${decomp}    scope=GLOBAL

Run C-Ray Single-thread Render
    [Documentation]    Run C-Ray benchmark with all resolutions (1080p, 4K, 5K) on single thread
    [Tags]    robot:private
    Log To Console    \n    # new line for readability
    VAR    ${test_name_to_path}=    cpuperformance
    VAR    ${test_name_to_path}=    ${test_name_to_path}    ${CURRENT_DATE}    separator=${EMPTY}

    ${result}=    Execute Command In Terminal
    ...    echo 4 | phoronix-test-suite batch-run pts/c-ray TEST_RESULTS_NAME=${test_name_to_path}
    ...    timeout=18000
    Should Not Contain    ${result}    The batch mode must first be configured.

    ${test_passed}=    Validate Multiple Results
    ...    ${PTS_RESULTS_DIR_LINUX_ROOT}
    ...    ${test_name_to_path}
    ...    @{SINGLE_THREAD_RES_TESTS}
    RETURN    ${test_passed}

Run Coremark Single-thread
    [Documentation]    Run Coremark benchmark on single thread
    [Tags]    robot:private
    VAR    ${test_name_to_path}=    cpuperformance
    VAR    ${test_name_to_path}=    ${test_name_to_path}    ${CURRENT_DATE}    separator=${EMPTY}

    ${result}=    Execute Command In Terminal
    ...    phoronix-test-suite batch-run pts/coremark TEST_RESULTS_NAME=${test_name_to_path}
    ...    timeout=1800
    Should Not Contain    ${result}    The batch mode must first be configured.

    ${test_result_values}=    Read The Results
    ...    ${PTS_RESULTS_DIR_LINUX_ROOT}
    ...    ${test_name_to_path}
    ...    CoreMark Size 666 - Iterations Per Second
    Log To Console    \nResults of the CoreMark Size 666 - Iterations Per Second:\n
    ${test_passed}=    Validate The Results    ${test_result_values}    ${COREMARK_SINGLE}
    RETURN    ${test_passed}

7-Zip Multi-thread Compression And Decompression Average
    [Documentation]    Run 7-Zip Multi-thread Compression and Decompression benchmark on multiple threads
    [Tags]    robot:private
    Log To Console    \n    # new line for readability
    VAR    ${test_name_to_path}=    cpuperformance
    VAR    ${test_name_to_path}=    ${test_name_to_path}    ${CURRENT_DATE}    separator=${EMPTY}

    ${result}=    Execute Command In Terminal
    ...    phoronix-test-suite batch-run pts/compress-7zip TEST_RESULTS_NAME=${test_name_to_path}
    ...    timeout=1800
    Should Not Contain    ${result}    The batch mode must first be configured.

    ${test_passed}=    Validate Multiple Results
    ...    ${PTS_RESULTS_DIR_LINUX_ROOT}
    ...    ${test_name_to_path}
    ...    @{MULTI_THREAD_TESTS}
    RETURN    ${test_passed}

Read The Results
    [Tags]    robot:private
    [Arguments]    ${perf_results_path_ubuntu}    ${test_name_to_path}    ${test_description}
    VAR    ${awk_commmand}=
    ...    awk -F '[<>]' '/<Description>${test_description}<\\/Description>/
    ...    {found=1} found && /<RawString>/
    ...    {print $3; found=0}' ${perf_results_path_ubuntu}/${test_name_to_path}/composite.xml
    ...    separator=${SPACE}
    ${test_result_values}=    Execute Command In Terminal    ${awk_commmand}
    RETURN    ${test_result_values}

Validate The Results
    [Tags]    robot:private
    [Arguments]    ${nums}    ${combined_ref_val}
    ${ref_val}=    Convert To Number    ${combined_ref_val}
    ${min}=    Evaluate    ${ref_val} * ${DEVIATION_DOWN}
    ${max}=    Evaluate    ${ref_val} * ${DEVIATION_UP}
    ${num_list}=    Split String    ${nums}    separator=:
    VAR    ${return_val}=    ${True}

    ${qtty}=    Get Length    ${num_list}
    FOR    ${i}    IN RANGE    ${qtty}
        ${num}=    Convert To Number    ${num_list}[${i}]
        ${i_plus_one}=    Evaluate    ${i} + 1
        IF    ${num} < ${min} or ${num} > ${max}
            Log To Console    ${i_plus_one}. ${num} is out of acceptable range of (${min} - ${max}).
            VAR    ${return_val}=    ${False}
        ELSE
            Log To Console    ${i_plus_one}. ${num}
        END
    END
    RETURN    ${return_val}

Validate Multiple Results
    [Tags]    robot:private
    [Arguments]    ${perf_results_path_ubuntu}    ${test_name_to_path}    @{reference_data}
    Should Not Be Empty    ${reference_data}
    VAR    ${test_passed}=    ${True}
    FOR    ${compare_values}    IN    @{reference_data}
        ${description_string}    ${expected_value}=    Split String    ${compare_values}    =
        Log To Console    \nResults of the ${description_string}:

        ${test_result_values}=    Read The Results
        ...    ${perf_results_path_ubuntu}
        ...    ${test_name_to_path}
        ...    ${description_string}

        ${result}=    Validate The Results    ${test_result_values}    ${expected_value}
        IF    ${result} == ${False}
            VAR    ${test_passed}=    ${False}
            Log To Console    Test Failed for the: ${description_string}.
        END
    END
    RETURN    ${test_passed}
