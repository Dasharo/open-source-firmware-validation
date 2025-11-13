*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     DCU Suite Setup
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DCU001.201 Change the UUID (Ubuntu)
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    ...    Previous IDs: DCU001.001
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.201 not supported
    Change The UUID    ${ENV_ID_UBUNTU}

DCU002.201 Change the serial number (Ubuntu)
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    ...    Previous IDs: DCU002.001
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.201 not supported
    Change The Serial Number    ${ENV_ID_UBUNTU}

DCU003.201 Change the bootsplash logo (Ubuntu)
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    ...    Previous IDs: DCU003.001
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.201 not supported
    Change The Bootsplash Logo    ${ENV_ID_UBUNTU}

DCU004.201 Verify SMMSTORE changes (Ubuntu)
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    ...    Previous IDs: DCU004.001
    Skip If
    ...    '''${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}''' == '''${EMPTY}'''
    ...    DCU004.201 Verify SMMSTORE changes not supported
    Verify SMMSTORE Changes    ${ENV_ID_UBUNTU}
