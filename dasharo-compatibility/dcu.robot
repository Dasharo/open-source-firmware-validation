*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
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
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Prepare DCU Test Environment
...                     AND
...                     Make Sure That Flash Locks Are Disabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DCU001.001 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${UUID_SETTABLE}    DCU001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU001.001 not supported

    ${uuid}=    Set Variable    96bcfa1a-42b4-6717-a44c-d8bbc18cbea4
    ${result}=    Run Process    bash    -c    ./dcu/dcu smbios -u ${uuid} ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${uuid_read}=    Get Firmware UUID
    Should Be Equal As Strings    '${uuid}'    '${uuid_read}'

DCU002.001 Change the serial number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${SERIAL_NUMBER_SETTABLE}    DCU002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU002.001 not supported

    ${serial_no}=    Set Variable    D01234567
    ${result}=    Run Process    bash    -c    ./dcu/dcu smbios -s ${serial_no} ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    ${serial_no_read}=    Get Firmware Serial Number
    Should Be Equal As Strings    '${serial_no}'    '${serial_no_read}'

DCU003.001 Change the bootsplash logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${BOOTSPLASH_SETTABLE}    DCU003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU003.001 not supported

    ${img_sum}=    Set Variable    6e5a6722955e4f78d947654630f27ff833703fbc04776ffed963c96617f6bb2a
    ${result}=    Run Process    bash    -c    ./dcu/dcu logo -l ./dcu/logo.bmp ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot Operating System    ubuntu
    Login To Linux
    Switch To Root User
    Write Into Terminal    sha256sum /sys/firmware/acpi/bgrt/image
    ${out}=    Read From Terminal Until Prompt
    Should Contain    ${out}    ${img_sum}


*** Keywords ***
Prepare DCU Test Environment
    Set Prompt For Terminal    :~$
    Run    git clone https://github.com/Dasharo/dcu
    Download To Host Cache
    ...    coreboot.rom
    ...    ${FW_URL}
    ...    aff826c08f7136752188c2abac14a3c3a08fa935e21186e536c4f8db7370c823
    Download To Host Cache
    ...    logo.bmp
    ...    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download
    ...    6e5a6722955e4f78d947654630f27ff833703fbc04776ffed963c96617f6bb2a
    ${local_path}=    Join Path    ${DL_CACHE_DIR}    coreboot.rom
    Run    cp ${local_path} dcu/coreboot.rom
    ${local_path}=    Join Path    ${DL_CACHE_DIR}    logo.bmp
    Run    cp ${local_path} dcu/logo.bmp
