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
...                     Set Up Platform
...                     AND
...                     Prepare Test Suite
Suite Teardown      Run Keywords
...                     Log Out And Close Connection


*** Test Cases ***
COG001.001 Check memory usage on heavy application
    [Documentation]    This test measures memory usage while running a
    ...    memory-heavy web application in Cog browser.
    ${variables}=    Get Variables
    IF    "\${TIME}" not in $variables
        ${time}=    Set Variable    60
    END
    ${cmd_timeout}=    Evaluate    int($TIME) + 500
    Variable Should Exist    ${HOSTNAME}
    Variable Should Exist    ${WORKDIR}
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}/memory_heavy#
    Execute Command In Terminal    mkdir memory_heavy && cd memory_heavy
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://pixijs.com/8.x/examples/mesh-and-shaders/instanced-geometry
    Execute Command In Terminal    export ${environment}
    Execute Command In Terminal    mem_test "cog ${url}" ${time} 50    ${cmd_timeout}s
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..

COG001.002 Check memory usage on light application
    [Documentation]    This test measures memory usage while running a
    ...    memory-light web application in Cog browser.
    ${variables}=    Get Variables
    IF    "\${TIME}" not in $variables
        ${time}=    Set Variable    60
    END
    ${cmd_timeout}=    Evaluate    int($TIME) + 500
    Variable Should Exist    ${HOSTNAME}
    Variable Should Exist    ${WORKDIR}
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}/memory_light#
    Execute Command In Terminal    mkdir memory_light && cd memory_light
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://www.timeanddate.com/worldclock/
    Execute Command In Terminal    export ${environment}
    Execute Command In Terminal    mem_test "cog ${url}" ${time} 50    ${cmd_timeout}s
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..

COG002.001 Check for memory leaks using Heaptrack
    [Documentation]    This test uses Heaptrack to check for memory leaks in Cog
    ...    browser.
    ${variables}=    Get Variables
    IF    "\${TIME}" not in $variables
        ${time}=    Set Variable    60
    END
    ${cmd_timeout}=    Evaluate    int($TIME) + 30
    Variable Should Exist    ${HOSTNAME}
    Variable Should Exist    ${WORKDIR}
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}/memleaks#
    Execute Command In Terminal    mkdir memleaks && cd memleaks
    ${environment}=    Catenate
    ...    COG_PLATFORM_WL_VIEW_HEIGHT=720 COG_PLATFORM_WL_VIEW_WIDTH=1280
    ...    COG_PLATFORM_WL_VIEW_MAXIMIZE=0 WAYLAND_DISPLAY=wayland-1
    ...    XDG_RUNTIME_DIR=/run/user/0
    ${url}=    Set Variable    https://pixijs.com/8.x/examples/mesh-and-shaders/instanced-geometry
    Execute Command In Terminal    export ${environment}
    #    Heaptrack cannot run in the background
    Write Into Terminal    heap_analyze "cog ${url}"
    Press Enter
    Sleep    ${time}
    Press Key N Times    1    ${CTRL_C}
    Set Prompt For Terminal    root@${HOSTNAME}:${WORKDIR}#
    Execute Command In Terminal    cd ..


*** Keywords ***
Set Up Platform
    Pause Execution    Boot Linux and press OK to conitnue.
    Pause Execution    Log in as root and press OK to continue.
    Pause Execution    If Weston is not running, run in the background with "weston &" and press OK to conitnue.
    Pause Execution    Navigate to the working directory of your choice and press OK to continue.
    Pause Execution    Close the serial connection and press OK to continue
