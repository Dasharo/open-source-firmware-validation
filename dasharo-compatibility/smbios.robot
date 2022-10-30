*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
Library             ../../lib/TestingStands.py
Resource            ../keys-and-keywords/setup-keywords.robot
Resource            ../keys-and-keywords/keys.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../sonoff-rest-api/sonoff-api.robot

Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
DMI001.001 Verify the device serial number
    [Documentation]    This test aims to verify that the serial number field
    ...    is filled in correctly according to the Dasharo SMBIOS guidelines.
    Skip If    not ${smbios_serial_number_verification}    DMI001.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t bios | grep Serial
    Should Contain    ${out}    ${dmidecode_serial_number}
    IF    ${serial_from_MAC}    Compare Serial Number from MAC    ${out}
    Logout from Linux with Root Privileges

DMI002.001 Verify the firmware version
    [Documentation]    This test aims to verify that the firmware version field
    ...    is filled in correctly according to the Dasharo SMBIOS guidelines.
    Skip If    not ${smbios_firmware_version_verification}    DMI002.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t bios | grep Version
    Should Contain    ${out}    ${dmidecode_firmware_version}
    Logout from Linux with Root Privileges
    IF    ${firmware_from_binary}    Firmware version verification from binary

DMI003.001 Verify the firmware product name
    [Documentation]    This test aims to verify that the firmware product name
    ...    fields are filled in correctly according to the Dasharo SMBIOS
    ...    guidelines.
    Skip If    not ${smbios_product_name_verification}    DMI003.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t system | grep Product
    Should Contain    ${out}    ${dmidecode_product_name}
    Logout from Linux with Root Privileges

DMI004.001 Verify the firmware release date
    [Documentation]    This test aims to verify that the firmware release date
    ...    field are filled in correctly according to the Dasharo SMBIOS
    ...    guidelines.
    Skip If    not ${smbios_release_date_verification}    DMI004.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t bios | grep Release
    Should Contain    ${out}    ${dmidecode_release_date}
    Logout from Linux with Root Privileges
    IF    ${release_date_from_sol}
        Firmware release date verification from SOL
    END

DMI005.001 Verify the firmware manufacturer
    [Documentation]    This test aims to verify that the firmware manufacturer
    ...    fields are filled in correctly according to the Dasharo SMBIOS
    ...    guidelines.
    Skip If    not ${smbios_manufacturer_verification}    DMI005.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t system | grep Manufacturer
    Should Contain    ${out}    ${dmidecode_manufacturer}
    ${out}=    Execute Command In Terminal    dmidecode -t baseboard | grep Manufacturer
    Should Contain    ${out}    ${dmidecode_manufacturer}
    Logout from Linux with Root Privileges

DMI006.001 Verify the firmware vendor
    [Documentation]    This test aims to verify that the firmware vendor field
    ...    is filled in correctly according to the Dasharo SMBIOS guidelines.
    Skip If    not ${smbios_vendor_verification}    DMI006.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t bios | grep Vendor
    Should Contain    ${out}    ${dmidecode_vendor}
    Logout from Linux with Root Privileges

DMI007.001 Verify the firmware family
    [Documentation]    This test aims to verify that the firmware family field
    ...    is filled in correctly according to the Dasharo SMBIOS guidelines.
    Skip If    not ${smbios_family_verification}    DMI007.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t system | grep Family
    Should Contain    ${out}    ${dmidecode_family}
    Logout from Linux with Root Privileges

DMI008.001 Verify the firmware type
    [Documentation]    This test aims to verify that the firmware type field is
    ...    filled in correctly according to the Dasharo SMBIOS guidelines.
    Skip If    not ${smbios_firmware_type_verification}    DMI008.001 not supported
    Power On
    Boot Operating System    ubuntu
    Login to System with Root Privileges    ubuntu
    Detect or Install Package    dmidecode
    ${out}=    Execute Command In Terminal    dmidecode -t chassis | grep Type
    Should Contain    ${out}    ${dmidecode_type}
    Logout from Linux with Root Privileges
