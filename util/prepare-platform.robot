*** Settings ***
Library     Collections
Library     OperatingSystem
Library     Process
Library     String
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     SSHLibrary    timeout=90 seconds
Library     RequestsLibrary
Resource    ../variables.robot
Resource    ../keywords.robot
Resource    ../keys.robot
Resource    ../lib/prepare-platform.resource


*** Test Cases ***
Run Prepare Platform
    Prepare Platform
