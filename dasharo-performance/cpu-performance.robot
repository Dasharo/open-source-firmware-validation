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
@{RESOLUTIONS}    HD=361    4K=14444    5K=2568
*** Test Cases ***
CPP001.001 Single Threaded CPU Benchmark (Ubuntu) (AC)
    #TODO: 1K, 4K, 5K
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while connected to power supply.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux    #chyba nie potrzebne bo już jest w Boot System Or From Connected Disk
    Switch To Root User
# #    TODO: Delete, we install PTS during Suite Setup
    Log To Console    Test start
    Run C-Ray Single-thread Render    # na dole
    Run Coremark Single-thread

CPP001.002 Single Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test single threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CPP001.002 not supported
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux    #chyba nie potrzebne bo już jest w Boot System Or From Connected Disk
    Switch To Root User
# #    TODO: Delete, we install PTS during Suite Setup
    Log To Console    Test start
    Run C-Ray Single-thread Render    # na dole
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
    # Power On
    # Boot System Or From Connected Disk    ubuntu
    Login To Linux    #chyba nie potrzebne bo już jest w Boot System Or From Connected Disk
    Switch To Root User
    7-Zip Multi-thread Compression and Decompression Average

CPP002.002 Multi Threaded CPU Benchmark (Ubuntu) (Battery)
    [Documentation]    Test multi threaded performance using phoronix
    ...    test suite, for Ubuntu, while powered by inbuilt battery.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${LAPTOP_PLATFORM}    The Platform is not a Laptop
    Skip If    not ${BATTERY_PRESENT}    Battery not present
    # Power On
    # Boot System Or From Connected Disk    ubuntu
    Login To Linux    #chyba nie potrzebne bo już jest w Boot System Or From Connected Disk
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
    ${get_date}    Set Variable    02032025130620
    Set Global Variable    ${CURRENT_DATE}    ${get_date}
    # ${CURRENT_DATE}=    Get Current Date    result_format=%d%m%Y%H%M%S
    Log To Console    \nData: ${CURRENT_DATE}\n
    ${LAPTOP_PLATFORM}=    Check The Platform Is A Laptop

    # ${test_name_1}=    Set Variable    crayrender
    # Log To Console    \nTest name1: ${test_name_1}
    # ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    # Log To Console    \nTest name2: ${test_name_1}
    # ${date_string}=    Convert Date    result_format=epoch    ${CURRENT_DATE}

Run C-Ray Single-thread Render
    [Documentation]    Run C-Ray benchmark with HD resolution and 1 thread
    ${test_name_1}=    Set Variable    crayrender    #nazwa + data
    Log To Console    \nTest name1: ${test_name_1}
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    Log To Console    \nTest name2: ${test_name_1}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results
    Log To Console    \nrun command
    # ${result}=    Execute Command In Terminal
    # ...    echo 1 | phoronix-test-suite batch-run pts/c-ray TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Resolution: 1080p - Rays Per Pixel: 16
    # ${TEST_AVERAGE}=    Execute Command In Terminal    awk -F '[<>]' '/<Value/ && NF > 1 {print $3}' ${RESULTS_PATH_ROOT}/${TEST_NAME_1}/composite.xml
    Log To Console    TestResutlValue HD: ${test_result_values}
    ${test_passed_HD}=    Validate The Results    ${test_result_values}    361

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Resolution: 4K - Rays Per Pixel: 16
    Log To Console    TestResutlValue 4K: ${test_result_values}
    ${test_passed_4K}=    Validate The Results    ${test_result_values}    1444

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Resolution: 5K - Rays Per Pixel: 16
    Log To Console    TestResutlValue 5K: ${test_result_values}
    ${test_passed_5K}=    Validate The Results    ${test_result_values}    2568

    Should Be True    ${test_passed_HD}
    Should Be True    ${test_passed_4K}
    Should Be True    ${test_passed_5K}

# Validate Multiple Resolutions
#     FOR    ${resolution_string}    IN    @{RESOLUTIONS}
#         ${resolution}    ${expected_value}=    Split String    ${resolution_string}    =

#         ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Resolution: ${resolution_string} - Rays Per Pixel: 16
#         Log To Console    TestResutlValue ${resolution}: ${test_result_values}

#         ${test_passed}=    Validate The Results    ${test_result_values}    ${expected_value}
#         Should Be True    ${test_passed}    msg=Test failed for resolution ${resolution}
#     END

Read The Results
    [Arguments]    ${results_path_root}    ${test_name_1}    ${Test_description}
    Log To Console    get results
    # ${test_result_values}=    Execute Command In Terminal
    # ...    awk -F '[<>]' '/<RawString/ && NF > 1 {print $3}' ${results_path_root}/${test_name_1}/composite.xml
    ${test_result_values}=    Execute Command In Terminal
    ...    awk -F '[<>]' '/<Description>${Test_description}<\\/Description>/ {found=1} found && /<RawString>/ {print $3; found=0}' ${results_path_root}/${test_name_1}/composite.xml
    # ...    awk -F '[<>]' '/<Description>${Test_description}<\\/Description>/ {found=1} found && /<RawString>/ {print $3; found=0}' ${results_path_root}/${test_name_1}/composite.xml
    RETURN    ${test_result_values}

Run Coremark Single-thread
    ${test_name_1}=    Set Variable    crayrender
    Log To Console    \nTest name1: ${test_name_1}
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    Log To Console    \nTest name2: ${test_name_1}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results

    # ${result}=    Execute Command In Terminal    phoronix-test-suite batch-run pts/coremark TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    CoreMark Size 666 - Iterations Per Second
    Log To Console    TestResutlValue: ${test_result_values}
    ${test_passed}=    Validate The Results    ${test_result_values}    69231
    Should Be True    ${test_passed}

7-Zip Multi-thread Compression and Decompression Average
    ${test_name_1}=    Set Variable    crayrender
    Log To Console    \nTest name1: ${test_name_1}
    ${test_name_1}=     Catenate    SEPARATOR=    ${test_name_1}    ${CURRENT_DATE}
    Log To Console    \nTest name2: ${test_name_1}
    ${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results

    # ${result}=    Execute Command In Terminal    phoronix-test-suite batch-run pts/compress-7zip TEST_RESULTS_NAME=${test_name_1}
    # ...    timeout=1800

    ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Test: Compression Rating
    Log To Console    TestResutlValue: ${test_result_values}
    ${test_passed_comp}=    Validate The Results    ${test_result_values}    16147

        ${test_result_values}=    Read The Results    ${results_path_root}    ${test_name_1}    Test: Decompression Rating
    Log To Console    TestResutlValue: ${test_result_values}
    ${test_passed_decomp}=    Validate The Results    ${test_result_values}    9801

    Should Be True    ${test_passed_comp}
    Should Be True    ${test_passed_decomp}

# 7-Zip Multi-thread Decompression Average

Validate The Results
    [Arguments]    ${nums}    ${TA_SERIO_REF_VAL}
    # ${ref_val}=    Convert To Number    ${HD_RENDER}
    ${ref_val}=    Convert To Number    ${TA_SERIO_REF_VAL}
    ${min}=    Evaluate    ${ref_val} * 0.9    #zapytać klienta
    ${max}=    Evaluate    ${ref_val} * 1.1    #zapytać klienta
    ${num_list}=    Split String    ${nums}    separator=:
    ${return_val}=    Set Variable    ${True}

    ${qtty}=    Get Length    ${num_list}
    FOR    ${i}    IN RANGE    ${qtty}
        ${num}=    Convert To Number    ${num_list}[${i}]
        IF    ${num} < ${min} or ${num} > ${max}
            Log To Console    \nThe restult of test ${num} is out of acceptable range of (${min} - ${max}).
            # Log To Console    \nThe restult of test ${num} is out of acceptable range of (${min:.0f} - ${max:.0f}).
            ${return_val}=    Set Variable    ${False}
        END
    END
    RETURN    ${return_val}

