*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

Suite Setup       Prepare platform    ${fw_file}

Resource    ../lib/sonoffctrl.robot
Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../snipeit-rest-api/snipeit-api.robot
Resource    ../variables.robot
Resource    ../keywords.robot

*** Keywords ***
