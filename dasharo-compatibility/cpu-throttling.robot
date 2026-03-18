*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=300 seconds
Library             RequestsLibrary
Resource            ../lib/performance/cpu.robot
Resource            ../lib/sensors/sensors.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
THR001.101 Try to enter a threshold value that's above the limit (EDK2 UEFI)
    [Documentation]    Verify that a threshold value that's above the limit
    ...    will get rejected with a proper prompt
    Skip If    not "${OPTIONS_LIB}" == "options-lib_uefi-setup-menu"
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Set UEFI Option    CpuThrottlingThreshold    25    # Set for reference
    Set UEFI Option    CpuThrottlingThreshold    200    # This will get abbreviated to 20
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_sys_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Dasharo System Features
    ${pwr_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${dasharo_sys_menu}
    ...    Power Management Options
    ${cpu_throttling}=    Get Option State    ${pwr_mgr_menu}    CPU Throttling
    ${current_cpu_throttling}=    Get Option State    ${pwr_mgr_menu}    Current CPU Throttling
    Should Be Equal    ${cpu_throttling}    20
    ${cpu_throttling_setpoint}=    Evaluate    ${MAX_CPU_TEMP_THRESHOLD} - 20
    Should Be Equal As Strings    ${current_cpu_throttling}    ${cpu_throttling_setpoint}

THR002.101 Try to enter a threshold value that's below the limit (EDK2 UEFI)
    [Documentation]    Verify that a threshold value that's below the limit
    ...    will get rejected with a proper prompt
    Skip If    not "${OPTIONS_LIB}" == "options-lib_uefi-setup-menu"
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Set UEFI Option    CpuThrottlingThreshold    -10
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_sys_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Dasharo System Features
    ${pwr_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${dasharo_sys_menu}
    ...    Power Management Options
    ${cpu_throttling}=    Get Option State    ${pwr_mgr_menu}    CPU Throttling
    ${current_cpu_throttling}=    Get Option State    ${pwr_mgr_menu}    Current CPU Throttling
    Should Be Equal    ${cpu_throttling}    10
    ${cpu_throttling_setpoint}=    Evaluate    ${MAX_CPU_TEMP_THRESHOLD} - 10
    Should Be Equal As Strings    ${current_cpu_throttling}    ${cpu_throttling_setpoint}

THR003.201 Try to enter a threshold value within the limits and verify in Ubuntu (Ubuntu)
    [Documentation]    Verify whether a reasonable throttling threshold will
    ...    take effect in Ubuntu
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    THR003.201 not supported
    Import Variables    ${CURDIR}/../platform-configs/${SENSORS_CONFIG_FILE}
    Set UEFI Option    CpuThrottlingThreshold    70
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Stress Test
    Sleep    5s    # Wait until the stress load gets to "heat up" the CPU
    ${out}=    Execute Command In Terminal    sensors
    ${temperature}=    Get CPU Temperature
    Should Be True    ${temperature} < 73    # needs a bit of a margin
