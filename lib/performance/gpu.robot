*** Settings ***
Documentation       OSFV RF Library for GPU performance testing

Resource            ./common.robot


*** Keywords ***
Run GPU Performance Benchmark On Windows
    [Documentation]    Wrapper for PTS. Run suite, gather and process
    ...    results. It assumes DUT is booted into Windows
    ${cmd}=    Set Variable
    ...    C:\phoronix-test\suite\phoronix-test-suite batch-benchmark
    ${cmd}=    Catenate    ${cmd}
    ...    unigine-super AUTOMATIC=1 RESULT_NAME="gpu_test_unigine" UPLOAD_RESULTS=0

    Execute Command In Terminal    ${cmd}    3600

Run GPU Performance Benchmark On Ubuntu
    [Documentation]    Wrapper for PTS. Run suite, gather and process
    ...    results. It assumes DUT is logged in into regular user
    ...    account on Ubuntu
    ${cmd}=    Set Variable    phoronix-test-suite batch-benchmark
    ${cmd}=    Catenate    ${cmd}
    ...    unigine-super AUTOMATIC=1 RESULT_NAME="gpu_test_unigine" UPLOAD_RESULTS=0
