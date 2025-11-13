*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     DCU Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
DCU001.202 Change the UUID (Fedora)
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.202 not supported
    Change The UUID    ${ENV_ID_FEDORA}

DCU002.202 Change the serial number (Fedora)
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.202 not supported
    Change The Serial Number    ${ENV_ID_FEDORA}

DCU003.202 Change the bootsplash logo (Fedora)
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.202 not supported
    Change The Bootsplash Logo    ${ENV_ID_FEDORA}

DCU004.202 Verify SMMSTORE changes (Fedora)
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in Setup menu.
    ...    Verified using Setup menu where possible. When tested on a device
    ...    which uses DCU for accessing Setup variables the results might not
    ...    be trustworthy.
    Skip If
    ...    '''${DCU_SUPPORTED_BOOLEAN_SMMSTORE_VARIABLE}''' == '''${EMPTY}'''
    ...    DCU004.202 Verify SMMSTORE changes not supported
    Verify SMMSTORE Changes    ${ENV_ID_FEDORA}
