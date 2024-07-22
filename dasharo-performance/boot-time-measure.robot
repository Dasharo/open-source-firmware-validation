*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${ITERATIONS}=      5


*** Test Cases ***
CBMEM001.001 Serial boot time measure: coreboot booting time after coldboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after coldboot if
    ...    CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM001.001 not supported
    ${average}=    Set Variable    0
    ${measured_durations}=    Create List
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Power Cycle On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${timestamps}=    Get Boot Timestamps
        ${length}=    Get Length    ${timestamps}
        Log Boot Timestamps    ${timestamps}    ${length}
        ${duration}=    Get Duration From Timestamps    ${timestamps}    ${length}
        Append To List    ${measured_durations}    ${duration}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${index}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    ${min}    ${max}    ${deviation}=    Boot Statistics
    ...    ${measured_durations}    ${average}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n 
    Log To Console    \nCoreboot shortest time std dev: ${min} s\n 
    Log To Console    \nCoreboot booting time std dev: ${deviation} s\n 

CBMEM002.001 Serial boot time measure: coreboot booting time after warmboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after warmboot if
    ...    CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM002.001 not supported
    ${average}=    Set Variable    0
    ${measured_durations}=    Create List
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${timestamps}=    Get Boot Timestamps
        ${length}=    Get Length    ${timestamps}
        Log Boot Timestamps    ${timestamps}    ${length}
        ${duration}=    Get Duration From Timestamps    ${timestamps}    ${length}
        Append To List    ${measured_durations}    ${duration}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${index}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    ${min}    ${max}    ${deviation}=    Standard Deviation
    ...    ${measured_durations}    ${average}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n 
    Log To Console    \nCoreboot shortest time std dev: ${min} s\n 
    Log To Console    \nCoreboot booting time std dev: ${deviation} s\n 

CBMEM003.001 Serial boot time measure: coreboot booting time after system reboot
    [Documentation]    Check whether the DUT boots after coldboot and how
    ...    long it takes for coreboot to boot after system reboot
    ...    if CPU is serial initialized.
    Skip If    not ${SERIAL_BOOT_MEASURE}    CBMEM003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CBMEM003.001 not supported
    ${average}=    Set Variable    0
    ${measured_durations}=    Create List
    Power On
    Log To Console    \n
    FOR    ${index}    IN RANGE    0    ${ITERATIONS}
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        ${timestamps}=    Get Boot Timestamps
        ${length}=    Get Length    ${timestamps}
        Log Boot Timestamps    ${timestamps}    ${length}
        ${duration}=    Get Duration From Timestamps    ${timestamps}    ${length}
        Append To List    ${measured_durations}    ${duration}
        ${duration_formatted}=    Evaluate    ${duration}/1000000
        Log To Console    (${index}) Coreboot booting time: ${duration_formatted} s (${duration} ns)
        ${average}=    Evaluate    ${average}+${duration_formatted}
        Write Into Terminal    reboot
    END
    ${average}=    Evaluate    ${average}/${ITERATIONS}
    ${min}    ${max}    ${deviation}=    Standard Deviation
    ...    ${measured_durations}    ${average}

    Log To Console    \nCoreboot average booting time: ${average} s\n
    Log To Console    \nCoreboot longest booting time: ${max} s\n 
    Log To Console    \nCoreboot shortest time std dev: ${min} s\n 
    Log To Console    \nCoreboot booting time std dev: ${deviation} s\n 


*** Keywords ***
Boot Statistics
    [Documentation]    Calculates the standard deviation, min, max of 
    ...    boot time measurements
    [Arguments]    ${samples}    ${average}
    ${standard_deviation}=    Set Variable    0
    ${min}=    Set Variable    99999999
    ${max}=    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${iterations}
        ${duration}=    Get From List    ${samples}    ${index}
        ${min}=    Evaluate    ${min} if ${min} < ${duration} else ${duration}
        ${max}=    Evaluate    ${max} if ${max} > ${duration} else ${duration}
        ${diff}=    Evaluate   ${duration} - ${average} 
        ${diff}=    Evaluate    ${diff}**2
        ${standard_deviation}=    Evaluate    ${standard_deviation} + ${diff}
    END
    RETURN    ${min}    ${max}    ${standard_deviation}

