*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Variables ***
# Pactl names are uniform for all devices, and in theory
# across multiple Linux distributions
${PACTL_STR_INTERNAL_OUT}=      analog-output-speaker
${PACTL_STR_INTERNAL_IN}=       analog-input-internal-mic
${PACTL_STR_HEADSET_OUT}=       analog-output-headphones
${PACTL_STR_HEADSET_IN}=        analog-input-headset-mic
${PACTL_STR_HDMI_OUT}=          hdmi-output-0


*** Test Cases ***
AUD001.201 Audio subsystem detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Ubuntu OS. To do so, we first try to detect
    ...    audio devices in sysfs. Then, we verify no dummy output is present.
    ...    Dummy output only appears when no other sound device is available,
    ...    therefore, presence of it indicate failure to initialize audio for userspace
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    ${out}=    Execute Command In Terminal    pactl list sinks
    ${result}=    Run Keyword And Ignore Error
    ...    Should Not Contain    ${out}    device.description = "Dummy Output"
    IF    '${result}[0]' == 'FAIL'
        Log    \nSound Card was found, but PulseAudio did not found any device\n    WARN
    END

AUD002.201 Internal Audio playback
    [Documentation]    Check whether the audio subsystem in Ubuntu is able
    ...    toplayback audio recordings. To do so, first determine presence
    ...    of audio sink. Audio sink must not be a dummy. After it was
    ...    verified, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Sink Port Using Pactl    internal
    Verify Active Sink Port Using Pactl    internal
    # TODO: Test playback and waveforms
    # We probably can do it using alsa monitoring device, and capture
    # the sound to check if it was malformed in a way.
    Log    \Internal speakers detected, check validity of sound playback manually\n

AUD003.201 Internal Audio capture
    [Documentation]    Check whether the audio subsystem is able to capture
    ...    audio on Ubuntu. To do so, we first determine presence of internal
    ...    capture device.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Source Port Using Pactl    internal
    Verify Active Source Port Using Pactl    internal
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.201 External headset recognition
    [Documentation]    Check whether Ubuntu has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones

AUD005.201 External headset audio playback
    [Documentation]    Check whether Ubuntu has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \nHeadset speakers detected, please verify validity of playback manually\n

AUD006.201 External headset audio capture
    [Documentation]    Check whether Ubuntu has capability to capture sound
    ...    via external headset.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Verify External Headset Is Plugged In
    Switch Active Source Port Using Pactl    headphones
    Verify Active Source Port Using Pactl    headphones
    # TODO: Use pulseaudio to record back the audio and maybe do simple
    # waveform analysis. We could use modified headphones, in which
    # the microphone is physically attached to the speaker.
    Log    \n Headset microphone detected, check validity of sound capture manually\n

AUD007.201 HDMI Audio recognition
    [Documentation]    Check whether the HDMI audio is recognized
    ...    properly in Ubuntu after connecting HDMI display.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    ${TEST_NAME} not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_UBUNTU}
    Switch Active Sink Port Using Pactl    hdmi
    Verify Active Sink Port Using Pactl    hdmi

AUD001.202 Audio subsystem detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Fedora OS. To do so, we first try to detect
    ...    audio devices in sysfs. Then, we verify no dummy output is present.
    ...    Dummy output only appears when no other sound device is available,
    ...    therefore, presence of it indicate failure to initialize audio for userspace
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}

AUD002.202 Internal Audio playback
    [Documentation]    Check whether the audio subsystem in Fedora is able
    ...    toplayback audio recordings. To do so, first determine presence
    ...    of audio sink. Audio sink must not be a dummy. After it was
    ...    verified, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
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
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Switch Active Source Port Using Pactl    internal
    Verify Active Source Port Using Pactl    internal
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.202 External headset recognition
    [Documentation]    Check whether Fedora has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Verify External Headset Is Plugged In
    Switch Active Sink Port Using Pactl    headphones
    Verify Active Sink Port Using Pactl    headphones

AUD005.202 External headset audio playback
    [Documentation]    Check whether Fedora has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
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
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
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
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    ${TEST_NAME} not supported
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Audio Subsystem Detection Linux    ${ENV_ID_FEDORA}
    Switch Active Sink Port Using Pactl    hdmi
    Verify Active Sink Port Using Pactl    hdmi

AUD001.301 Audio subsystem detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Windows 11. To do so, we attempt detection
    ...    of the Audio Service, and verify it is in Running state.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
    ${out}=    Execute Command In Terminal    Get-Service | Where-Object { $_.Name -eq "Audiosrv" }
    Should Contain    ${out}    Running
    Execute Shutdown Command

AUD002.301 Internal Audio playback
    [Documentation]    Check whether the audio subsystem is able to playback
    ...    audio recordings. To do so, first determine presence of audio sink.
    ...    After that, we verify that sound is not malformed.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
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
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${INTERNAL_AUDIO_SUPPORT}    ${TEST_NAME} requires internal Microphone
    Power On
    Login To Windows
    ${out}=    Get Sound Devices In Windows    microphone
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_INTERNAL_IN}
    Should Contain    ${out}    OK
    # TODO: Somehow capture sound and confirm it is not malformed.
    Log    \Internal microphone detected, check validity of sound capture manually\n

AUD004.301 External headset recognition
    [Documentation]    Check whether Windows has recognized external headset,
    ...    after plugging in micro jack into slot.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
    ${out}=    Get Sound Devices In Windows    headphones
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HEADSET_OUT}
    Should Contain    ${out}    OK

AUD005.301 External headset audio playback
    [Documentation]    Check whether Windows has capability to playback
    ...    sounds via external headset.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
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
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
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
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    ${TEST_NAME} not supported
    Skip If    not ${HDMI_AUDIO_SUPPORT}    ${TEST_NAME} not supported
    Power On
    Login To Windows
    ${out}=    Get Sound Devices In Windows    display
    Should Not Be Empty    ${out}
    Should Contain    ${out}    ${POWERSHELL_STR_HDMI_OUT}
    Should Contain    ${out}    OK

AUD001.203 Audio subsystem detection (Qubes OS)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in QubesOS. To do so, we attempt detection
    ...    of the Audio Service, and verify it is in Running state.
    ...    Previous IDs: AUD001.003
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    ${out}=    Execute Command In Terminal    pactl list sinks
    ${result}=    Run Keyword And Ignore Error
    ...    Should Not Contain    ${out}    device.description = "Dummy Output"
    IF    '${result}[0]' == 'FAIL'
        Log    \nSound Card was found, but PulseAudio did not found any device\n    WARN
    END


*** Keywords ***
Audio Subsystem Detection Linux
    [Documentation]    Ensures Ubuntu is currently active and that the
    ...    audio chip was detected.
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    ${out}=    Execute Command In Terminal    cat /sys/class/sound/card0/hwC0D*/chip_name
    Should Not Contain    ${out}    No such file or directory

Get Sound Devices In Windows
    [Documentation]    Get and return sound devices via PowerShell
    ...    filtered as all devices, audio-sink only, or microphones only
    [Arguments]    ${class}=all
    IF    '${class}' == 'all'
        VAR    ${filter_condition}=    {$_.Class -match "Audio"}
    ELSE IF    '${class}' == 'speakers'
        VAR    ${filter_condition}=
        ...    {$_.Class -match "Audio" -and ($_.Name -match "Speaker" -or $_.Name -match "Output")}
    ELSE IF    '${class}' == 'headphones'
        VAR    ${filter_condition}=
        ...    {$_.Class -match "Audio" -and ($_.Name -match "Headphones" -or $_.Name -match "Output")}
    ELSE IF    '${class}' == 'microphone'
        VAR    ${filter_condition}=    {$_.Class -match "Audio" -and $_.Name -match "Microphone"}
    ELSE IF    '${class}' == 'display'
        VAR    ${filter_condition}=
        ...    {$_.Class -match "Audio" -and ($_.Name -match "Display" -or $_.Name -match "HDMI")}
    END

    ${ps_command}=    Evaluate
    ...    'Get-PnpDevice -PresentOnly | Where-Object ${filter_condition} | Select-Object Name, Status'
    ${out}=    Execute Command In Terminal    ${ps_command}
    RETURN    ${out}

Switch Active Sink Port Using Pactl
    [Documentation]    Using Pulse Audio Controller (pactl), attempt to switch
    ...    to specified sink port.
    [Arguments]    ${class}
    ${sink}=    Execute Command In Terminal
    ...    pactl list short sinks | awk '{print $1}'
    VAR    ${cmd}=    pactl set-sink-port ${sink}

    IF    '${class}' == 'internal'
        VAR    ${cmd}=    ${cmd}    ${PACTL_STR_INTERNAL_OUT}    separator=${SPACE}
    ELSE IF    '${class}' == 'headphones'
        VAR    ${cmd}=    ${cmd}    ${PACTL_STR_HEADSET_OUT}    separator=${SPACE}
    ELSE IF    '${class}' == 'hdmi'
        VAR    ${cmd}=    ${cmd}    ${PACTL_STR_HDMI_OUT}    separator=${SPACE}
    ELSE
        Fail    Invalid audio class. Use: headphones, internal, or hdmi.
    END
    Execute Command In Terminal    ${cmd}

Switch Active Source Port Using Pactl
    [Documentation]    Using Pulse Audio Controller (pactl), attempt to switch
    ...    to specified source port. Due to limitations of audio subsystems,
    ...    to set a source port, we need to specify device by full name,
    ...    so we filter it with "grep alsa_input", in contrast to sink change
    ...    which only requires a numeric ID.
    [Arguments]    ${class}
    ${source}=    Execute Command In Terminal
    ...    pactl list sources | grep alsa_input | awk 'NR==1 {print $2}'
    VAR    ${cmd}=    pactl set-source-port ${source}

    IF    '${class}' == 'internal'
        VAR    ${cmd}=    ${cmd}    ${PACTL_STR_INTERNAL_IN}    separator=${SPACE}
    ELSE IF    '${class}' == 'headphones'
        VAR    ${cmd}=    ${cmd}    ${PACTL_STR_HEADSET_IN}    separator=${SPACE}
    ELSE
        Fail    Invalid audio class. Use: headphones or internal.
    END
    Execute Command In Terminal    ${cmd}

Verify Active Sink Port Using Pactl
    [Documentation]    Using Pulse Audio Controller (pactl), verify that specified
    ...    class of sink ports aka audio output is available
    [Arguments]    ${class}
    ${sinks}=    Execute Command In Terminal    pactl list sinks | grep "Active Port"
    Should Not Be Empty    ${sinks}

    IF    '${class}' == 'internal'
        Should Contain    ${sinks}    ${PACTL_STR_INTERNAL_OUT}
    ELSE IF    '${class}' == 'hdmi'
        Should Contain    ${sinks}    ${PACTL_STR_HDMI_OUT}
    ELSE IF    '${class}' == 'headphones'
        Should Contain    ${sinks}    ${PACTL_STR_HEADSET_OUT}
    ELSE
        Fail    Invalid audio class. Use: headphones, internal, or hdmi.
    END

Verify Active Source Port Using Pactl
    [Documentation]    Using Pulse Audio Controller (pactl), verify that specified
    ...    class of source ports is available
    [Arguments]    ${class}
    ${sources}=    Execute Command In Terminal    pactl list sources | grep "Active Port"
    Should Not Be Empty    ${sources}

    IF    '${class}' == 'internal'
        Should Contain    ${sources}    ${PACTL_STR_INTERNAL_IN}
    ELSE IF    '${class}' == 'headphones'
        Should Contain    ${sources}    ${PACTL_STR_HEADSET_IN}
    ELSE
        Fail    Invalid audio source class. Use: headphones or internal.
    END

Verify External Headset Is Plugged In
    [Documentation]    Using Pulse Audio Controller (pactl), verify that
    ...    external headset is plugged in.
    ${result}=    Execute Command In Terminal
    ...    pactl list sinks | grep analog-output-headphones | awk 'NR==1'
    Should Not Contain    ${result}    not available
