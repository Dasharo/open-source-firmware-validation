*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
AUD001.001 Audio subsystem detection (Ubuntu 20.04)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Linux OS.
    Skip If    not ${audio_subsystem_support}    AUD001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    AUD001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    alsa-utils
    ${out}=    Execute Linux command    cat /sys/class/sound/card0/hwC0D*/chip_name
    Should Contain    ${out}    ${device_audio1}
    Should Contain    ${out}    ${device_audio2}
    Exit from root user

AUD001.002 Audio subsystem detection (Windows 11)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Windows 11.
    Skip If    not ${audio_subsystem_support}    AUD001.002 not supported
    Skip If    not ${tests_in_windows_support}    AUD001.002 not supported
    Power On
    Boot system or from connected disk    ${os_windows}
    Login to Windows
    ${out}=    Get Sound Devices Windows
    Should Contain    ${out}    ${device_audio1_win}
    Should Contain    ${out}    OK

## PI-KVM necessary
# AUD002.001 Audio playback (Ubuntu 20.04)
#    [Documentation]    Check whether the audio subsystem is able to playback
#    ...    audio recordings.
#    Execute Linux command    pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo    0
#    Telnet.Read Until Prompt
#    Execute Linux command    pactl set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo 65535
#    Telnet.Read Until Prompt
#    Execute Linux command    speaker-test
#    Telnet.Read Until Prompt
#    ${out}=    Execute Linux command    arecord -qd 1 volt && sox volt -n stat &> volt.d && sed '4q;d' volt.d
#    Should Contain    ${out}    #TODO the output

# in fact tested in AUD002.001
# AUD003.001 Audio capture (Ubuntu 20.04)
#    [Documentation]    Check whether the audio subsystem is able to capture
#    ...    audio.

AUD004.001 External headset recognition (Ubuntu 20.04)
    [Documentation]    Check whether the external headset is recognized
    ...    properly after plugging in micro jack into slot.
    Skip If    not ${audio_subsystem_support}    AUD004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    AUD004.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    ${out}=    Execute Linux command    amixer -c 0 contents | grep -A 2 'Headphone' | cat
    ${headset_string}=    Set Variable    values=on
    Should Contain    ${out}    ${headset_string}
    Exit from root user

# Work in progress
# AUD004.002 External headset recognition (Windows 11)
#    [Documentation]    Check whether the external headset is recognized
#    ...    properly after plugging in micro jack into slot.
#    Skip If    not ${audio_subsystem_support}    AUD004.002 not supported
#    Skip If    not ${tests_in_windows_support}    AUD004.002 not supported
#    Power On
#    Boot system or from connected disk    ${os_windows}
#    Login to Windows
#    Execute Command In Terminal    Install-PackageProvider -Name NuGet -Force
#    Execute Command In Terminal    Install-Module -Name AudioDeviceCmdlets -Force
#    ${out}=    Execute Command In Terminal    Get-AudioDevice -list    | ft Index, Default, Type, Name
#    Should Contain    ${out}    ${headset_string}
#    Exit from root user
