*** Settings ***
Resource    common.resource

Suite Setup       Run Keywords
...                   Prepare Test Suite
...                   AND    Skip If    not ${DASHARO_INTEL_ME_MENU_SUPPORT}    Dasharo Intel ME menu not supported
...                   AND    Set UEFI Option    MeMode    Enabled
...                   AND    Log Out And Close Connection

*** Keywords ***
