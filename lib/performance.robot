*** Settings ***
Documentation       A library file for common tasks related to performance testing

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot


*** Variables ***
${PTS_LATEST_URL}=
...                                 https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
${PTS_DOWNLOAD_PATH}=               C:\pts\pts.zip
${PTS_EXTRACT_PATH}=                C:\pts-extracted\
${PERF_RESULTS_PATH_UBUNTU}=        /var/lib/phoronix-test-suite/test-results
${PERF_RESULTS_PATH_WINDOWS}=       C:\testing\reports\


*** Keywords ***
Detect Or Install Phoronix Test Suite On Ubuntu
    [Documentation]    Detects and installs PTS
    Detect Or Install Package    php-cli
    Detect Or Install Package    php-xml
    # xvfb = x11 virtual frame buffer for GPU testing over SSH
    IF    ${GPU_PERFORMANCE_TESTS_SUPPORT}    Detect Or Install Package    xvfb

    ${out}=    Execute Command In Terminal    test -f /usr/bin/phoronix-test-suite && echo "PTS Installed"
    IF    '${out}' != 'PTS Installed'
        Switch To Root User
        Execute Command In Terminal    wget ${PTS_LATEST_URL}    60
        Execute Command In Terminal    unzip -q -o v10.8.4.zip    120
        ${out}=    Execute Command In Terminal
        ...    cd phoronix-test-suite-10.8.4 && ./install-sh && cd ..    120
        Should Contain    ${out}    Phoronix Test Suite Installation Completed
        Execute Command In Terminal
        ...    rm v10.8.4.zip && rm -r phoronix-test-suite-10.8.4
        Exit From Root User
    END

Setup Phoronix Batch Mode
    [Documentation]    Configure batch mode required for more automated tests
    Write Into Terminal    phoronix-test-suite batch-setup
    Read From Terminal Until    Save test results when in batch mode (Y/n):
    Write Into Terminal    y
    Read From Terminal Until    Open the web browser automatically when in batch mode (y/N):
    Write Into Terminal    n
    Read From Terminal Until    Auto upload the results to OpenBenchmarking.org (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Prompt for test identifier (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Prompt for test description (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Prompt for saved results file-name (Y/n):
    Write Into Terminal    n
    Read From Terminal Until    Run all test options (Y/n):
    Write Into Terminal    n

# Detect Or Install Phoronix Test Suite On Windows
#    [Documentation]    Detects and installs PTS
#    ${out}=    Execute Command In Terminal    Test-Path -Path C:\phoronix-test-suite
#    IF    '${out}' != 'True'
#    Execute Command In Terminal
#    ...    Invoke-WebRequest -Uri ${PTS_LATEST_URL} -OutFile ${PTS_DOWNLOAD_PATH}    60
#    Execute Command In Terminal
#    ...    Expand-Archive -Path ${PTS_DOWNLOAD_PATH} -DestinationPath ${PTS_EXTRACT_PATH} -Force    60
#    Execute Command In Terminal
#    ...    Start-Process -FilePath ${PTS_EXTRACT_PATH}\install.bat -NoNewWindow -Wait    300
#    Execute Command In Terminal
#    ...    Remove-Item -Path ${PTS_DOWNLOAD_PATH} -Force
#    Execute Command In Terminal
#    ...    Remove-Item -Path ${PTS_EXTRACT_PATH} -Force
#    END

# Run GPU Performance Benchmark On Windows
#    [Documentation]    Wrapper for PTS. Run suite, gather and process
#    ...    results. It assumes DUT is booted into Windows
#    ${cmd}=    Set Variable
#    ...    C:\phoronix-test\suite\phoronix-test-suite batch-benchmark
#    ${cmd}=    Catenate    ${cmd}
#    ...    unigine-super AUTOMATIC=1 RESULT_NAME="gpu_test_unigine" UPLOAD_RESULTS=0

#    Execute Command In Terminal    ${cmd}    3600

Run GPU Performance Benchmark On Ubuntu
    [Documentation]    Wrapper for PTS. Run suite, gather and process
    ...    results. It assumes DUT is logged in into regular user
    ...    account on Ubuntu
    ${cmd}=    Set Variable    phoronix-test-suite batch-run
    ${cmd}=    Catenate    ${cmd}
    ...    unigine-super RESULT_NAME="gpu_test_unigine" UPLOAD_RESULTS=0

    ${result}=    Execute Command In Terminal    ${cmd}    timeout=1800
    Should Not Contain    ${result}    The batch mode must first be configured.
    Should Not Contain    ${result}    The following PHP extensions are REQUIRED
