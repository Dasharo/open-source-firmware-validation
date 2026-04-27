*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init AUD Ubuntu
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
AUD001.201 Audio subsystem detection (Ubuntu)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Ubuntu OS. To do so, we first try to detect
    ...    audio devices in sysfs. Then, we verify no dummy output is present.
    ...    Dummy output only appears when no other sound device is available,
    ...    therefore, presence of it indicate failure to initialize audio for userspace
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    ${out}=    Execute Command In Terminal    pactl list sinks
    ${result}=    Run Keyword And Ignore Error
    ...    Should Not Contain    ${out}    device.description = "Dummy Output"
    IF    '${result}[0]' == 'FAIL'
        Log    \nSound Card was found, but PulseAudio did not found any device\n    WARN
    END

AUD002.201 Internal speaker audio playback (Ubuntu)
    [Documentation]    Check whether the audio subsystem in Ubuntu is able
    ...    toplayback audio recordings. To do so, first determine presence
    ...    of audio sink. Audio sink must not be a dummy. After it was
    ...    verified, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Sink Port Using Pactl    internal
    Verify Active Sink Port Using Pactl    internal
    # TODO: Test playback and waveforms
    # We probably can do it using alsa monitoring device, and capture
    # the sound to check if it was malformed in a way.
    Log    \Internal speakers detected, check validity of sound playback manually\n

AUD003.201 Internal microphone audio capture (Ubuntu)
    [Documentation]    Check whether the audio subsystem is able to capture
    ...    audio on Ubuntu. To do so, we first determine presence of internal
    ...    capture device.
    [Tags]    semiauto
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Source Port Using Pactl    internal
    Verify Active Source Port Using Pactl    internal
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.201 External headset recognition (Ubuntu)
    [Documentation]    Check whether Ubuntu has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones

AUD005.201 External headset audio playback (Ubuntu)
    [Documentation]    Check whether Ubuntu has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \nHeadset speakers detected, please verify validity of playback manually\n

AUD006.201 External headset audio capture (Ubuntu)
    [Documentation]    Check whether Ubuntu has capability to capture sound
    ...    via external headset.
    [Tags]    semiauto
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Source Port Using Pactl    headphones
    Verify Active Source Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \n Headset microphone detected, check validity of sound capture manually\n

AUD007.201 HDMI audio recognition (Ubuntu)
    [Documentation]    Check whether the HDMI audio is recognized
    ...    properly in Ubuntu after connecting HDMI display.
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Sink Port Using Pactl    hdmi
    Verify Active Sink Port Using Pactl    hdmi

AUD008.201 HDMI audio playback (Ubuntu)
    [Documentation]    Check whether Ubuntu is able to play back audio
    ...    via an HDMI-connected display.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Execute Manual Step    [1/5] Power on the DUT
    Execute Manual Step    [2/5] Connect an external display via HDMI and boot into Ubuntu
    Execute Manual Step
    ...    [3/5] Open a terminal and set HDMI as active output: pactl set-sink-port @DEFAULT_SINK@ hdmi-output-0
    Execute Manual Step    [4/5] Play an audio file: paplay /usr/share/sounds/alsa/Front_Center.wav
    Execute Manual Step    [5/5] Confirm that audio is audible from the HDMI-connected display speakers


*** Keywords ***
Init AUD Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
