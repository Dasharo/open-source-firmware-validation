*** Settings ***
Documentation       Collection of keywords related to System Sleep States


*** Keywords ***
Check If Platform Sleep Type Can Be Selected
    [Documentation]    Check if there is a Platform sleep type option
    IF    ${DASHARO_POWER_MGMT_MENU_SUPPORT} == ${FALSE}
        Set Suite Variable    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    ${FALSE}
        RETURN
    END
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    ${platform_sleep_type_selectable}=    Run Keyword And Return Status
    ...    Get Option State
    ...    ${power_menu}
    ...    Platform sleep type
    Set Suite Variable    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    ${platform_sleep_type_selectable}

Set Platform Sleep Type
    [Documentation]    Set Platform sleep type to the given value
    [Arguments]    ${platform_sleep_type}
    Power On
    IF    '${platform_sleep_type}' == 'S0ix'
        Set Local Variable    ${PLATFORM_SLEEP_TYPE_TEXT}    Suspend to Idle (S0ix)
    ELSE IF    '${platform_sleep_type}' == 'S3'
        Set Local Variable    ${PLATFORM_SLEEP_TYPE_TEXT}    Suspend to RAM (S3)
    ELSE
        Fail    Wrong Argument
    END
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${power_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    Set Option State    ${power_menu}    Platform sleep type    ${PLATFORM_SLEEP_TYPE_TEXT}
    Save Changes And Reset

Check Platform Sleep Type Is Correct On Linux
    [Documentation]    Check Platform sleep type in Linux
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    IF    '${platform_sleep_type}' == 'S0ix'
        ${power_mem_sleep}=    Execute Command In Terminal    cat /sys/power/mem_sleep
        Should Contain    ${power_mem_sleep}    [s2idle] shallow    # Six0
    ELSE IF    '${platform_sleep_type}' == 'S3'
        ${power_mem_sleep}=    Execute Command In Terminal    cat /sys/power/mem_sleep
        Should Contain    ${power_mem_sleep}    s2idle [deep]    # S3
    END

Detect Or Install FWTS
    [Documentation]    Keyword allows to check if Firmware Test Suite (fwts)
    ...    has been already installed on the device. Otherwise, triggers
    ...    process of obtaining and installation.
    [Arguments]    ${package}=fwts
    ${is_package_installed}=    Set Variable    ${FALSE}
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
    IF    ${is_package_installed}=='False'
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
    ${is_suspend_performed_correctly}=    Set Variable    ${FALSE}
    Write Into Terminal    fwts s3 -f -r /tmp/suspend_test_log.log
    Sleep    ${test_duration}s
    Login To Linux
    Switch To Root User
    ${test_result}=    Execute Linux Command    cat /tmp/suspend_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_suspend_performed_correctly}=    Set Variable    ${TRUE}
    EXCEPT
        ${is_suspend_performed_correctly}=    Set Variable    ${FALSE}
    END
    RETURN    ${is_suspend_performed_correctly}

Perform Hibernation Test Using FWTS
    [Documentation]    Keyword allows to perform hibernation and resume procedure
    ...    test by using Firmware Test Suite tool
    [Arguments]    ${test_duration}=40
    ${is_hibernation_performed_correctly}=    Set Variable    ${FALSE}
    Execute Command In Terminal    fwts s4 -f -r /tmp/hibernation_test_log.log
    Sleep    ${test_duration}s
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${test_result}=    Execute Command In Terminal    cat /tmp/hibernation_test_log.log
    TRY
        Should Contain    ${test_result}    0 failed
        Should Contain    ${test_result}    0 warning
        Should Contain    ${test_result}    0 aborted
        Should Contain    ${test_result}    0 skipped
        ${is_hibernation_performed_correctly}=    Set Variable    ${TRUE}
    EXCEPT
        ${is_hibernation_performed_correctly}=    Set Variable    ${FALSE}
    END
    RETURN    ${is_hibernation_performed_correctly}
