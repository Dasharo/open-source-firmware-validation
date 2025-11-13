*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     SUSP Suite Setup
...                     AND    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Ubuntu not supported
...                     AND    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    Ubuntu not supported
...                     AND    Init SUSP Ubuntu
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SUSP005.201 Cyclic platform suspend and resume (Ubuntu)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.001
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.201 not supported
    Cyclic Platform Suspend And Resume

SUSP006.201 Cyclic platform suspend and resume (Ubuntu) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.002
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix

SUSP007.201 Cyclic platform suspend and resume (Ubuntu) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    ...    Previous IDs: SUSP005.003
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3


*** Keywords ***
Init SUSP Ubuntu
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
