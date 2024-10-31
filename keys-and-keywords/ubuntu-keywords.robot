# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Keywords ***
Detect Or Install Package
    [Documentation]    Keyword allows to check whether the package, that is
    ...    necessary to run the test case, has already been installed on
    ...    the system, otherwise forces it to be installed.
    [Arguments]    ${package}
    ${is_package_installed}=    Set Variable    ${FALSE}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    IF    ${is_package_installed}    RETURN
    Log To Console    \nInstalling required package (${package})...
    Install Package    ${package}
    Sleep    10s
    ${is_package_installed}=    Check If Package Is Installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Check If Package Is Installed
    [Documentation]    Keyword allows to check whether the package, that is
    ...    necessary to run the test case, has already been installed on the
    ...    system.
    [Arguments]    ${package}
    ${output}=    Execute Linux Command    dpkg --list ${package} | cat
    ${status}=    Evaluate    "no packages found matching" in """${output}"""
    ${is_installed}=    Set Variable If    ${status}    ${FALSE}    ${TRUE}
    RETURN    ${is_installed}

Install Package
    [Documentation]    Keyword allows to install the package, that is necessary
    ...    to run the test case
    [Arguments]    ${package}
    Set DUT Response Timeout    600s
    Write Into Terminal    apt-get install --assume-yes ${package}
    Read From Terminal Until Prompt
    Set DUT Response Timeout    30s

Get Logging Level
    [Documentation]    This keyword returns TRUE if logging is disabled and
    ...    FALSE if it is not.
    ${ret}=    Execute Linux Command    cut -f1 /proc/sys/kernel/printk

    RETURN    ${ret}

Set Logging Level
    [Documentation]    This keyword sets the logging level to given value [0; 7]
    [Arguments]    ${level}
    Execute Linux Command    echo "kernel.printk = ${level} 4 1 7" > /etc/sysctl/d/10-console-messages.conf
    Execute Linux Command    sed -i '/kernel\.printk =/d' /etc/sysctl.conf
    Execute Linux Command    echo "kernel.printk = ${level} 4 1 7" >> /etc/sysctl.conf
    Execute Linux Command    sysctl --system
