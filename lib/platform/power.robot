*** Settings ***
Documentation       Common header for OSFV Power management keywords

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot


*** Keywords ***
Check Power Supply
    VAR    ${LAPTOP_PLATFORM}=    ${EMPTY}    scope=SUITE
    ${laptop_platform}=    Check The Platform Is A Laptop
    IF    ${laptop_platform}
        IF    ${TESTS_IN_UBUNTU_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Linux
        ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Windows
        ELSE IF    ${HEADS_PAYLOAD_SUPPORT}
            Log    Check Power Supply on Heads not implemented yet    ERROR
        ELSE
            Fail    Fail: Check Power Supply is not implemented enough
        END
        VAR    ${BATTERY_PRESENT}=    ${bat0_present}    scope=SUITE
        VAR    ${AC_CONNECTED}=    ${ac_online}    scope=SUITE
        VAR    ${USB_PD_CONNECTED}=    ${usb_pd_online}    scope=SUITE
    END

Check The Platform Is A Laptop
    ${laptop_producer}=    Run Keyword And Return Status    Should Contain Any    ${PLATFORM}    novacustom    tuxedo
    ${nuc}=    Run Keyword And Return Status    Should Contain Any    ${PLATFORM}    nuc_box
    ${laptop_platform}=    Evaluate    ${laptop_producer} and not ${nuc}
    RETURN    ${laptop_platform}

Check Power Supply On Linux
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    ${bat0_present_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/BAT0/present
    ${bat0_present}=    Run Keyword And Return Status    Should Be Equal    ${bat0_present_raw}    1

    ${ac_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/AC/online
    Should Not Contain    ${ac_online_raw}    No such file or directory
    ${ac_online}=    Run Keyword And Return Status    Should Be Equal    ${ac_online_raw}    1

    # FIXME: USB-PD detection is not yet possible.
    ${usb_pd_online_raw}=    Execute Command In Terminal    cat /sys/class/power_supply/USB-PD/online
    Log    'cat /sys/class/power_supply/USB-PD/online' not implemented yet, if implemented, remove #    WARN
    # Should Not Contain    ${usb_pd_online_raw}    No such file or directory
    ${usb_pd_online}=    Run Keyword And Return Status    Should Be Equal    ${usb_pd_online_raw}    1

    RETURN    ${bat0_present}    ${ac_online}    ${usb_pd_online}

Check Power Supply On Windows
    Power On
    Login To Windows
    ${raw_output}=    Execute Command In Terminal    (Get-WmiObject Win32_Battery).BatteryStatus
    ${bat0_present}=    Run Keyword And Return Status    Should Not Be Empty    ${raw_output}

    # ${ac_online_raw}=    Execute Command In Terminal    (Get-WmiObject Win32_Battery).BatteryStatus
    ${ac_online_empty}=    Run Keyword And Return Status    Should Be Empty    ${raw_output}
    ${ac_online_equal_2}=    Run Keyword And Return Status    Should Be Equal    ${raw_output}    2
    # IF    ${ac_online_raw_empty}    or    ${ac_online_raw_equal_2}
    #    Set Local Variable    ${AC_ONLINE}=    ${TRUE}
    # END
    IF    ${ac_online_empty}
        VAR    ${ac_online}=    ${TRUE}
    ELSE IF    ${ac_online_equal_2}
        VAR    ${ac_online}=    ${TRUE}
    ELSE
        VAR    ${ac_online}=    ${None}
    END

    # FIXME: USB-PD detection is not yet possible.
    Log    Check power supply USB-PD not implemented yet    WARN
    ${usb_pd_online}=    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${raw_output}
    ...    insert the correct USB-PD detection method here

    RETURN    ${bat0_present}    ${ac_online}    ${usb_pd_online}

Check Battery Level On Linux
    [Documentation]    Returns a battery level as percentage.
    ${power_level}=    Execute Command In Terminal
    ...    cat /sys/class/power_supply/BAT0/capacity
    Should Not Contain    ${power_level}    No such file or directory
    RETURN    ${power_level}

Check Battery Level On Windows
    [Documentation]    Returns a battery level as percentage.
    ${power_level}=    Execute Command In Terminal
    ...    (Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining
    Should Not Be Empty    ${power_level}
    RETURN    ${power_level}

Power Cycle Into Ubuntu
    Power On
    Boot System Or From Connected Disk    201
    Login To Linux

Power Cycle Into Windows
    Power On
    Login To Windows

Power Cycle Into Firmware Setup
    Power On
    Enter Setup Menu Tianocore

Execute Cold Boot
    [Documentation]    Performs cold boot, either with RTE relay or Sonoff
    Power On
    Set UEFI Option    PowerStateAfterPowerAcLoss    Powered On
    Sleep    2
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu Off
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff Off
    END
    Sleep    12
    IF    '${POWER_CTRL}' == 'RteCtrl'
        Rte Psu On
    ELSE IF    '${POWER_CTRL}' == 'sonoff'
        Sonoff On
    END
