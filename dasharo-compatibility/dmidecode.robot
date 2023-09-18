*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
DMI001.001 Verify the device serial number
    [Documentation]    Check whether the DUT serial number is the same as it is
    ...    expected.
    Skip If    not ${serial_number_verification}    DMI001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI001.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t bios | grep Serial
    Should Contain    ${out}    ${dmidecode_serial_number}
    IF    ${serial_from_MAC}    Compare Serial Number from MAC    ${out}
    Exit from root user

DMI002.001 Verify the firmware version
    [Documentation]    Check whether the firmware version on the DUT is the
    ...    same as it is expected.
    Skip If    not ${firmware_number_verification}    DMI002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI001.002 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t bios | grep Version
    Should Contain    ${out}    ${dmidecode_firmware_version}
    Exit from root user
    IF    ${firmware_from_binary}    Firmware version verification from binary

DMI003.001 Verify the firmware product name
    [Documentation]    Check whether the DUT product name is the same as it is
    ...    expected.
    Skip If    not ${product_name_verification}    DMI003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI003.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t system | grep Product
    Should Contain    ${out}    ${dmidecode_product_name}
    Exit from root user

DMI004.001 Verify the firmware release date
    [Documentation]    Check whether the firmware release date on the DUT is
    ...    the same as it is expected.
    Skip If    not ${release_date_verification}    DMI004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI004.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t bios | grep Release
    Should Contain    ${out}    ${dmidecode_release_date}
    Exit from root user
    IF    ${release_date_from_sol}
        Firmware release date verification from SOL
    END

DMI005.001 Verify the firmware manufacturer
    [Documentation]    Check whether the firmware manufacturer on the DUT is
    ...    the same as it is expected.
    Skip If    not ${manufacturer_verification}    DMI005.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI005.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t system | grep Manufacturer
    Should Contain    ${out}    ${dmidecode_manufacturer}
    ${out}=    Execute Linux command    dmidecode -t baseboard | grep Manufacturer
    Should Contain    ${out}    ${dmidecode_manufacturer}
    Exit from root user

DMI006.001 Verify the firmware vendor
    [Documentation]    Check whether the firmware vendor on the DUT is the same
    ...    as it is expected.
    Skip If    not ${vendor_verification}    DMI006.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI006.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t bios | grep Vendor
    Should Contain    ${out}    ${dmidecode_vendor}
    Exit from root user

DMI007.001 Verify the firmware family
    [Documentation]    Check whether the firmware family on the DUT is the same
    ...    as it is expected.
    Skip If    not ${family_verification}    DMI007.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI007.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t system | grep Family
    Should Contain    ${out}    ${dmidecode_family}
    Exit from root user

DMI008.001 Verify the firmware type
    [Documentation]    Check whether the firmware type on the DUT is the same
    ...    as it is expected.
    Skip If    not ${type_verification}    DMI008.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    DMI008.001 not supported
    Power On
    Boot system or from connected disk    ubuntu
    Login to Linux
    Switch to root user
    Detect or Install Package    dmidecode
    ${out}=    Execute Linux command    dmidecode -t chassis | grep Type
    Should Contain    ${out}    ${dmidecode_type}
    Exit from root user
