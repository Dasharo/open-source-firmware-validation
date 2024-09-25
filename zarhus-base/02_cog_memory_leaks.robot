*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# Required setup keywords:
# Prepare Test Suite - elementary setup keyword for all tests.
# Upload Required Images - uploads all required files onto the PiKVM.
# Required teardown keywords:
# Log Out And Close Connection - elementary teardown keyword for all tests.
Suite Setup         Run Keywords
...                     Pause Execution
...                     Log in as root and close the serial connection, then press OK to conitnue.
...                     AND
...                     Prepare Test Suite
...                     AND
...                     Set Up Variables
...                     AND
...                     Set Up Platform
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Test Cases ***
COG001.001 Check memory usage on resource-intensive application
    [Documentation]    This test measures memory usage while running a
    ...    memory-heavy web application in Cog browser.
    ${cmd_timeout}=    Evaluate    int(${TIME}) + 500
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}/memory_heavy#
    Execute Command In Terminal    mkdir memory_heavy && cd memory_heavy
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://pixijs.com/8.x/examples/mesh-and-shaders/instanced-geometry
    Execute Command In Terminal    export ${environment}
    Execute Command In Terminal    mem_test "cog ${url}" ${TIME} 50    ${cmd_timeout}s
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..

COG001.002 Check memory usage on lightweight application
    [Documentation]    This test measures memory usage while running a
    ...    memory-light web application in Cog browser.
    ${cmd_timeout}=    Evaluate    int(${TIME}) + 500
    Execute Command In Terminal    mkdir memory_light && cd memory_light
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://www.timeanddate.com/worldclock/
    Execute Command In Terminal    export ${environment}
    Execute Command In Terminal    mem_test "cog ${url}" ${TIME} 50    ${cmd_timeout}s
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..

COG002.001 Check for memory leaks using Heaptrack
    [Documentation]    This test uses Heaptrack to check for memory leaks in Cog
    ...    browser.
    ${cmd_timeout}=    Evaluate    int(${TIME}) + 500
    Execute Command In Terminal    mkdir memleaks && cd memleaks
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://pixijs.com/8.x/examples/mesh-and-shaders/instanced-geometry
    Execute Command In Terminal    export ${environment}
    #    Heaptrack cannot run in the background
    Write Into Terminal    heaptrack cog ${url}
    Press Enter
    Sleep    ${TIME}
    Press Key N Times    1    ${CTRL_C}
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..


*** Keywords ***
Set Up Platform
    Execute Command In Terminal    kill $(pgrep weston | head -n 1)
    Execute Command In Terminal    weston &
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    mkdir ${WORKDIR} && cd ${WORKDIR}

Set Up Variables
    ${out}=    Run Keyword And Return Status    Variable Should Exist    ${TIME}
    IF    ${out} == False
        ${time}=    Set Variable    60
    END
    Variable Should Exist    ${HOSTNAME}
    Variable Should Exist    ${WORKDIR}
    Set Prompt For Terminal    root@${HOSTNAME}:~#
