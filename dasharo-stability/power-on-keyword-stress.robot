*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
Stress test Power On keyword for stability (N=1)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=2)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=3)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=4)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=5)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=6)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=7)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=8)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=9)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10

Stress test Power On keyword for stability (N=10)
    Power On
    Login to Linux
    Switch to root user
    Execute Command In Terimal    sleep 10
