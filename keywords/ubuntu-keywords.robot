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

Get SMBIOS data
    [Documentation]    Keyword allows to get all necessary SMBIOS data for
    ...    comparison by using dmidecode commands.
    # serial number
    ${serial_number}=    Execute Linux command    dmidecode -t system | grep 'Serial Number' | cat
    ${serial_number}=    Fetch From Right    ${serial_number}    Number:${SPACE * 1}
    ${serial_number}=    Fetch From Left    ${serial_number}    \r
    # firmware version
    ${firmware_version}=    Execute Linux command    dmidecode -t bios | grep 'Version' | cat
    ${firmware_version}=    Fetch From Right    ${firmware_version}    Version:${SPACE * 1}
    ${firmware_version}=    Fetch From Left    ${firmware_version}    \r
    # product name
    ${product_name}=    Execute Linux command    dmidecode -t system | grep 'Product Name' | cat
    ${product_name}=    Fetch From Right    ${product_name}    Name:${SPACE * 1}
    ${product_name}=    Fetch From Left    ${product_name}    \r
    # release date
    ${release_date}=    Execute Linux command    dmidecode -t bios | grep 'Release Date' | cat
    ${release_date}=    Fetch From Right    ${release_date}    Date:${SPACE * 1}
    ${release_date}=    Fetch From Left    ${release_date}    \r
    # manufacturer
    ${manufacturer}=    Execute Linux command    dmidecode -t system | grep 'Manufacturer' | cat
    ${manufacturer}=    Fetch From Right    ${manufacturer}    Manufacturer:${SPACE * 1}
    ${manufacturer}=    Fetch From Left    ${manufacturer}    \r
    # vendor
    ${vendor}=    Execute Linux command    dmidecode -t bios | grep 'Vendor' | cat
    ${vendor}=    Fetch From Right    ${vendor}    Vendor:${SPACE * 1}
    ${vendor}=    Fetch From Left    ${vendor}    \r
    # firmware family
    ${firmware_family}=    Execute Linux command    dmidecode -t system | grep 'Firmware Family' | cat
    ${firmware_family}=    Fetch From Right    ${firmware_family}    Family:${SPACE * 1}
    ${firmware_family}=    Fetch From Left    ${firmware_family}    \r
    # firmware type
    ${firmware_type}=    Execute Linux command    dmidecode -t chassis | grep 'Type' | cat
    ${firmware_type}=    Fetch From Right    ${firmware_type}    Type:${SPACE * 1}
    ${firmware_type}=    Fetch From Left    ${firmware_type}    \r
    &{smbios_data}=    Create Dictionary
    ...    serial_number=${serial_number}
    ...    firmware_version=${firmware_version}
    ...    product_name=${product_name}
    ...    release_date=${release_date}
    ...    firmware_manufacturer=${manufacturer}
    ...    firmware_vendor=${vendor}
    ...    firmware_family=${firmware_family}
    ...    firmware_type=${firmware_type}
    RETURN    ${smbios_data}
