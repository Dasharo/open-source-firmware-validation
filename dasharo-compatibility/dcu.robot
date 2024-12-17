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
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../lib/dcu.robot

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


*** Variables ***
${FW_COPY}=     coreboot.rom


*** Test Cases ***
DCU001.001 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.001 not supported

    ${uuid}=    Uuid 4
    DCU Smbios Set UUID In File    ${FW_COPY}    ${uuid}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing

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

    ${serial_no}=    Random Int    min=10000000    max=99999999
    DCU Smbios Set Serial In File    ${FW_COPY}    ${serial_no}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing

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

    ${img_sum}=    Set Variable    f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513
    ${logo_path}=    Join Path    ${DL_CACHE_DIR}    logo.bmp
    DCU Logo Set In File    ${FW_COPY}    ${logo_path}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing

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
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    Skip If
    ...    '''${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}''' == '''${EMPTY}'''
    ...    DCU004.001 Verify SMMSTORE changes not supported
    IF    "${OPTIONS_LIB}"=="uefi-setup-menu"
        Verify SMMSTORE Changes (Setup Menu)
    ELSE IF    "${OPTIONS_LIB}"=="dcu"
        Log To Console
        ...    Verifying DCU possible only using on this device DCU. The test may not be trustworthy.
        ...    WARN
        Verify SMMSTORE Changes (DCU)
    ELSE
        Fail    Unsupported $OPTIONS_LIB: ${OPTIONS_LIB}
    END


*** Keywords ***
Prepare DCU Test Environment

    Copy File    ../osfv-test-data/coreboot_logo_convert.bmp    ${CURDIR}/../dl-cache/logo.bmp

    Run    cp ${FW_FILE} ${FW_COPY}
    Run    chmod -R a+rw dcu

Verify SMMSTORE Changes (Setup Menu)
    [Documentation]    This keyword verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.

    ${initial_value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    ${new_value}=    Evaluate    not ${initial_value}

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_value}

    ${value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${new_value}

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${initial_value}

    ${value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${initial_value}

Verify SMMSTORE Changes (DCU)
    [Documentation]    This keyword verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in DCU.

    # Initial value cannot be checked and restored using DCU because the
    # variable store may not be initialized yet.
    ${initial_value}=    Set Variable    ${FALSE}
    ${new_value}=    Set Variable    ${TRUE}

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_value}

    Login To Linux
    Switch To Root User
    ${value}=    DCU Variable Get UEFI Option From DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${new_value}
    DCU Variable Set UEFI Option In Dut    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${initial_value}

    Login To Linux
    Switch To Root User
    ${value}=    DCU Variable Get UEFI Option From DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${initial_value}

Make Sure New Firmware Is Booted After Flashing
    [Documentation]    Makes sure the platforms loads the newly flashed FW.
    ...    Platforms without POWER_CTRL typically do nothing
    ...    as an implementation of Power On etc. and they need a reboot after
    ...    flashing
    IF    '''${POWER_CTRL}''' == '''NONE'''
        Power On
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
        Execute Reboot Command
    END
