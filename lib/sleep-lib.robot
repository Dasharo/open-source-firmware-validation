*** Settings ***
Documentation       Collection of keywords related to System Sleep States

Resource            ../keywords.robot


*** Keywords ***
Check If Platform Sleep Type Can Be Selected
    [Documentation]    Check if there is a Platform sleep type option
    VAR    ${PLATFORM_SLEEP_TYPE_SELECTABLE}=    ${FALSE}    scope=GLOBAL
    IF    not ${TESTS_IN_FIRMWARE_SUPPORT}    RETURN
    IF    ${DASHARO_POWER_MGMT_MENU_SUPPORT} == ${FALSE}    RETURN
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    ${selectable}=    Run Keyword And Return Status
    ...    Get Option State
    ...    ${power_menu}
    ...    Platform sleep type
    VAR    ${PLATFORM_SLEEP_TYPE_SELECTABLE}=    ${selectable}    scope=GLOBAL
    Save Changes And Reset

Set Platform Sleep Type
    [Documentation]    Set Platform sleep type to the given value
    [Arguments]    ${platform_sleep_type}
    Power On
    IF    '${platform_sleep_type}' == 'S0ix'
        VAR    ${platform_sleep_type_text}=    Suspend to Idle (S0ix)
    ELSE IF    '${platform_sleep_type}' == 'S3'
        VAR    ${platform_sleep_type_text}=    Suspend to RAM (S3)
    ELSE
        Fail    Wrong Argument
    END
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${power_menu}    Platform sleep type    ${platform_sleep_type_text}
    Save Changes And Reset

Check Platform Sleep Type Is Correct On Linux
    [Documentation]    Check Platform sleep type in Linux
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    IF    '${platform_sleep_type}' == 'S0ix'
        ${power_mem_sleep}=    Execute Command In Terminal    cat /sys/power/mem_sleep
        Should Contain Any    ${power_mem_sleep}    [s2idle] shallow    [s2idle] deep    # S0ix
    ELSE IF    '${platform_sleep_type}' == 'S3'
        ${power_mem_sleep}=    Execute Command In Terminal    cat /sys/power/mem_sleep
        Should Contain    ${power_mem_sleep}    s2idle [deep]    # S3
    END

Detect Or Install FWTS
    [Documentation]    Keyword allows to check if Firmware Test Suite (fwts)
    ...    has been already installed on the device. Otherwise, triggers
    ...    process of obtaining and installation.
    [Arguments]    ${package}=fwts
    VAR    ${is_package_installed}=    ${FALSE}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
        RETURN
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    Log To Console    \nInstalling required package (${package})...
    Get And Install FWTS
    Sleep    10s
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    not ${is_package_installed}
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Get And Install FWTS
    [Documentation]    Keyword allows to obtain and install Firmware Test Suite
    ...    (fwts) tool.
    Set DUT Response Timeout    500s
    Write Into Terminal    add-apt-repository ppa:firmware-testing-team/ppa-fwts-stable
    Read From Terminal Until    Press [ENTER] to continue or Ctrl-c to cancel
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Reading package lists... Done
    Write Into Terminal    apt-get install --assume-yes fwts
    Read From Terminal Until Prompt

Perform Suspend Test Using FWTS
    [Documentation]    Keyword allows to perform suspend and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    VAR    ${is_suspend_performed_correctly}=    ${FALSE}
    VAR    ${test_time_out}=    ${${test_duration}-5}
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log
    Sleep    ${test_duration}s
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        # Clean up console before reading file
        Read From Terminal
        Write Bare Into Terminal    ${ENTER}
        Read From Terminal Until Prompt
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'
        Login To Linux
        Switch To Root User
    END
    ${test_result}=    Execute Command In Terminal    cat /tmp/suspend_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        VAR    ${is_suspend_performed_correctly}=    ${TRUE}
    EXCEPT
        VAR    ${is_suspend_performed_correctly}=    ${FALSE}
    END
    RETURN    ${is_suspend_performed_correctly}

Perform Hibernation Test Using FWTS
    [Documentation]    Keyword allows to perform hibernation and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    VAR    ${is_hibernation_performed_correctly}=    ${FALSE}
    IF    '${POWER_CTRL}' == 'none'    Set Nextboot    ${BOOTED_OS_ID}
    Execute Command In Terminal    fwts s4 -f -r /tmp/hibernation_test_log.log
    Sleep    ${test_duration}s
    Boot System Or From Connected Disk    ${BOOTED_OS_ID}
    Login To Linux
    Switch To Root User
    ${test_result}=    Execute Command In Terminal    cat /tmp/hibernation_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        VAR    ${is_hibernation_performed_correctly}=    ${TRUE}
    EXCEPT
        VAR    ${is_hibernation_performed_correctly}=    ${FALSE}
    END
    RETURN    ${is_hibernation_performed_correctly}

Perform Warmboot Using Rtcwake
    [Documentation]    Executes a command that will cause a warmboot

    # Using "Execute Command In Terimal" will cause the test to wait
    # for command prompt to appear before continuing but the prompt
    # will not appear again until we Login after reboot, so the test
    # would hang here and fail.
    # Sometimes it may take long to shutdown all systemd services,
    # so the waiting times have to be excessive to avoid false negatives.
    IF    '${POWER_CTRL}' == 'none'    Set Nextboot    ${BOOTED_OS_ID}
    Write Into Terminal    rtcwake -m off -s 60
    Set DUT Response Timeout    300s
    Sleep    60s

Perform Suspend And Wake Using Rtcwake
    [Documentation]    Suspends and then wakes up the device after some time

    # Using "Execute Command In Terimal" will cause the test to wait
    # for command prompt to appear before continuing but the prompt
    # will not appear again until we Login after reboot, so the test
    # would hang here and fail.
    # Sometimes it may take long to shutdown all systemd services,
    # so the waiting times have to be excessive to avoid false negatives.
    Write Into Terminal    rtcwake -m ram -s 20
    Set DUT Response Timeout    300s
    Sleep    20s
