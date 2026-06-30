*** Settings ***
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
ECF001.001 EC firmware external flashing
    [Documentation]    Check whether there is the possibility to flash the DUT EC firmware externally using Arduino.
    Execute Manual Step
    ...    [1/2] Perform EC firmware flashing in accordance with the EC Recovery section from the EC recovery documentation.
    Execute Manual Step    [2/2] Note the results.
    Execute Manual Step
    ...    [Expected result] The output of the last command should contain information about the correctly performed procedure: Successfully programmed SPI ROM
