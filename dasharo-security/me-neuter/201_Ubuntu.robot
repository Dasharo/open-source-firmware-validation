*** Settings ***
Resource            common.resource

Suite Setup         Prepare Test Suite
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MNE002.201 Intel ME mode option Enabled works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state Enabled
    ...    works correctly.
    ...    Previous IDs: MNE002.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE002.201 not supported
    Intel ME Mode Option Enabled Works Correctly    ${ENV_ID_UBUNTU}

MNE003.201 Intel ME mode option Disabled (Soft) works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (Soft) works correctly
    ...    Previous IDs: MNE003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE003.201 not supported
    Intel ME Mode Option Disabled (Soft) Works Correctly    ${ENV_ID_UBUNTU}

MNE004.201 Intel ME mode option Disabled (HAP) works correctly (Ubuntu)
    [Documentation]    Check whether the Intel ME mode option in state
    ...    Disabled (HAP) works correctly.
    ...    Previous IDs: MNE004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE004.201 not supported
    Intel ME Mode Option Disabled (HAP) Works Correctly    ${ENV_ID_UBUNTU}

MNE006.201 Check Intel ME version (Ubuntu)
    [Documentation]    This test aims to verify that the Intel ME version might
    ...    be read on the Operating System level. The read version should be
    ...    the same as in the release notes.
    ...    Previous IDs: MNE006.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    MNE006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    MNE004.201 not supported
    Check Intel ME Version    ${ENV_ID_UBUNTU}
