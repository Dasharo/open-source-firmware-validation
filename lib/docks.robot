*** Settings ***
Documentation       Collection of keywords for testing USB-C docking stations

Resource            ../keywords.robot


*** Keywords ***
Ensure DisplayLink Driver Is Installed Linux
    [Documentation]    Keyword installs DisplayLink drivers if they're missing.
    TRY
        ${out}=    Execute Linux Command    apt list --installed
        Should Contain    ${out}    displaylink-driver
    EXCEPT
        Download File
        ...    https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
        ...    synaptics-repository-keyring.deb
        Install Package    ./synapics-repository-keyring.deb
        Execute Linux Command    apt update
        Install Package    displaylink-driver
        Execute Linux Command    systemctl start displaylink-driver.service
        Sleep    5s
        Execute Linux Command    systemctl restart gdm.service
        Sleep    5s
    END

Check DisplayLink Dock In Linux
    [Documentation]    Keyword looks for any enabled outputs on connected
    ...    DisplayLink docks.
    Ensure DisplayLink Driver Is Installed Linux
    ${out}=    Execute Linux Command    cat /sys/devices/platform/evdi.*/drm/card*/card*-*/enabled
    Should Contain    ${out}    enabled

Check Docking Station HDMI Windows
    [Documentation]    Check if docking station HDMI display is recognized by
    ...    Windows OS.
    # this actually just checks if HDMI or DP is found
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 12    VideoOutputTechnology : 10

Check PCON On MST Hub In Linux
    [Documentation]    Keyword checks if a HDMI port on an MST hub is active.
    ${out}=    Execute Linux Command    cat /sys/kernel/debug/dri/*/i915_dp_mst_info
    # XXX: Conversion to HDMI, DVI or VGA is detected the same way
    Should Contain    ${out}    DP LEGACY CONV

Check DP Port On MST Hub In Linux
    [Documentation]    Keyword checks if a DP port on an MST hub is active.
    ${out}=    Execute Linux Command    cat /sys/kernel/debug/dri/*/i915_dp_mst_info
    # Either a normal SST sink, or MST hub downstream, means the port is OK.
    Should Contain    ${out}    SST SINK    MST BRANCHING

Check Display Port On Hub In Linux
    [Documentation]    Check if a monitor is connected to a docking station (ignoring eDP)
    [Arguments]    ${target}
    Log    Please ensure that all external monitors are exclusively connected to    WARN
    Log    the docking station to eliminate false positives    WARN
    ${content}=    Execute Command In Terminal    cat ../../../sys/kernel/debug/dri/1/i915_display_info
    ${dock_connected}=    Check Docking Connection    ${content}    ${target}
    IF    ${dock_connected}
        Log    Monitor is connected to docking station
    ELSE
        Fail    No monitor connected to docking station or only eDP connected
    END

Check Docking Station DP Windows
    [Documentation]    Check if docking station DP display is recognized by
    ...    Windows OS.
    # this actually just checks if DP is found
    ${out}=    Check Displays Windows
    Should Contain Any    ${out}    VideoOutputTechnology : 10    VideoOutputTechnology : 11

Detect Docking Station USB Devices In Linux
    [Documentation]    Keyword check the docking station is detected correctly.
    [Arguments]    ${docking_station_model}
    # USB devices
    ${out}=    List Devices In Linux    usb
    IF    '${docking_station_model}' == 'WL-UMD05 Pro Rev.E'
        Should Contain    ${out}    VIA Labs, Inc. USB2.0 Hub
        Should Contain    ${out}    Fresco Logic Generic Billboard Device
        Should Contain    ${out}    Prolific Technology, Inc. USB 2.0 Hub
        Should Contain    ${out}    Genesys Logic, Inc. Hub
        Should Contain    ${out}    Realtek Semiconductor Corp. USB3.0 Card Reader
        Should Contain    ${out}    Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
        Should Contain    ${out}    VIA Labs, Inc. USB3.0 Hub
        Should Contain    ${out}    05e3:0620    # Genesys Logic, Inc. USB3.2 Hub
    ELSE IF    '${docking_station_model}' == 'WL-UMD05 Pro Rev.C1'
        Should Contain    ${out}    VIA Labs, Inc. USB2.0 Hub
        Should Contain    ${out}    Fresco Logic USB2.0 Hub
        Should Contain    ${out}    Linux Foundation 2.0 root hub
        Should Contain    ${out}    ASIX Electronics Corp. AX88179 Gigabit Ethernet
        Should Contain    ${out}    VIA Labs, Inc. USB3.0 Hub
        Should Contain    ${out}    Realtek Semiconductor Corp. USB3.0 Card Reader
        Should Contain    ${out}    Fresco Logic USB3.0 Hub
        Should Contain    ${out}    JMTek, LLC. USB PnP Audio Device
    ELSE IF    '${docking_station_model}' == 'WL-UG69PD2 Rev.A1'
        Should Contain    ${out}    Genesys Logic, Inc. Hub
        Should Contain    ${out}    Fresco Logic USB2.0 Hub
        Should Contain    ${out}    Genesys Logic, Inc. USB3.1 Hub
        Should Contain    ${out}    DisplayLink USB3.0 5K Graphic Docking
        Should Contain    ${out}    Fresco Logic USB3.0 Hub
    ELSE
        Fail    unknown docking station
    END

Detect Docking Station Video Ports In Linux
    [Documentation]    Keyword check the docking station is detected correctly.
    [Arguments]    ${docking_station_model}
    IF    '${docking_station_model}' == 'WL-UMD05 Pro Rev.E'
        Check PCON On MST Hub In Linux
        Check DP Port On MST Hub In Linux
    ELSE IF    '${docking_station_model}' == 'WL-UMD05 Pro Rev.C1'
        Check PCON On MST Hub In Linux
        Check DP Port On MST Hub In Linux
    ELSE IF    '${docking_station_model}' == 'WL-UG69PD2 Rev.A1'
        Check DisplayLink Dock In Linux
    ELSE
        Fail    unknown docking station
    END

Detect Docking Station In Linux
    [Documentation]    Keyword check the docking station is detected correctly.
    [Arguments]    ${docking_station_model}
    # Workaround for full initialize docking station.
    Sleep    5s
    Detect Docking Station USB Devices In Linux    ${docking_station_model}
    Detect Docking Station Video Ports In Linux    ${docking_station_model}

Check Docking Connection
    [Documentation]    Returns True if a monitor is connected to a docking station, False otherwise.
    [Arguments]    ${content}    ${target}
    ${lines}=    Split To Lines    ${content}
    ${dock_connected}=    Evaluate    'False'
    ${check_for_hdmi}=    Evaluate    'False'
    FOR    ${line}    IN    @{lines}
        ${line}=    Strip String    ${line}
        # at first we ignore that condition, it' ll become relevant once we find connector
        IF    ${check_for_hdmi}
            ${is_hdmi}=    Evaluate    "Type: HDMI" in """${line}"""
            IF    ${is_hdmi}
                ${dock_connected}=    Set Variable    True
                ${check_for_hdmi}=    Set Variable    False
            END
        ELSE
            # we start by finding non eDP display
            ${contains}=    Evaluate    "status: connected" in """${line}"""
            IF    ${contains}
                IF    "eDP" not in "${line}"
                    # since HDMI screens are listed as DP connector we need to look more clues
                    IF    "${target}" == "HDMI"
                        ${check_for_hdmi}=    Set Variable    True
                    ELSE IF    "${target}" == "DP"
                        ${dock_connected}=    Set Variable    True
                    END
                END
            END
        END
    END
    RETURN    ${dock_connected}
