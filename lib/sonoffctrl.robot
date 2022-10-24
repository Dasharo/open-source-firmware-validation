*** Keywords ***
# These keywords assume that RTE and Sonoff might be in another subnet. It 
# would be advisable to rethink them in the future: maybe we should control 
# Sonoff from RTE again but by using the net hosting by RTE

Sonoff Power On
    [Arguments]    ${ip}
    Run    wget -q -O - http://${ip}/switch/sonoff_s20_relay/turn_on --method=POST

Sonoff Power Off
    [Arguments]    ${ip}
    Run    wget -q -O - http://${ip}/switch/sonoff_s20_relay/turn_off --method=POST

Sonoff Toggle
    [Arguments]    ${ip}
    Run    wget -q -O - http://${ip}/switch/sonoff_s20_relay/toggle --method=POST

Sonoff Get State
    [Documentation]    Return current state of sonoff swtich. Correct values are
    ...                "ON" and "OFF".
    [Arguments]    ${ip}
    ${s}=    Run
    ...    wget -q -O - http://${ip}/switch/sonoff_s20_relay
    ${s}=    evaluate    json.loads('''${s}''')    json
    [Return]    ${s['state']}
