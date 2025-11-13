*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     SUSP Suite Setup
...                     AND    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    Fedora not supported
...                     AND    Init SUSP Fedora
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SUSP005.202 Cyclic platform suspend and resume (Fedora)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.202 not supported
    Cyclic Platform Suspend And Resume

SUSP006.202 Cyclic platform suspend and resume (Fedora) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix

SUSP007.202 Cyclic platform suspend and resume (Fedora) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3


*** Keywords ***
Init SUSP Fedora
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
