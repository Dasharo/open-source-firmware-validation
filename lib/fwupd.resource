*** Comments ***
# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0


*** Settings ***
Documentation       Common variables and keywords for fwupd tests

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/performance/cpu.robot


*** Keywords ***
Run Fwupd Update With Battery Check Workaround
    [Documentation]    The battery check used by fwupd thinks that the AC is
    ...    disconnected if the battery charge threshold is reached and its
    ...    not being charged anymore. To work this around we need to discharge
    ...    the battery a bit.
    [Arguments]    ${update_keyword}    @{args}
    # BATTERY_PRESENT might not exist for non-laptop devices
    ${battery}=    Get Variable Value    ${BATTERY_PRESENT}    ${FALSE}
    # Trigger workaround if the device is battery powered
    IF    ${battery}
        FOR    ${i}    IN RANGE    5
            ${out}=    Run Keyword    ${update_keyword}    @{args}
            ${ac_ok}=    Run Keyword And Return Status    Should Not Contain Any
            ...    ${out}
            ...    AC power
            ...    AC not detected
            ...    is not currently updatable
            IF    ${ac_ok}    BREAK
            Log
            ...    AC not detected, might be caused by battery charging threshold being triggered, running a stress test
            ...    WARN
            Stress Test    30s
            Sleep    30s
            Stress Test Stop
        END
    ELSE
        ${out}=    Run Keyword    ${update_keyword}    @{args}
    END
    RETURN    ${out}
