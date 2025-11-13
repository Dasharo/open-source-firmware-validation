*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     MEM Suite Setup
...                     AND    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    ESXi not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MEM001.401 Expected RAM size detected in OS (ESXi)
    [Documentation]    Verify that the installed RAM is correctly recognized by ESXi.
    ...    Total memory reported should match the expected amount within a reasonable margin.
    ...    Previous IDs: MEM001.011
    Power On
    IF    ${HAS_E_CORES}    Set UEFI Option    ActiveECores    0
    Login To OS    ${ENV_ID_ESXI}
    Sleep    5s
    ${out}=    Execute Command In Terminal    esxcli hardware memory get
    ${ram_size_line}=    Get Regexp Matches    ${out}    Physical Memory:\\s*(\\d+)    1
    ${ram_size_str}=    Get From List    ${ram_size_line}    0
    ${ram_size}=    Convert To Integer    ${ram_size_str}
    IF    ${ram_size} <= ${SIZE_OF_31_GB} or ${ram_size} >= ${SIZE_OF_33_GB}
        Fail    RAM size out of scope.\n
    END
