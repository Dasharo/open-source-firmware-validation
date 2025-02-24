*** Settings ***
Documentation       lib/performance/common

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             RequestsLibrary
Library             SSHLibrary
Resource            ../../variables.robot
Resource            ../../keywords.robot
Resource            ../../keys.robot
# IMPORTANT: This must be commented out for production
# This is here only to make LSP happy during development.
# Resource    ../../platform-configs/include/default.robot


*** Variables ***
${PTS_LATEST_URL}=
...                             https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/tags/v10.8.4.zip
${PTS_DOWNLOAD_PATH}=           C:\pts\pts.zip
${PTS_EXTRACT_PATH}=            C:\pts-extracted\
${PERF_REPORT_DIR_LINUX}=       ~/testing/reports/
${PERF_REPORT_DIR_WINDOWS}=     C:\testing\reports\


*** Keywords ***
Power Cycle Into Ubuntu
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux

Power Cycle Into Windows
    Power On
    Login To Windows

Power Cycle Into Firmware Setup
    Power On
    Enter Setup Menu Tianocore

Detect Or Install Phoronix Test Suite On Ubuntu
    [Documentation]    Detects and installs PTS
    ${out}=    Execute Command In Terminal    test -f /usr/bin/phoronix-test-suite && echo "PTS Installed"
    IF    '${out}' != 'PTS Installed'
        Switch To Root User
        Detect Or Install Package    php-cli
        Execute Command In Terminal    wget ${PTS_LATEST_URL}    60
        Execute Command In Terminal    unzip -q -o v10.8.4.zip    120
        ${out}=    Execute Command In Terminal
        ...    cd phoronix-test-suite-10.8.4 && ./install-sh && cd ..    60
        Should Contain    ${out}    Phoronix Test Suite Installation Completed
        Execute Command In Terminal
        ...    cd .. && rm v10.8.4.zip && rm -r phoronix-test-suite-10.8.4
        Exit From Root User
    END

Detect Or Install Phoronix Test Suite On Windows
    [Documentation]    Detects and installs PTS
    ${out}=    Execute Command In Terminal    Test-Path -Path C:\phoronix-test-suite
    IF    '${out}' != 'True'
        Execute Command In Terminal
        ...    Invoke-WebRequest -Uri ${PTS_LATEST_URL} -OutFile ${PTS_DOWNLOAD_PATH}    60
        Execute Command In Terminal
        ...    Expand-Archive -Path ${PTS_DOWNLOAD_PATH} -DestinationPath ${PTS_EXTRACT_PATH} -Force    60
        Execute Command In Terminal
        ...    Start-Process -FilePath ${PTS_EXTRACT_PATH}\install.bat -NoNewWindow -Wait    300
        Execute Command In Terminal
        ...    Remove-Item -Path ${PTS_DOWNLOAD_PATH} -Force
        Execute Command In Terminal
        ...    Remove-Item -Path ${PTS_EXTRACT_PATH} -Force
    END

Check Power Supply
    ${laptop_platform}=    Check The Platform Is A Laptop
    Set Suite Variable    ${LAPTOP_PLATFORM}    ${laptop_platform}
    IF    ${LAPTOP_PLATFORM}
        IF    ${TESTS_IN_UBUNTU_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Linux
        ELSE IF    ${TESTS_IN_WINDOWS_SUPPORT}
            ${bat0_present}    ${ac_online}    ${usb_pd_online}=    Check Power Supply On Windows
        ELSE IF    ${HEADS_PAYLOAD_SUPPORT}
            Log    Check Power Supply on Heads not implemented yet    ERROR
        ELSE
            Fail    Fail: Check Power Supply is not implemented enough
        END
        Set Suite Variable    ${BATTERY_PRESENT}    ${bat0_present}
        Set Suite Variable    ${AC_CONNECTED}    ${ac_online}
        Set Suite Variable    ${USB-PD_CONNECTED}    ${usb_pd_online}
    END

Check The Platform Is A Laptop
    ${laptop_platform}=    Run Keyword And Return Status    Should Contain Any    ${PLATFORM}    novacustom    tuxedo
    RETURN    ${laptop_platform}

Check Power Supply On Linux
    Power On
    Boot System Or From Connected Disk    ubuntu
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
    ${ac_online}=    Set Variable If
    ...    ${ac_online_empty}    ${TRUE}
    ...    ${ac_online_equal_2}    ${TRUE}

    # FIXME: USB-PD detection is not yet possible.
    Log    Check power supply USB-PD not implemented yet    WARN
    ${usb_pd_online}=    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${raw_output}
    ...    insert the correct USB-PD detection method here

    RETURN    ${bat0_present}    ${ac_online}    ${usb_pd_online}
