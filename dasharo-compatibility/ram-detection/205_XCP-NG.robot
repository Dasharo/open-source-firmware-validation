*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     MEM Suite Setup
...                     AND    Skip If    not ${TESTS_IN_XCP_NG_SUPPORT}    XCP-NG not supported
...                     AND    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    XCP-NG not supported
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
MEM001.205 Expected RAM size detected in OS (XCP-NG)
    [Documentation]    This test verifies that the installed physical memory (RAM)
    ...    is properly detected and reported by the XCP-NG OS.
    ...    Previous IDs: MEM001.010
    Power On
    Login To OS    ${ENV_ID_XCP_NG}

    ${meminfo}=    Execute Linux Command    cat /proc/meminfo | grep ^MemTotal
    Log    ${meminfo}

    ${mem_line}=    Fetch From Right    ${meminfo}    MemTotal:
    ${mem_line}=    Strip String    ${mem_line}
    ${mem_kb_str}=    Split String    ${mem_line}    ${SPACE}
    ${actual_kb}=    Convert To Integer    ${mem_kb_str}[0]

    ${delta}=    Evaluate    abs(${actual_kb} - ${PLATFORM_RAM_SIZE})
    VAR    ${tolerance}=    524288    # 512 MB tolerance

    Run Keyword Unless
    ...    ${delta} < ${tolerance}
    ...    Fail
    ...    RAM size mismatch: expected ~${PLATFORM_RAM_SIZE} kB, got ${actual_kb} kB (delta: ${delta})
