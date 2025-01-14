*** Settings ***
Documentation       Collection of keywords related to the Power State After
...                 Power Fail option


*** Keywords ***
Simulate Power Failure
    [Documentation]    This keyword simulates a power failure to the DUT.
    ...    It is using osfv_cli libraries which control the power
    ...    via a RTE relay or a sonoff.
    # Use 15 seconds delay because if power is absent for less than roughly 10
    # seconds the platform powers on regardless of the settings (original
    # firmware behaves the same) and waiting 10 seconds doesn't produce stable
    # results.
    Rte Psu Off
    Sleep    15s
    Read From Terminal
    Rte Psu On
