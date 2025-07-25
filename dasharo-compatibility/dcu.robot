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

Default Tags        automated


*** Variables ***
${FW_COPY}=     coreboot.rom


*** Test Cases ***
DCU001.201 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    ...    Previous IDs: DCU001.001
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DCU001.201 not supported
    Change The UUID    ${ENV_ID_UBUNTU}

DCU002.201 Change the serial number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    ...    Previous IDs: DCU002.001
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DCU002.201 not supported
    Change The Serial Number    ${ENV_ID_UBUNTU}

DCU003.201 Change the bootsplash logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    ...    Previous IDs: DCU003.001
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DCU003.201 not supported
    Change The Bootsplash Logo    ${ENV_ID_UBUNTU}

DCU004.201 Verify SMMSTORE changes
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    ...    Previous IDs: DCU004.001
    Skip If
    ...    '''${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}''' == '''${EMPTY}'''
    ...    DCU004.201 Verify SMMSTORE changes not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    DCU004.201 not supported
    Verify SMMSTORE Changes    ${ENV_ID_UBUNTU}

DCU001.202 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DCU001.202 not supported
    Change The UUID    ${ENV_ID_FEDORA}

DCU002.202 Change the serial number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DCU002.202 not supported
    Change The Serial Number    ${ENV_ID_FEDORA}

DCU003.202 Change the bootsplash logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DCU003.202 not supported
    Change The Bootsplash Logo    ${ENV_ID_FEDORA}

DCU004.202 Verify SMMSTORE changes
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    Skip If
    ...    '''${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}''' == '''${EMPTY}'''
    ...    DCU004.202 Verify SMMSTORE changes not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    DCU004.202 not supported
    Verify SMMSTORE Changes    ${ENV_ID_FEDORA}


*** Keywords ***
Prepare DCU Test Environment
    Read Firmware    ${FW_COPY}
    Run    chmod -R a+rw dcu

Verify SMMSTORE Changes (Setup Menu)
    [Documentation]    This keyword verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    [Arguments]    ${os_id}
    ${initial_value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    ${new_value}=    Evaluate    not ${initial_value}

    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_value}

    ${value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${new_value}

    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${initial_value}

    ${value}=    Get UEFI Option    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${initial_value}

Verify SMMSTORE Changes (DCU)
    [Documentation]    This keyword verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in DCU.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    # Initial value cannot be checked and restored using DCU because the
    # variable store may not be initialized yet.
    VAR    ${initial_value}=    ${FALSE}
    VAR    ${new_value}=    ${TRUE}

    Login To Linux
    Switch To Root User
    DCU Variable Set UEFI Option In DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${new_value}
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${value}=    DCU Variable Get UEFI Option From DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${new_value}
    DCU Variable Set UEFI Option In Dut    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}    ${initial_value}
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${value}=    DCU Variable Get UEFI Option From DUT    ${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}
    Should Be Equal    ${value}    ${initial_value}

Make Sure New Firmware Is Booted After Flashing
    [Documentation]    Makes sure the platforms loads the newly flashed FW.
    ...    Platforms without POWER_CTRL typically do nothing
    ...    as an implementation of Power On etc. and they need a reboot after
    ...    flashing
    [Tags]    robot:private
    [Arguments]    ${os_id}=${DEFAULT_BOOT_OS_ID}
    IF    '''${POWER_CTRL}''' == '''none'''
        Power On
        Boot System Or From Connected Disk    ${os_id}
        Login To Linux
        Switch To Root User
        Execute Reboot Command
    END

Change The UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}

    ${uuid}=    Uuid 4
    DCU Smbios Set UUID In File    ${FW_COPY}    ${uuid}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing    ${os_id}

    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${uuid_read}=    Get Firmware UUID
    Should Be Equal As Strings    '${uuid}'    '${uuid_read}'

Change The Serial Number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    ${serial_no}=    Random Int    min=10000000    max=99999999
    Read Firmware    ${FW_COPY}
    DCU Smbios Set Serial In File    ${FW_COPY}    ${serial_no}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing    ${os_id}

    Power On
    Boot System Or From Connected Disk    ${os_id}
    Login To Linux
    Switch To Root User
    ${serial_no_read}=    Get Firmware Serial Number
    Should Be Equal As Strings    '${serial_no}'    '${serial_no_read}'

Change The Bootsplash Logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    Power On
    Boot System Or From Connected Disk    ${os_id}
    VAR    ${img_sum}=    f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513
    ${logo_path}=    Join Path    ${TEST_DATA_DIR}/dcu    logo.bmp
    Read Firmware    ${FW_COPY}
    DCU Logo Set In File    ${FW_COPY}    ${logo_path}
    Flash Firmware    ${FW_COPY}
    Make Sure New Firmware Is Booted After Flashing

    Power On
    Boot System Or From Connected Disk    ${os_id}
    VAR    ${DUT_CONNECTION_METHOD}=    SSH    scope=GLOBAL
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

Verify SMMSTORE Changes
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    [Tags]    robot:private
    [Arguments]    ${os_id}
    IF    "${OPTIONS_LIB}"=="options-lib_uefi-setup-menu"
        Verify SMMSTORE Changes (Setup Menu)    ${os_id}
    ELSE IF    "${OPTIONS_LIB}"=="options-lib_dcu"
        Log To Console
        ...    Verifying DCU possible only using on this device DCU. The test may not be trustworthy.
        ...    WARN
        Verify SMMSTORE Changes (DCU)    ${os_id}
    ELSE
        Fail    Unsupported $OPTIONS_LIB: ${OPTIONS_LIB}
    END
