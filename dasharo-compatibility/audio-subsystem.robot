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

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
AUD001.201 Audio subsystem detection (Ubuntu)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Linux OS.
    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}    AUD001.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    AUD001.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    AUD001.201 not supported
    Audio Subsystem Detection    ${ENV_ID_UBUNTU}

# PI-KVM necessary
# AUD002.001 Audio playback (Ubuntu)
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

AUD004.201 External headset recognition (Ubuntu)
    [Documentation]    Check whether the external headset is recognized
    ...    properly after plugging in micro jack into slot.
    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}    AUD004.201 not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    AUD004.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    AUD004.201 not supported
    Skip If    "${ENV_ID_UBUNTU}" not in "${TESTED_LINUX_DISTROS}"    AUD004.201 not supported
    External Headset Recognition    ${ENV_ID_UBUNTU}

AUD001.202 Audio subsystem detection (Fedora)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Linux OS.
    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}    AUD001.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    AUD001.202 not supported
    Audio Subsystem Detection    ${ENV_ID_FEDORA}

AUD004.202 External headset recognition (Fedora)
    [Documentation]    Check whether the external headset is recognized
    ...    properly after plugging in micro jack into slot.
    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}    AUD004.202 not supported
    Skip If    not ${EXTERNAL_HEADSET_SUPPORT}    AUD004.202 not supported
    Skip If    "${ENV_ID_FEDORA}" not in "${TESTED_LINUX_DISTROS}"    AUD004.202 not supported
    External Headset Recognition    ${ENV_ID_FEDORA}

AUD001.301 Audio subsystem detection (Windows)
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Windows 11.
    Skip If    not ${AUDIO_SUBSYSTEM_SUPPORT}    AUD001.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    AUD001.301 not supported
    Power On
    Login To Windows
    ${out}=    Get Sound Devices Windows
    Should Contain    ${out}    ${DEVICE_AUDIO1_WIN}
    Should Contain    ${out}    OK

# Work in progress
# AUD004.002 External headset recognition (Windows)
#    [Documentation]    Check whether the external headset is recognized
#    ...    properly after plugging in micro jack into slot.
#    Skip If    not ${audio_subsystem_support}    AUD004.002 not supported
#    Skip If    not ${tests_in_windows_support}    AUD004.002 not supported
#    Power On
#    Login to Windows
#    Execute Command In Terminal    Install-PackageProvider -Name NuGet -Force
#    Execute Command In Terminal    Install-Module -Name AudioDeviceCmdlets -Force
#    ${out}=    Execute Command In Terminal    Get-AudioDevice -list    | ft Index, Default, Type, Name
#    Should Contain    ${out}    ${headset_string}
#    Exit from root user


*** Keywords ***
Audio Subsystem Detection
    [Documentation]    Check whether the audio subsystem is initialized correctly
    ...    and can be detected in Linux OS.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Linux Command    cat /sys/class/sound/card0/hwC0D*/chip_name
    Should Not Be Empty
    ...    ${DEVICE_AUDIO1}
    ...    msg=At least DEVICE_AUDIO01 must be defined in platform config if audio suite is enabled
    Should Contain    ${out}    ${DEVICE_AUDIO1}
    Should Contain    ${out}    ${DEVICE_AUDIO2}
    Exit From Root User

External Headset Recognition
    [Documentation]    Check whether the external headset is recognized
    ...    properly after plugging in micro jack into slot.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${out}=    Execute Linux Command    amixer -c 0 contents | grep -A 2 'Headphone' | cat
    ${headset_string}=    Set Variable    values=on
    Should Contain    ${out}    ${headset_string}
    Exit From Root User
