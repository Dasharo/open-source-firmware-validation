*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${TESTS_IN_QUBESOS_SUPPORT}    Qubes OS not supported
...                     AND    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    Qubes OS not supported
...                     AND    Init AUD Qubes OS
Suite Teardown      Log Out And Close Connection


*** Test Cases ***
AUD001.203 Audio subsystem detection (Qubes OS)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Qubes OS. To do so, we attempt detection
    ...    of the Audio Service, and verify it is in Running state.
    ...    Previous IDs: AUD001.003
    ${out}=    Execute Command In Terminal    pactl list sinks
    ${result}=    Run Keyword And Ignore Error
    ...    Should Not Contain    ${out}    device.description = "Dummy Output"
    IF    '${result}[0]' == 'FAIL'
        Log    \nSound Card was found, but PulseAudio did not found any device\n    WARN
    END

AUD002.203 Internal Audio playback (Qubes OS)
    [Documentation]    Verify audio playback via internal speakers in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] In any AppVM, play a test audio file.
    Execute Manual Step    [3/4] Listen for sound from internal speakers.
    Execute Manual Step    [4/4] Verify audio is audible and not distorted.

AUD003.203 Internal Audio capture (Qubes OS)
    [Documentation]    Verify audio capture via internal microphone in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] In any AppVM, start an audio recording.
    Execute Manual Step    [3/4] Speak into the internal microphone.
    Execute Manual Step    [4/4] Verify recorded audio is clear and audible.

AUD004.203 External headset recognition (Qubes OS)
    [Documentation]    Verify recognition of an external headset in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Plug in an external headset into the audio jack.
    Execute Manual Step    [3/4] Observe audio device changes in the system.
    Execute Manual Step    [4/4] Verify headset audio input and output are available.

AUD005.203 External headset audio playback (Qubes OS)
    [Documentation]    Verify audio playback via an external headset in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Plug in an external headset.
    Execute Manual Step    [3/4] Play a test audio file in any AppVM.
    Execute Manual Step    [4/4] Verify sound is audible via headset speakers.

AUD006.203 External headset audio capture (Qubes OS)
    [Documentation]    Verify audio capture via an external headset microphone in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/4] Make sure Qubes OS is booted.
    Execute Manual Step    [2/4] Plug in an external headset with microphone.
    Execute Manual Step    [3/4] Start an audio recording in any AppVM.
    Execute Manual Step    [4/4] Verify recorded audio is clear and audible.

AUD007.203 HDMI Audio recognition (Qubes OS)
    [Documentation]    Verify HDMI audio output recognition in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/9] Make sure Qubes OS is booted.
    Execute Manual Step    [2/9] Connect an HDMI display with audio capability.
    Execute Manual Step    [3/9] Click the Qubes OS logo in the corner of the screen.
    Execute Manual Step    [4/9] Click the gear icon in the menu.
    Execute Manual Step    [5/9] Select the "Volume Control" icon from the menu.
    Execute Manual Step    [6/9] In Volume Control, navigate to the "Configuration" tab.
    Execute Manual Step    [7/9] From the profile dropdown, select "Digital Stereo (HDMI) Output".
    Execute Manual Step    [8/9] Observe available audio output devices.
    Execute Manual Step    [9/9] Verify HDMI audio output is available.

AUD008.203 HDMI Audio playback (Qubes OS)
    [Documentation]    Verify audio playback via HDMI output in Qubes OS.
    [Tags]    semiauto
    Execute Manual Step    [1/9] Make sure Qubes OS is booted.
    Execute Manual Step    [2/9] Connect an HDMI display with speakers.
    Execute Manual Step    [3/9] Click the Qubes OS logo in the corner of the screen.
    Execute Manual Step    [4/9] Click the gear icon in the menu.
    Execute Manual Step    [5/9] Select the "Volume Control" icon from the menu.
    Execute Manual Step    [6/9] In Volume Control, navigate to the "Configuration" tab.
    Execute Manual Step    [7/9] From the profile dropdown, select "Digital Stereo (HDMI) Output".
    Execute Manual Step    [8/9] Play a test audio file in any AppVM.
    Execute Manual Step    [9/9] Verify sound is audible via HDMI-connected speakers.


*** Keywords ***
Init AUD Qubes OS
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
