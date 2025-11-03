*** Settings ***
Resource            common.resource

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MNE002.202 Intel ME mode option Enabled works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE002.202 not supported
    Intel ME Mode Option Enabled Works Correctly    ${ENV_ID_FEDORA}

MNE003.202 Intel ME mode option Disabled (Soft) works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE003.202 not supported
    Intel ME Mode Option Disabled (Soft) Works Correctly    ${ENV_ID_FEDORA}

MNE004.202 Intel ME mode option Disabled (HAP) works correctly (Fedora)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE004.202 not supported
    Intel ME Mode Option Disabled (HAP) Works Correctly    ${ENV_ID_FEDORA}

MNE006.202 Check Intel ME version (Fedora)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    MNE004.202 not supported
    Check Intel ME Version    ${ENV_ID_FEDORA}
