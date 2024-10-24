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
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DMI001.001 Verify the device serial number
    [Documentation]    Check whether the DUT serial number is the same as it is
    ...    expected.
    Skip If    not ${SERIAL_NUMBER_VERIFICATION}    DMI001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI001.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t system | grep Serial
    Should Contain    ${out}    ${DMIDECODE_SERIAL_NUMBER}
    IF    ${SERIAL_FROM_MAC}    Compare Serial Number From MAC    ${out}
    Exit From Root User

DMI002.001 Verify the firmware version
    [Documentation]    Check whether the firmware version on the DUT is the
    ...    same as it is expected.
    [Tags]    minimal-regression
    Skip If    not ${FIRMWARE_NUMBER_VERIFICATION}    DMI002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI001.002 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t bios | grep Version
    Should Contain    ${out}    ${DMIDECODE_FIRMWARE_VERSION}
    Exit From Root User
    IF    ${FIRMWARE_FROM_BINARY}    Firmware Version Verification From Binary

DMI003.001 Verify the firmware product name
    [Documentation]    Check whether the DUT product name is the same as it is
    ...    expected.
    [Tags]    minimal-regression
    Skip If    not ${PRODUCT_NAME_VERIFICATION}    DMI003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI003.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t system | grep Product
    Should Contain    ${out}    ${DMIDECODE_PRODUCT_NAME}
    Exit From Root User

DMI004.001 Verify the firmware release date
    [Documentation]    Check whether the firmware release date on the DUT is
    ...    the same as it is expected.
    Skip If    not ${RELEASE_DATE_VERIFICATION}    DMI004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t bios | grep Release
    Should Contain    ${out}    ${DMIDECODE_RELEASE_DATE}
    Exit From Root User

DMI005.001 Verify the firmware manufacturer
    [Documentation]    Check whether the firmware manufacturer on the DUT is
    ...    the same as it is expected.
    Skip If    not ${MANUFACTURER_VERIFICATION}    DMI005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI005.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t system | grep Manufacturer
    Should Contain    ${out}    ${DMIDECODE_MANUFACTURER}
    ${out}=    Execute Linux Command    dmidecode -t baseboard | grep Manufacturer
    Should Contain    ${out}    ${DMIDECODE_MANUFACTURER}
    Exit From Root User

DMI006.001 Verify the firmware vendor
    [Documentation]    Check whether the firmware vendor on the DUT is the same
    ...    as it is expected.
    Skip If    not ${VENDOR_VERIFICATION}    DMI006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI006.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t bios | grep Vendor
    Should Contain    ${out}    ${DMIDECODE_VENDOR}
    Exit From Root User

DMI007.001 Verify the firmware family
    [Documentation]    Check whether the firmware family on the DUT is the same
    ...    as it is expected.
    Skip If    not ${FAMILY_VERIFICATION}    DMI007.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI007.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t system | grep Family
    Should Contain    ${out}    ${DMIDECODE_FAMILY}
    Exit From Root User

DMI008.001 Verify the firmware type
    [Documentation]    Check whether the firmware type on the DUT is the same
    ...    as it is expected.
    Skip If    not ${TYPE_VERIFICATION}    DMI008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    DMI008.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    dmidecode
    ${out}=    Execute Linux Command    dmidecode -t chassis | grep Type
    Should Contain    ${out}    ${DMIDECODE_TYPE}
    Exit From Root User
