*** Settings ***
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Resource            ../lib/performance/gpu.robot

Suite Setup         GPU Performance Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
GPP001.201 GPU Performance Measure (Ubuntu) (AC)
    [Documentation]    Test GPU performance for Ubuntu on AC
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    not ${AC_CONNECTED}    Cannot run this test on battery
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    # Pass condition, that is at least 90% of original benchmark
    ${pass_cond}=    Evaluate    ${UNIGINE_SUPERPOSITION_RESULT_AC} * 0.9
    ${result}=    Run Unigine Superposition On Ubuntu
    Log To Console    \nAverage FPS: ${result}
    IF    ${result} < ${pass_cond}
        Fail    GPU AC performance lower than expected!
    END

GPP002.201 GPU Performance Measure (Ubuntu) (Battery)
    [Documentation]    Test GPU performance for Ubuntu on Battery
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Skip If    ${AC_CONNECTED}    You must run this test on battery
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    ${power_level}=    Check Battery Level On Linux
    # This test runtime is ~11 minutes, probably should be good on more than 25%
    Skip If    ${power_level} < 25    Insufficient Battery Charge to perform this test
    # Pass condition, that is at least 90% of original benchmark
    ${pass_cond}=    Evaluate    ${UNIGINE_SUPERPOSITION_RESULT_BAT} * 0.9
    ${result}=    Run Unigine Superposition On Ubuntu
    Log To Console    \nAverage FPS: ${result}
    IF    ${result} < ${pass_cond}
        Fail    GPU battery performance lower than expected!
    END


*** Keywords ***
GPU Performance Suite Setup
    [Documentation]    Load config and download tooling for supported OSes
    Prepare Test Suite
    Skip If    not ${GPU_PERFORMANCE_TESTS_SUPPORT}
    ${get_date}=    Get Current Date    result_format=%d%m%Y%H%M%S
    VAR    ${CURRENT_DATE}=    ${get_date}    scope=GLOBAL

    IF    ${TESTS_IN_UBUNTU_SUPPORT}
        Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
        Login To Linux
        Execute Manual Step    Please ensure DUT has active desktop session
        ...    by logging into X11 Gnome Desktop.
        Detect Or Install Phoronix Test Suite On Ubuntu

        # Error redirection; for unknown reason to me, DTS throws
        # "sh: 1: kill: No such process" from time to time
        ${out}=    Execute Command In Terminal
        ...    phoronix-test-suite list-installed-tests 2>/dev/null | grep "pts/unigine-super"

        IF    '${out}' == '${EMPTY}'
            # 10 Minute timeout to download ~1.5GB
            Execute Linux Command    DISPLAY=:0 phoronix-test-suite install-test unigine-super    600
            Read From Terminal Until Prompt
        END

        Setup Phoronix Batch Mode
    END

    Check Power Supply
