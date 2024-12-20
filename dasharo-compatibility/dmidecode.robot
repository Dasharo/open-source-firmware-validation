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
Resource            ../pikvm-rest-api/pikvm_comm.robot

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


*** Test Cases ***
DMI001.001 Verify the device serial number
    [Documentation]    Check whether the DUT serial number is the same as it is
    ...    expected.
    Skip If    not ${SERIAL_NUMBER_VERIFICATION}    DMI001.001 not supported
    Should Contain    ${DMI_SYSTEM}    Serial Number: ${DMIDECODE_SERIAL_NUMBER}
    IF    ${SERIAL_FROM_MAC}    Compare Serial Number From MAC    ${DMI_SYSTEM}

DMI002.001 Verify the firmware version
    [Documentation]    Check whether the firmware version on the DUT is the
    ...    same as it is expected.
    [Tags]    minimal-regression
    Skip If    not ${FIRMWARE_NUMBER_VERIFICATION}    DMI002.001 not supported
    Should Contain    ${DMI_BIOS}    Version: ${DMIDECODE_FIRMWARE_VERSION}
    IF    ${FIRMWARE_FROM_BINARY}    Firmware Version Verification From Binary

DMI003.001 Verify the firmware product name
    [Documentation]    Check whether the DUT product name is the same as it is
    ...    expected.
    [Tags]    minimal-regression
    Skip If    not ${PRODUCT_NAME_VERIFICATION}    DMI003.001 not supported
    Should Contain    ${DMI_SYSTEM}    Product Name: ${DMIDECODE_PRODUCT_NAME}

DMI004.001 Verify the firmware release date
    [Documentation]    Check whether the firmware release date on the DUT is
    ...    the same as it is expected.
    Skip If    not ${RELEASE_DATE_VERIFICATION}    DMI004.001 not supported
    Should Contain    ${DMI_BIOS}    Release Date: ${DMIDECODE_RELEASE_DATE}

DMI005.001 Verify the firmware manufacturer
    [Documentation]    Check whether the firmware manufacturer on the DUT is
    ...    the same as it is expected.
    Skip If    not ${MANUFACTURER_VERIFICATION}    DMI005.001 not supported
    Should Contain    ${DMI_SYSTEM}    Manufacturer: ${DMIDECODE_MANUFACTURER}
    Should Contain    ${DMI_BASEBOARD}    Manufacturer: ${DMIDECODE_MANUFACTURER}

DMI006.001 Verify the firmware vendor
    [Documentation]    Check whether the firmware vendor on the DUT is the same
    ...    as it is expected.
    Skip If    not ${VENDOR_VERIFICATION}    DMI006.001 not supported
    Should Contain    ${DMI_BIOS}    Vendor: ${DMIDECODE_VENDOR}

DMI007.001 Verify the firmware family
    [Documentation]    Check whether the firmware family on the DUT is the same
    ...    as it is expected.
    Skip If    not ${FAMILY_VERIFICATION}    DMI007.001 not supported
    Should Contain    ${DMI_SYSTEM}    Family: ${DMIDECODE_FAMILY}

DMI008.001 Verify the firmware type
    [Documentation]    Check whether the firmware type on the DUT is the same
    ...    as it is expected.
    Skip If    not ${TYPE_VERIFICATION}    DMI008.001 not supported
    Should Contain    ${DMI_CHASSIS}    Type: ${DMIDECODE_TYPE}


*** Keywords ***
Get SMBIOS Values
    [Documentation]    Get the dump of SMBIOS tables (BIOS, System, Base Board
    ...    and Chassis) and store them in suite variables. Each table is stored
    ...    in a dedicated variable because their fields have generic names (e.g.
    ...    Type) that is later extracted in the test cases.
    Power Cycle On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t bios
    Set Suite Variable    $DMI_BIOS    ${out}
    ${out}=    Execute Linux Command    dmidecode -t system
    Set Suite Variable    $DMI_SYSTEM    ${out}
    ${out}=    Execute Linux Command    dmidecode -t baseboard
    Set Suite Variable    $DMI_BASEBOARD    ${out}
    ${out}=    Execute Linux Command    dmidecode -t chassis
    Set Suite Variable    $DMI_CHASSIS    ${out}
    Exit From Root User
