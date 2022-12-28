*** Keywords ***
Detect or Install Package
    [Documentation]    Keyword allows to check whether the package, that is
    ...    necessary to run the test case, has already been installed on
    ...    the system, otherwise forces it to be installed.
    [Arguments]    ${package}
    ${is_package_installed}=    Set Variable    ${False}
    Log To Console    \nChecking if ${package} is installed...
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}
        Log To Console    \nPackage ${package} is installed
    ELSE
        Log To Console    \nPackage ${package} is not installed
    END
    IF    ${is_package_installed}    RETURN
    Log To Console    \nInstalling required package (${package})...
    Install package    ${package}
    Sleep    10s
    ${is_package_installed}=    Check if package is installed    ${package}
    IF    ${is_package_installed}=='False'
        FAIL    \nRequired package (${package}) cannot be installed
    END
    Log To Console    \nRequired package (${package}) installed successfully

Check if package is installed
    [Documentation]    Keyword allows to check whether the package, that is
    ...    necessary to run the test case, has already been installed on the
    ...    system.
    [Arguments]    ${package}
    ${output}=    Execute Linux command    dpkg --list ${package} | cat
    ${status}=    Evaluate    "no packages found matching" in """${output}"""
    ${is_installed}=    Set Variable If    ${status}    ${False}    ${True}
    RETURN    ${is_installed}

Install package
    [Documentation]    Keyword allows to install the package, that is necessary
    ...    to run the test case
    [Arguments]    ${package}
    Set DUT Response Timeout    600s
    Write Into Terminal    apt-get install --assume-yes ${package}
    Read From Terminal Until Prompt
    Set DUT Response Timeout    30s
