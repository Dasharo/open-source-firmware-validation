*** Settings ***
Library         Collections
Library         Dialogs
Library         OperatingSystem
Library         Process
Library         String
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND
...                 Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}
...                 AND
...                 Detect Or Install Phoronix Test Suite On Windows
# TODO: human-readable representation of setup menu key for all platforms


*** Variables ***
# @{tests}=    smallpt    cachebench    compress-7zip    blake2    crafty
#
# blake2 - szybki (1-2min) - multi
# cachebench - ok 30m - multi - testuje też cache i ram
# compress-7zip - 30min - multi - już na ubuntu
# smallpt - single - 10-15min
# Crafty - xD - single
#
#
#
${DEVIATION_UP}=        1.2    # acceptable deviation +/-20%
${DEVIATION_DOWN}=      0.8
${REF_VAL}=             100


*** Test Cases ***
UPP001.301 Manual Single Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    tbd you can do this test in ssh terminal
    # Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP001.001 not supported
    Pause Execution
    ...    This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
    Execute Manual Step    [1/8] Power on the DUT
    Execute Manual Step    [2/8] Boot into Windows
    Execute Manual Step    [3/8] Login with default login and password
    Execute Manual Step    [4/8] Enter powershell as administrator
    Run A Test Manually    smallpt    100
    Run A Test Manually    crafty    100

UPP001.302 Manual Multi Threaded CPU Benchmark (Windows) (AC)
    [Documentation]    tbd you can do this test in ssh terminal
    # Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    CPP001.001 not supported
    Pause Execution
    ...    This is semi-manual execution, in next step there will be instruction checklist of DUT setup modification.
    Execute Manual Step    [1/8] Power on the DUT
    Execute Manual Step    [2/8] Boot into Windows
    Execute Manual Step    [3/8] Login with default login and password
    Execute Manual Step    [4/8] Enter powershell as administrator
    Run A Test Manually    cachebench    100
    Run A Test Manually    compress-7zip    100
    Run A Test Manually    blake2    100


*** Keywords ***
Run A Test Manually
    [Arguments]    ${test_name}    ${ref_val}

    Log To Console    .\phoronix-test-suite batch-run    ${test_name}
    Execute Manual Step
    ...    [6/8] Execute command in terminal:${\n}.\phoronix-test-suite batch-run    ${test_name}
    Execute Manual Step
    ...    [7/8] Wait until test finishes and prints the results on console
    ${deviation}=    Get Value From User
    ...    [8/8] Enter deviation:
    ${lower_bound}=    Evaluate    ${ref_val} * ${DEVIATION_DOWN}
    ${higher_bound}=    Evaluate    ${ref_val} * ${DEVIATION_UP}
    Log To Console    \n${deviation}
    Log To Console    \n${lower_bound}
    Log To Console    \n${higher_bound}
    IF    ${deviation} > ${higher_bound} or ${deviation} < ${lower_bound}
        Pause Execution    Results are out of acceptable values: ${higher_bound} - ${lower_bound}\n
        Fail    Results are out of acceptable values: ${higher_bound} - ${lower_bound}\n
    END

Detect Or Install Phoronix Test Suite On Windows
    Log To Console    Command: Test-Path "C:\phoronix-test-suite\phoronix-test-suite.batch"
    Execute Manual Step
    ...    [1/2] Execute command in terminal:${\n}Test-Path "C:\phoronix-test-suite\phoronix-test-suite.batch"
    ${out}=    Get Selection From User    What is the output of that command?
    ...    "True"    "False"    "Other"
    IF    ${out} == "True"
        Log To Console    Command: Test-Path "C:\phoronix-test-suite\phoronix-test-suite.batch.bat"
        Execute Manual Step
        ...    [2/2] Execute command in terminal:${\n}Test-Path "C:\phoronix-test-suite\phoronix-test-suite.batch.bat"
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
    Log To Console    Command: Test-Path "C:\phoronix-test-suite\phoronix-test-suite.bat"
    Execute Manual Step
    ...    Installation [1/13] Execute command in terminal: ${\n}Test-Path "C:\phoronix-test-suite\phoronix-test-suite.bat"
    Log To Console    Command: cd C:\
    Execute Manual Step
    ...    Installation [2/13] Execute command in terminal: ${\n}cd C:\
    Log To Console
    ...    Command: Invoke-WebRequest -Uri "https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/heads/master.zip" -OutFile "phoronix-master.zip"
    Execute Manual Step
    ...    Installation [3/13] Execute command in terminal: ${\n}Invoke-WebRequest -Uri "https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/heads/master.zip" -OutFile "phoronix-master.zip"
    # ...    and wait until download completes.
    Log To Console    Command: Expand-Archive -Path "phoronix-master.zip" -DestinationPath "phoronix-master"
    Execute Manual Step
    ...    Installation [4/13] Execute command in terminal: ${\n}Expand-Archive -Path "phoronix-master.zip" -DestinationPath "phoronix-master"
    Log To Console    Command: cd .\phoronix-master\phoronix-test-suite-master
    Execute Manual Step
    ...    Installation [5/13] Execute command in terminal: ${\n}cd .\phoronix-master\phoronix-test-suite-master
    Log To Console    Command: \install.bat
    Execute Manual Step
    ...    Installation [6/13] Execute command in terminal: ${\n}.\install.bat
    Log To Console    Command: cd C:\phoronix-test-suite\
    Execute Manual Step
    ...    Installation [7/13] Execute command in terminal: ${\n}cd C:\phoronix-test-suite\
    Log To Console    Command: .\phoronix-test-suite
    Execute Manual Step
    ...    Installation [8/13] Execute command in terminal: ${\n}.\phoronix-test-suite
    Log To Console    Command: .\phoronix-test-suite install cachebench
    Execute Manual Step
    ...    Installation [9/13] Execute command in terminal: ${\n}.\phoronix-test-suite install cachebench
    Log To Console    Command: .\phoronix-test-suite install smallpt
    Execute Manual Step
    ...    Installation [10/13] Execute command in terminal: ${\n}.\phoronix-test-suite install smallpt
    Log To Console    Command: .\phoronix-test-suite install compress-7zip
    Execute Manual Step
    ...    Installation [11/13] Execute command in terminal: ${\n}.\phoronix-test-suite install compress-7zip
    Log To Console    Command: .\phoronix-test-suite list-installed-tests
    Execute Manual Step
    ...    Installation [12/13] Execute command in terminal: ${\n}.\phoronix-test-suite list-installed-tests
    ${out}=    Get Selections From User    [13/13] Output should contains:
    ...    pts/smallpt    pts/cachebench    pts/compress-7zip
    Log To Console    ${out}
    # TBD!
    # IF    smallpt not in ${out}
    #    Log To Console    good
    # ELSE
    #    Log To Console    bad
    # END

Setup Phoronix Batch Mode
    [Documentation]    Configure batch mode required for more automated tests.
    Log To Console    Command: \phoronix-test-suite batch-setup
    Execute Manual Step
    ...    Batch setup [1/8] Execute command in terminal: ${\n}.\phoronix-test-suite batch-setup
    Execute Manual Step
    ...    Batch setup [2/8]${\n}Save test results when in batch mode (Y/n): Execute command in terminal:${\n}y
    Execute Manual Step
    ...    Batch setup [3/8]${\n}Open the web browser automatically when in batch mode (y/N): Execute command in terminal:${\n}n
    Execute Manual Step
    ...    Batch setup [4/8]${\n}Auto upload the results to OpenBenchmarking.org (Y/n): Execute command in terminal:${\n}n
    Execute Manual Step
    ...    Batch setup [5/8]${\n}Prompt for test identifier (Y/n): Execute command in terminal: ${\n}n
    Execute Manual Step
    ...    Batch setup [6/8]${\n}Prompt for test description (Y/n): Execute command in terminal: ${\n}n
    Execute Manual Step
    ...    Batch setup [7/8]${\n}Prompt for saved results file-name (Y/n): Execute command in terminal: ${\n}n
    Execute Manual Step
    ...    Batch setup [8/8]${\n}Run all test options (Y/n): Execute command in terminal: ${\n}y    # for sure?
