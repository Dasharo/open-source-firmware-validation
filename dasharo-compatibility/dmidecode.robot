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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    dmidecode is not supported
...                     AND
...                     Get SMBIOS Values
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DMI001.201 Verify the serial number (Ubuntu)
    [Documentation]    Check whether the DUT serial number is the same as it is
    ...    expected.
    Skip If    not ${SERIAL_NUMBER_VERIFICATION}    DMI001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI001.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_SYSTEM}    Serial Number: ${DMIDECODE_SERIAL_NUMBER}
    IF    ${SERIAL_FROM_MAC}    Compare Serial Number From MAC    ${DMI_SYSTEM}

DMI002.201 Verify the firmware version (Ubuntu)
    [Documentation]    Check whether the firmware version on the DUT is the
    ...    same as it is expected.
    [Tags]    automated    minimal-regression
    Skip If    not ${FIRMWARE_NUMBER_VERIFICATION}    DMI002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI002.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_BIOS}    Version: ${DMIDECODE_FIRMWARE_VERSION}
    IF    ${FIRMWARE_FROM_BINARY}    Firmware Version Verification From Binary

DMI003.201 Verify the firmware product name (Ubuntu)
    [Documentation]    Check whether the DUT product name is the same as it is
    ...    expected.
    [Tags]    automated    minimal-regression
    Skip If    not ${PRODUCT_NAME_VERIFICATION}    DMI003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI003.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_SYSTEM}    Product Name: ${DMIDECODE_PRODUCT_NAME}

DMI004.201 Verify the firmware release date (Ubuntu)
    [Documentation]    Check whether the firmware release date on the DUT is
    ...    the same as it is expected.
    Skip If    not ${RELEASE_DATE_VERIFICATION}    DMI004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI004.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_BIOS}    Release Date: ${DMIDECODE_RELEASE_DATE}

DMI005.201 Verify the firmware manufacturer (Ubuntu)
    [Documentation]    Check whether the firmware manufacturer on the DUT is
    ...    the same as it is expected.
    Skip If    not ${MANUFACTURER_VERIFICATION}    DMI005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI005.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_SYSTEM}    Manufacturer: ${DMIDECODE_MANUFACTURER}
    Should Contain    ${DMI_BASEBOARD}    Manufacturer: ${DMIDECODE_MANUFACTURER}

DMI006.201 Verify the firmware vendor (Ubuntu)
    [Documentation]    Check whether the firmware vendor on the DUT is the same
    ...    as it is expected.
    Skip If    not ${VENDOR_VERIFICATION}    DMI006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI006.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_BIOS}    Vendor: ${DMIDECODE_VENDOR}

DMI007.201 Verify the firmware family (Ubuntu)
    [Documentation]    Check whether the firmware family on the DUT is the same
    ...    as it is expected.
    Skip If    not ${FAMILY_VERIFICATION}    DMI007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI007.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_SYSTEM}    Family: ${DMIDECODE_FAMILY}

DMI008.201 Verify the firmware type (Ubuntu)
    [Documentation]    Check whether the firmware type on the DUT is the same
    ...    as it is expected.
    Skip If    not ${TYPE_VERIFICATION}    DMI008.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DMI008.201 not supported
    Get SMBIOS Values    ${ENV_ID_UBUNTU}
    Should Contain    ${DMI_CHASSIS}    Type: ${DMIDECODE_TYPE}

DMI001.202 Verify the device serial number (Fedora)
    [Documentation]    Check whether the DUT serial number is the same as it is
    ...    expected.
    Skip If    not ${SERIAL_NUMBER_VERIFICATION}    DMI001.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI001.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_SYSTEM}    Serial Number: ${DMIDECODE_SERIAL_NUMBER}
    IF    ${SERIAL_FROM_MAC}    Compare Serial Number From MAC    ${DMI_SYSTEM}

DMI002.202 Verify the firmware version (Fedora)
    [Documentation]    Check whether the firmware version on the DUT is the
    ...    same as it is expected.
    [Tags]    automated    minimal-regression
    Skip If    not ${FIRMWARE_NUMBER_VERIFICATION}    DMI002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI002.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_BIOS}    Version: ${DMIDECODE_FIRMWARE_VERSION}
    IF    ${FIRMWARE_FROM_BINARY}    Firmware Version Verification From Binary

DMI003.202 Verify the firmware product name (Fedora)
    [Documentation]    Check whether the DUT product name is the same as it is
    ...    expected.
    [Tags]    automated    minimal-regression
    Skip If    not ${PRODUCT_NAME_VERIFICATION}    DMI003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI003.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_SYSTEM}    Product Name: ${DMIDECODE_PRODUCT_NAME}

DMI004.202 Verify the firmware release date (Fedora)
    [Documentation]    Check whether the firmware release date on the DUT is
    ...    the same as it is expected.
    Skip If    not ${RELEASE_DATE_VERIFICATION}    DMI004.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI004.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_BIOS}    Release Date: ${DMIDECODE_RELEASE_DATE}

DMI005.202 Verify the firmware manufacturer (Fedora)
    [Documentation]    Check whether the firmware manufacturer on the DUT is
    ...    the same as it is expected.
    Skip If    not ${MANUFACTURER_VERIFICATION}    DMI005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI005.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_SYSTEM}    Manufacturer: ${DMIDECODE_MANUFACTURER}
    Should Contain    ${DMI_BASEBOARD}    Manufacturer: ${DMIDECODE_MANUFACTURER}

DMI006.202 Verify the firmware vendor (Fedora)
    [Documentation]    Check whether the firmware vendor on the DUT is the same
    ...    as it is expected.
    Skip If    not ${VENDOR_VERIFICATION}    DMI006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI006.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_BIOS}    Vendor: ${DMIDECODE_VENDOR}

DMI007.202 Verify the firmware family (Fedora)
    [Documentation]    Check whether the firmware family on the DUT is the same
    ...    as it is expected.
    Skip If    not ${FAMILY_VERIFICATION}    DMI007.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI007.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_SYSTEM}    Family: ${DMIDECODE_FAMILY}

DMI008.202 Verify the firmware type (Fedora)
    [Documentation]    Check whether the firmware type on the DUT is the same
    ...    as it is expected.
    Skip If    not ${TYPE_VERIFICATION}    DMI008.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DMI008.202 not supported
    Get SMBIOS Values    ${ENV_ID_FEDORA}
    Should Contain    ${DMI_CHASSIS}    Type: ${DMIDECODE_TYPE}


*** Keywords ***
Get SMBIOS Values
    [Documentation]    Get the dump of SMBIOS tables (BIOS, System, Base Board
    ...    and Chassis) and store them in suite variables. Each table is stored
    ...    in a dedicated variable because their fields have generic names (e.g.
    ...    Type) that is later extracted in the test cases.
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User

    ${out}=    Execute Linux Command    dmidecode -t bios
    VAR    ${DMI_BIOS}=    ${out}    scope=SUITE
    ${out}=    Execute Linux Command    dmidecode -t system
    VAR    ${DMI_SYSTEM}=    ${out}    scope=SUITE
    ${out}=    Execute Linux Command    dmidecode -t baseboard
    VAR    ${DMI_BASEBOARD}=    ${out}    scope=SUITE
    ${out}=    Execute Linux Command    dmidecode -t chassis
    VAR    ${DMI_CHASSIS}=    ${out}    scope=SUITE
    Exit From Root User
