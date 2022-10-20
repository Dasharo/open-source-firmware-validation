*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

Suite Setup       Run Keyword    Prepare Test Suite
Suite Teardown    Run Keyword    Log Out And Close Connection

Resource    ../lib/sonoffctrl.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../snipeit-rest-api/snipeit-api.robot
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot

*** Test Cases ***
