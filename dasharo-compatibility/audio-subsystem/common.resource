*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for AUD tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Variables ***
# Pactl names are uniform for all devices, and in theory
# across multiple Linux distributions
${PACTL_STR_INTERNAL_OUT}=      analog-output-speaker
${PACTL_STR_INTERNAL_IN}=       analog-input-internal-mic
${PACTL_STR_HEADSET_OUT}=       analog-output-headphones
${PACTL_STR_HEADSET_IN}=        analog-input-headset-mic
${PACTL_STR_HDMI_OUT}=          hdmi-output-0
${PLATFORM_STATE_CONTROL}=      ${TRUE}


*** Keywords ***
Audio Subsystem Detection Linux
    [Documentation]    Ensures Ubuntu is currently active and that the
    ...    audio chip was detected.
    [Arguments]    ${os_id}
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
