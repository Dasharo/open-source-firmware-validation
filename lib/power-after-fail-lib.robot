*** Settings ***
Documentation       Collection of keywords related to the Power State After
...                 Power Fail option


*** Keywords ***
Simulate Power Failure
    [Documentation]    This keyword simulates a power failure to the DUT,
    ...    preferably using sonoff. If it's unavailable, the fallback is RTE.
    # Use 15 seconds delay because if power is absent for less than roughly 10
    # seconds the platform powers on regardless of the settings (original
    # firmware behaves the same) and waiting 10 seconds doesn't produce stable
    # results.
    IF    'sonoff' == '${POWER_CTRL}'
        Sonoff Power Off
        Sleep    15s
        Read From Terminal
        Sonoff Power On
    ELSE
        RteCtrl Relay
        Sleep    15s
        Read From Terminal
        RteCtrl Relay
    END
