*** Settings ***
Documentation       Collection of keywords related to the Power State After
...                 Power Fail option


*** Keywords ***
Simulate Power Failure
    [Documentation]    This keyword simulates a power failure to the DUT,
    ...    preferably using sonoff. If it's unavailable, the fallback is RTE.
    IF    'sonoff' == '${POWER_CTRL}'
        Sonoff Power Off
        Sleep    10s
        Sonoff Power On
    ELSE
        RteCtrl Relay
        Sleep    10s
        RteCtrl Relay
    END
