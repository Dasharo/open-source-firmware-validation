*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library    ../venv/lib/python3.13/site-packages/robot/libraries/DateTime.py
Resource            ../lib/performance/reference-values.robot
Resource            ../lib/performance/common.robot
Resource            ../lib/performance/cpu.robot

Suite Setup         Run Keywords
...                     CPU Performance Suite Setup
...                     AND
...                     Skip If    not ${CPU_PERFORMANCE_TESTS_SUPPORT}    CPU temperature measurement tests not supported
...                     AND
...                     Check Power Supply
Suite Teardown      Run Keyword
...                     Log Out And Close Connection
*** Variables ***
@{SginleThreadResTests}    Resolution: 1080p - Rays Per Pixel: 16=361    Resolution: 4K - Rays Per Pixel: 16=1444    Resolution: 5K - Rays Per Pixel: 16=2568
@{MultiThreadTests}    Test: Compression Rating=16147    Test: Decompression Rating=9801

*** Test Cases ***
CPP001.001 Single Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.001 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Run C-Ray Single-thread Render
    Run Coremark Single-thread

CPP001.002 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery is not present
    Skip If    ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Run C-Ray Single-thread Render
    Run Coremark Single-thread

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

CPP002.001 Multi Threaded CPU Benchmark (Ubuntu) (AC)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${AC_CONNECTED}    The platform is not connected to AC
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    7-Zip Multi-thread Compression and Decompression Average

CPP002.002 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Skip If    ${AC_CONNECTED}    AC connected
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    7-Zip Multi-thread Compression and Decompression Average

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
        Execute Linux Command    phoronix-test-suite install c-ray    300
        Execute Linux Command    phoronix-test-suite install compress-7zip    300
        Execute Linux Command    phoronix-test-suite install coremark    300
    END
    # ${get_date}=    Get Current Date    result_format=%d%m%Y%H%M%S    #Date and hour of the start of the test not used globally
    ${get_date}    Set Variable    02032025130620    #manual date for testing
    Set Global Variable    ${CURRENT_DATE}    ${get_date}
    # ${CURRENT_DATE}=    Get Current Date    result_format=%d%m%Y%H%M%S
    ${LAPTOP_PLATFORM}=    Check The Platform Is A Laptop

Run C-Ray Single-thread Render
    [Documentation]    Run C-Ray benchmark with all resolutions (1080p, 4K, 5K) on single thread
    ${test_name_1}=    Set Variable    crayrender    #nazwa + data
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results
    # ${result}=    Execute Command In Terminal
    # ...    echo 1 | phoronix-test-suite batch-run pts/c-ray TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_passed}=    Validate Multiple Results    ${results_path_root}   ${test_name_1}    @{SginleThreadResTests}
    Should Be True    ${test_passed}

Run Coremark Single-thread
    [Documentation]    Run Coremark benchmark on single thread
    ${test_name_1}=    Set Variable    crayrender
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results

    # ${result}=    Execute Command In Terminal    phoronix-test-suite batch-run pts/coremark TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    CoreMark Size 666 - Iterations Per Second
    Log To Console    \nResults of the CoreMark Size 666 - Iterations Per Second:\n
    ${test_passed}=    Validate The Results    ${test_result_values}    69231
    Should Be True    ${test_passed}

7-Zip Multi-thread Compression and Decompression Average
    [Documentation]    Run 7-Zip Multi-thread Compression and Decompression benchmark on multiple threads
    ${test_name_1}=    Set Variable    crayrender
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results

    # ${result}=    Execute Command In Terminal    phoronix-test-suite batch-run pts/compress-7zip TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_passed}=    Validate Multiple Results    ${results_path_root}   ${test_name_1}    @{MultiThreadTests}
    Should Be True    ${test_passed}

Read The Results
    [Arguments]    ${results_path_root}    ${test_name_1}    ${Test_description}
    ${test_result_values}=    Execute Command In Terminal
    ...    awk -F '[<>]' '/<Description>${Test_description}<\\/Description>/ {found=1} found && /<RawString>/ {print $3; found=0}' ${results_path_root}/${test_name_1}/composite.xml
    RETURN    ${test_result_values}

Validate The Results
    [Arguments]    ${nums}    ${TA_SERIO_REF_VAL}
    # ${ref_val}=    Convert To Number    ${HD_RENDER}
    ${ref_val}=    Convert To Number    ${TA_SERIO_REF_VAL}
    ${min}=    Evaluate    ${ref_val} * ${deviation_down}
    ${max}=    Evaluate    ${ref_val} * ${deviation_up}
    ${num_list}=    Split String    ${nums}    separator=:
    ${return_val}=    Set Variable    ${True}

    ${qtty}=    Get Length    ${num_list}
    FOR    ${i}    IN RANGE    ${qtty}
        ${num}=    Convert To Number    ${num_list}[${i}]
        ${i_plusOne}    Evaluate    ${i} + 1
        IF    ${num} < ${min} or ${num} > ${max}
            Log To Console    ${i_plusOne}. ${num} is out of acceptable range of (${min} - ${max}).
            # Log To Console    \nThe restult of test ${num} is out of acceptable range of (${min:.0f} - ${max:.0f}).
            ${return_val}=    Set Variable    ${False}
        ELSE
            Log To Console    ${i_plusOne}. ${num}
        END
    END
    RETURN    ${return_val}

Validate Multiple Results
    [Arguments]    ${results_path_root}    ${test_name_1}    @{REFERENCE_DATA}
    ${test_passed}=    Set Variable    ${True}
    FOR    ${compare_values}    IN    @{REFERENCE_DATA}
        ${Description_string}    ${expected_value}=    Split String    ${compare_values}    =
        Log To Console    \nResults of the ${Description_string}:

        ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    ${Description_string}

        ${result}=    Validate The Results    ${test_result_values}    ${expected_value}

        # ${result}=    ${test_passed}    msg=Test failed for resolution ${Description_string}
        IF    ${result} == ${False}
            ${test_passed}=    Set Variable    ${False}
            Log To Console    Test Failed for the: ${Description_string}.
        END
    END
    RETURN    ${test_passed}
