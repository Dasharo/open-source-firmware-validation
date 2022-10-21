*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections
Library     ../../lib/TestingStands.py

Suite Setup       Run Keyword    Prepare Test Suite
Suite Teardown    Run Keyword    Log Out And Close Connection

Resource    ../keywords.robot

*** Test Cases ***

TEST CASE 1
    ${cpuid}=    Get Rte Cpuid    192.168.4.2331
