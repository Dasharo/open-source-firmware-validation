*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init AUD Fedora
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
AUD001.202 Audio subsystem detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Fedora OS. To do so, we first try to detect
    ...    audio devices in sysfs. Then, we verify no dummy output is present.
    ...    Dummy output only appears when no other sound device is available,
    ...    therefore, presence of it indicate failure to initialize audio for userspace
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}

AUD002.202 Internal Audio playback
    [Documentation]    Check whether the audio subsystem in Fedora is able
    ...    toplayback audio recordings. To do so, first determine presence
    ...    of audio sink. Audio sink must not be a dummy. After it was
    ...    verified, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Switch Active Sink Port Using Pactl    internal
    # TODO: Test playback and waveforms
    # We probably can do it using alsa monitoring device, and capture
    # the sound to check if it was malformed in a way.
    Log    \Internal speakers detected, check validity of sound playback manually\n

AUD003.202 Internal Audio capture
    [Documentation]    Check whether the audio subsystem is able to capture
    ...    audio on Fedora. To do so, we first determine presence of internal
    ...    capture device.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Switch Active Source Port Using Pactl    internal
    Verify Active Source Port Using Pactl    internal
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.202 External headset recognition
    [Documentation]    Check whether Fedora has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones

AUD005.202 External headset audio playback
    [Documentation]    Check whether Fedora has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \nHeadset speakers detected, please verify validity of playback manually\n

AUD006.202 External headset audio capture
    [Documentation]    Check whether Fedora has capability to capture sound
    ...    via external headset.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Verify External Headset Is Plugged In
    Switch Active Source Port Using Pactl    headphones
    Verify Active Source Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \n Headset microphone detected, check validity of sound capture manually\n

AUD007.202 HDMI Audio recognition
    [Documentation]    Check whether the HDMI audio is recognized
    ...    properly in Fedora after connecting HDMI display.
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Switch Active Sink Port Using Pactl    hdmi
    Verify Active Sink Port Using Pactl    hdmi


*** Keywords ***
Init AUD Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
