*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             FakerLibrary
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
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DCU001.001 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU001.001 not supported

    ${uuid}=    Uuid 4
    ${result}=    Run Process    bash    -c    ./dcu/dcu smbios -u ${uuid} ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${uuid_read}=    Get Firmware UUID
    Should Be Equal As Strings    '${uuid}'    '${uuid_read}'

DCU002.001 Change the serial number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU002.001 not supported

    ${serial_no}=    Random Int    min=10000000    max=99999999
    ${result}=    Run Process    bash    -c    ./dcu/dcu smbios -s ${serial_no} ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${serial_no_read}=    Get Firmware Serial Number
    Should Be Equal As Strings    '${serial_no}'    '${serial_no_read}'

DCU003.001 Change the bootsplash logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.001 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU003.001 not supported

    ${img_sum}=    Set Variable    f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513
    ${result}=    Run Process    bash    -c    ./dcu/dcu logo -l ./dcu/logo.bmp ./dcu/coreboot.rom
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot System Or From Connected Disk    ubuntu
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal
    ...    sha256sum /sys/firmware/acpi/bgrt/image
    ${unplugged}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    No such file
    IF    ${unplugged} == ${TRUE}
        Fail    Please make sure that a display device is connected to the DUT
    END
    Should Contain    ${out}    ${img_sum}

DCU004.001 Verify SMMSTORE changes
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in EDK2.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU003.001 not supported

    #
    #    Section where the SMMSTORE gets edited via (yet unknown) DCU commands
    #    and the resulting image gets flashed onto the DUT
    #
    #    We expect to set:
    #    bool
    #    SerialRedirection -> true
    #    NetworkBoot -> true
    #    uint16
    #    Timeout -> 8
    #    uint8
    #    PowerFailureState -> 1
    #    ascii
    #    Lang -> eng //actually french, check correct code
    #    PlatformLang -> en
    #

    # Power On

    # ${setup_menu}=    Enter Setup Menu And Return Construction
    # Should Contain Match    ${setup_menu}    *Standard English*

    # ${dsf_index}=    Get Index Of Matching Option In Menu    ${setup_menu}    Dasharo System Features
    # ${bmm_index}=    Get Index Of Matching Option In Menu    ${setup_menu}    Boot Maintenance Manager
    # ${rel_index}=    Evaluate    ${bmm_index}-${dsf_index}
    # ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    # ${sp_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Serial Port Configuration
    # ${state}=    Get Option State    ${sp_menu}    Enable Serial Port
    # Should Be Equal    ${state}    ${TRUE}
    # Press Key N Times    2    ${ESC}

    # Press Key N Times And Enter    ${rel_index}    ${ARROW_DOWN}
    # ${bmm_menu}=    Get Submenu Construction
    # ${state}=    Get Option State    ${bmm_menu}    Auto Boot Time-out
    # Should Be Equal    ${state}    8
    # Press Key N Times    2    ${ESC}

    # Press Key N Times And Enter    ${rel_index}    ${ARROW_UP}
    # ${dasharo_menu}=    Get Submenu Construction
    # ${pmo_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
    # ${state}=    Get Option State    ${pmo_menu}    Power state after power
    # Should Be Equal    ${state}    Powered On
    Skip    smmstoretool ins not yet supported in DCU


*** Keywords ***
Prepare DCU Test Environment
    Run    git clone https://github.com/Dasharo/dcu

    Download To Host Cache
    ...    logo.bmp
    ...    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download
    ...    6e5a6722955e4f78d947654630f27ff833703fbc04776ffed963c96617f6bb2a

    Run    cp ${FW_FILE} dcu/coreboot.rom
    ${local_path}=    Join Path    ${DL_CACHE_DIR}    logo.bmp
    Run    cp ${local_path} dcu/logo.bmp
