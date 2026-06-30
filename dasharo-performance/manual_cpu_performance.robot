*** Settings ***
Library         Collections
Library         OperatingSystem
Library         Process
Library         String
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND
...                 Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Tests in Windows not supported
...                 AND
...                 Pause Execution    It is advised to run this test via Powershell by ssh
...                 AND
...                 Detect Or Install Phoronix Test Suite On Windows

# TODO: human-readable representation of setup menu key for all platforms
Default Tags    semiauto


*** Variables ***
${DEVIATION}=       0.2
${RUNS_AMOUNT}=     3


*** Test Cases ***
UPP001.301 Manual Single Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    tbd you can do this test in ssh terminal
    Pause Execution
    ...    This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
    Execute Manual Step    Single Threaded [1/8] Power on the DUT
    Execute Manual Step    Single Threaded [2/8] Boot into Windows
    Execute Manual Step    Single Threaded [3/8] Login with default login and password
    Execute Manual Step    Single Threaded [4/8] Enter powershell as administrator
    Run Supported Benchmarks    singlecore

UPP002.301 Manual Multi Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    tbd you can do this test in ssh terminal
    Pause Execution
    ...    This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
    Execute Manual Step    [1/8] Power on the DUT
    Execute Manual Step    [2/8] Boot into Windows
    Execute Manual Step    [3/8] Login with default login and password
    Execute Manual Step    [4/8] Enter powershell as administrator
    Run Supported Benchmarks    multicore


*** Keywords ***
Run Supported Benchmarks
    [Documentation]    Runs all benchmarks by the given type
    [Arguments]    ${target_type}    # singlecore / multicore

    VAR    ${any_failed}=    ${FALSE}
    VAR    @{errors}=    @{EMPTY}
    FOR    ${benchmark_dict}    IN    @{UPP_BENCHMARKS}
        ${type}=    Get From Dictionary    ${benchmark_dict}    type
        IF    '${type}' == '${target_type}'
            ${result}    ${msg}=    Run A Test Manually    ${benchmark_dict}
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

Run A Test Manually
    [Documentation]    Conducting the whole test manually and comparing its result
    ...    with reference value.
    [Arguments]    ${benchmark_dict}
    ${phoronix_test_name}=    Get From Dictionary    ${benchmark_dict}    name
    ${ref_score}=    Get From Dictionary    ${benchmark_dict}    score
    ${scale}=    Get From Dictionary    ${benchmark_dict}    scale
    ${deviation}=    Get From Dictionary    ${benchmark_dict}    dev
    ${deviation_percent}=    Evaluate    float(${deviation})*100
    Log To Console
    ...    ${\n}$env:FORCE_TIMES_TO_RUN=${RUNS_AMOUNT}; .\\phoronix-test-suite batch-run ${phoronix_test_name}
    Execute Manual Step
    ...    [6/8] Execute command in terminal:${\n}$env:FORCE_TIMES_TO_RUN=${RUNS_AMOUNT}; .\\phoronix-test-suite batch-run ${phoronix_test_name}
    Execute Manual Step
    ...    [7/8] Wait until test finishes and prints the results on console
    ${benchmark_score}=    Get Value From User
    ...    [8/8] Enter benchmark score:
    ${lower_bound}=    Evaluate    ${ref_score} * (1 - ${deviation})
    ${higher_bound}=    Evaluate    ${ref_score} * (1 + ${deviation})

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
    END
    VAR    ${msg}=    ${phoronix_test_name}: The measured score of ${benchmark_score}
    ...    is acceptable for reference value of ${ref_score}
    Log    ${msg}    CONSOLE
    RETURN    ${TRUE}    ${msg}

Detect Or Install Phoronix Test Suite On Windows
    [Documentation]    Detecting Or Installing Phoronix Test Suite On Windows
    Log To Console    Command: Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.batch"
    Execute Manual Step
    ...    [1/2] Execute command in terminal:${\n}Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.batch"
    ${out}=    Get Selection From User    What is the output of that command?
    ...    "True"    "False"    "Other"
    IF    ${out} == "True"
        Log To Console    Command: Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.batch.bat"
        Execute Manual Step
        ...    [2/2] Execute command in terminal:${\n}Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.batch.bat"
        ${out}=    Get Selection From User    What is the output of that command?
        ...    "True"    "False"    "Other"
        # TBD
    ELSE IF    ${out} == "False"
        Install Phoronix On Windows Manually
        Setup Phoronix Batch Mode
    ELSE
        Pause Execution    Error, the process will now kill itself
        Fail    Different Output
    END

Install Phoronix On Windows Manually
    [Documentation]    Installing Phoronix On Windows Manually
    VAR    @{tests}=    @{EMPTY}
    FOR    ${benchmark}    IN    @{UPP_BENCHMARKS}
        ${name}=    Get From Dictionary    ${benchmark}    name
        Append To List    ${tests}    ${name}
    END
    Log To Console    Command: Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.bat"
    Execute Manual Step
    ...    Installation [1/14] Execute command in terminal: ${\n}Test-Path "C:\\phoronix-test-suite\\phoronix-test-suite.bat"
    Log To Console    Command: cd C:\\
    Execute Manual Step
    ...    Installation [1/14] Execute command in terminal: ${\n}cd C:\\
    Log To Console
    ...    Command: Invoke-WebRequest -Uri "https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/heads/master.zip" -OutFile "phoronix-master.zip"
    Execute Manual Step
    ...    Installation [2/14] Execute command in terminal: ${\n}Invoke-WebRequest -Uri "https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/heads/master.zip" -OutFile "phoronix-master.zip"
    Log To Console    Command: Expand-Archive -Path "phoronix-master.zip" -DestinationPath "phoronix-master"
    Execute Manual Step
    ...    Installation [3/14] Execute command in terminal: ${\n}Expand-Archive -Path "phoronix-master.zip" -DestinationPath "phoronix-master"
    Log To Console    Command: cd .\\phoronix-master\\phoronix-test-suite-master
    Execute Manual Step
    ...    Installation [4/14] Execute command in terminal: ${\n}cd .\\phoronix-master\\phoronix-test-suite-master
    Log To Console    Command: .\\install.bat
    Execute Manual Step
    ...    Installation [5/14] Execute command in terminal: ${\n}.\\install.bat
    Log To Console    Command: cd C:\\phoronix-test-suite\\
    Execute Manual Step
    ...    Installation [6/14] Execute command in terminal: ${\n}cd C:\\phoronix-test-suite\\
    Log To Console    Command: .\\phoronix-test-suite
    Execute Manual Step
    ...    Installation [7/14] Execute command in terminal: ${\n}.\\phoronix-test-suite - this may take a long time to execute
    Log To Console    Command: .\\phoronix-test-suite install ${tests}[0]
    Execute Manual Step
    ...    Installation [8/14] Execute command in terminal: ${\n}.\\phoronix-test-suite install ${tests}[0]
    Log To Console    Command: .\\phoronix-test-suite install ${tests}[1]
    Execute Manual Step
    ...    Installation [9/14] Execute command in terminal: ${\n}.\\phoronix-test-suite install ${tests}[1]
    Log To Console    Command: .\\phoronix-test-suite install ${tests}[2]
    Execute Manual Step
    ...    Installation [10/14] Execute command in terminal: ${\n}.\\phoronix-test-suite install ${tests}[2]
    Log To Console    Command: .\\phoronix-test-suite install ${tests}[3]
    Execute Manual Step
    ...    Installation [11/14] Execute command in terminal: ${\n}.\\phoronix-test-suite install ${tests}[3]
    Log To Console    Command: .\\phoronix-test-suite list-installed-tests
    Execute Manual Step
    ...    Installation [13/14] Execute command in terminal: ${\n}.\\phoronix-test-suite list-installed-tests
    ${out}=    Get Selections From User    [14/14] Output should contain:
    ...    @{tests}

    IF    ${tests} != ${out}    Fail    Not all tests installed

Setup Phoronix Batch Mode
    [Documentation]    Configure batch mode required for more automated tests.
    Log To Console    Command: .\\phoronix-test-suite batch-setup
    Execute Manual Step
    ...    Batch setup [1/8] Execute command in terminal: ${\n}.\\phoronix-test-suite batch-setup
    Execute Manual Step
    ...    Batch setup [2/8]${\n}Save test results when in batch mode (Y/n):${\n}Execute command in terminal: y
    Execute Manual Step
    ...    Batch setup [3/8]${\n}Open the web browser automatically when in batch mode (y/N):${\n}Execute command in terminal: n
    Execute Manual Step
    ...    Batch setup [4/8]${\n}Auto upload the results to OpenBenchmarking.org (Y/n):${\n}Execute command in terminal: y
    Execute Manual Step
    ...    Batch setup [5/8]${\n}Prompt for test identifier (Y/n):${\n}Execute command in terminal: n
    Execute Manual Step
    ...    Batch setup [6/8]${\n}Prompt for test description (Y/n):${\n}Execute command in terminal: n
    Execute Manual Step
    ...    Batch setup [7/8]${\n}Prompt for saved results file-name (Y/n):${\n}Execute command in terminal: n
    Execute Manual Step
    ...    Batch setup [8/8]${\n}Run all test options (Y/n):${\n}Execute command in terminal: y
