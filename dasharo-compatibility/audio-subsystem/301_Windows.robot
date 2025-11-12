*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...    Prepare Test Suite
...    AND    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    Windows not supported
...    AND    Init AUD Windows
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
AUD001.301 Audio subsystem detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Windows 11. To do so, we attemptt detection
    ...    of the Audio Service, and verify it is in Running state.
    ${out}=    Execute Command In Terminal    Get-Service | Where-Object { $_.Name -eq "Audiosrv" }
    Should Contain    ${out}    Running

AUD002.301 Internal Audio playback
    [Documentation]    Check whether the audio subsystem is able to playback
    ...    audio recordings. To do so, first determine presence of audio sink.
    ...    After that, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    ${out}=    Get Sound Devices In Windows    speakers
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_INTERNAL_OUT}
    Should Contain    ${out}    OK

    # TODO: Somehow verify that sound played is proper, no ideas on how to do it
    # for windows, besides claiming this test as semi-auto.
    Log    \Internal speakers detected, check validity of sound playback manually\n

AUD003.301 Internal Audio capture
    [Documentation]    Check whether the audio subsystem is able to capture
    ...    audio on Windows. To do so, we first determine presence of internal
    ...    capture device.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    ${out}=    Get Sound Devices In Windows    microphone
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_INTERNAL_IN}
    Should Contain    ${out}    OK
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.301 External headset recognition
    [Documentation]    Check whether Windows has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    ${out}=    Get Sound Devices In Windows    headphones
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HEADSET_OUT}
    Should Contain    ${out}    OK

AUD005.301 External headset audio playback
    [Documentation]    Check whether Windows has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    ${out}=    Get Sound Devices In Windows    headphones
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HEADSET_OUT}
    Should Contain    ${out}    OK
    # TODO: Use some software to record back. We could use modified headphones,
    # in which the microphone is physically attached to the speaker.
    Log    \nHeadset speakers detected, please verify validity of playback manually\n

AUD006.301 External headset audio capture
    [Documentation]    Check whether the external headset is recognized
    ...    properly after plugging in micro jack into slot.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    ${out}=    Get Sound Devices In Windows    microphone
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HEADSET_IN}
    Should Contain    ${out}    OK
    # TODO: If possible, use some software to capture sound, and compare
    # waveforms with original audio, to verify it was not malformed.
    Log    \n Headset microphone detected, check validity of sound capture manually\n

AUD007.301 HDMI Audio recognition
    [Documentation]    Check whether the HDMI audio is recognized
    ...    properly in Windows 11 after connecting HDMI display.
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    ${out}=    Get Sound Devices In Windows    display
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HDMI_OUT}
    Should Contain    ${out}    OK


*** Keywords ***
Init AUD Windows
    Power On
    Login To Windows