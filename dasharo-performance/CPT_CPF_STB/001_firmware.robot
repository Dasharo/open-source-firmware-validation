*** Settings ***
Metadata        ORDER_SENSITIVE

Resource        ./common.resource

Suite Setup     Run Keywords
...                 Prepare Test Suite

Default Tags    semiauto


*** Test Cases ***
STB001.001 Verify if no reboot occurs in the firmware
    [Documentation]    Check whether the firmware remains stable without unexpected
    ...    reboots during the firmware execution phase.
    Execute Manual Step    [1/3] Power on the DUT and observe the firmware boot process (POST and UEFI)
    Execute Manual Step    [2/3] Let the firmware run for an extended period (or observe POST completion)
    Execute Manual Step    [3/3] Confirm no unexpected reboots or resets occurred during the firmware execution
