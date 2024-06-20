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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CPU_TESTS_SUPPORT}    CPU tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
CCC001.001 CPU cores count (Ubuntu 22.04)
    [Documentation]    Check CPU cores count.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CCC001.001 not supported
    Power On
    #${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    ${cpu_info}=    Execute Linux Command    lscpu
    Set Suite Variable    ${CPU_INFO}
    ${cpu}=    Get Lines Matching Regexp    ${CPU_INFO}    ^CPU\\(s\\):\\s+\\d+$    flags=MULTILINE
    Should Contain    ${cpu}    ${DEF_THREADS_TOTAL}    Different number of CPU's than ${DEF_THREADS_TOTAL}
    ${online}=    Execute Linux Command    cat /sys/devices/system/cpu/online
    Should Contain    ${online}    ${DEF_ONLINE_CPU}    There are more than ${DEF_ONLINE_CPU[2]} on-line CPU's