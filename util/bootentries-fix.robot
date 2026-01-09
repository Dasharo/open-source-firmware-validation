*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../lib/cbmem.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
Test bootentries fix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Log In To Linux
    Switch To Root User

    ${bootorder_initial}=    Get BootOrder
    Log To Console    BootOrder initial: ${bootorder_initial}

    ${custom_bootnum}=    Ensure Custom Entry    Ubuntu    force=${TRUE}
    Log To Console    Ubuntu custom Boot####: ${custom_bootnum}

    ${bootorder_after_step1}=    Get BootOrder
    Log To Console    BootOrder after Step 1: ${bootorder_after_step1}
    BootOrder Should Start With Bootnum    ${bootorder_after_step1}    ${custom_bootnum}

    ${ubuntu_bootnum}=    Get Bootnum For Label    Ubuntu
    Log To Console    Ubuntu Boot####: ${ubuntu_bootnum}

    # Step 2: flash firmware option and check BootOrder timing
    # Set UEFI Option    ${UEFI_OPTION_NAME}    TRUE

    ${bootorder_immediate}=    Get BootOrder
    Log To Console    BootOrder immediately after Set UEFI Option returned: ${bootorder_immediate}

    Execute Reboot Command    assume_correct_boot=${TRUE}
    Log In To Linux
    Switch To Root User

    ${bootorder_after_reboot}=    Get BootOrder
    Log To Console    BootOrder after reboot: ${bootorder_after_reboot}


*** Keywords ***
Get BootOrder
    ${out}=    Execute Command In Terminal    efibootmgr | sed -n 's/^BootOrder: *//p'
    ${out}=    Strip String    ${out}
    Should Match Regexp    ${out}    ^[0-9A-Fa-f]{4}(,[0-9A-Fa-f]{4})*$
    RETURN    ${out}

Get Bootnum For Label
    [Arguments]    ${label}
    ${txt}=    Execute Command In Terminal    efibootmgr
    ${txt}=    Replace String    ${txt}    \r    ${EMPTY}
    ${hits}=    Get Regexp Matches
    ...    ${txt}
    ...    (?m)^Boot([0-9A-Fa-f]{4})[^\\n]*\\s${label}(\\s|$)
    ...    1
    Should Not Be Empty    ${hits}
    ${boot}=    Get From List    ${hits}    0
    RETURN    ${boot}

Get Bootnums For Label
    [Arguments]    ${label}
    ${nums}=    Execute Command In Terminal
    ...    efibootmgr | grep -F "${label}" | sed -n 's/^Boot\\([0-9A-Fa-f]\\{4\\}\\).*/\\1/p'
    ${nums}=    Strip String    ${nums}
    IF    $nums == ''
        VAR    @{out}=    @{EMPTY}
    ELSE
        @{out}=    Split To Lines    ${nums}
    END
    RETURN    @{out}

BootOrder Should Start With Bootnum
    [Arguments]    ${bootorder}    ${bootnum}
    @{entries}=    Split String    ${bootorder}    ,
    Should Be Equal    ${entries}[0]    ${bootnum}

Ensure Custom Entry
    [Arguments]    ${os_label}    ${force}=${FALSE}
    VAR    ${custom_label}=    ${os_label} OSFV
    ${bootnums}=    Get Bootnums For Label    ${custom_label}
    ${already_exists}=    Run Keyword And Return Status    Should Not Be Empty    ${bootnums}
    IF    ${already_exists} and not ${force}
        Log To Console    ${custom_label} Already exists    level=WARN
        RETURN
    END

    # Get original bootentry
    ${src_num}=    Get Bootnum For Label    ${os_label}
    ${src_line}=    Execute Command In Terminal    efibootmgr | grep -E "^Boot${src_num}\\*?"
    ${src_line}=    Strip String    ${src_line}
    Should Not Be Empty    ${src_line}

    # Get its loader file and disk partition
    ${loader}=    Extract Loader From EfiLine    ${src_line}
    ${partuuid}=    Extract Partuuid From EfiLine    ${src_line}

    ${part_dev}=    Execute Command In Terminal
    ...    lsblk -rno PATH,PARTUUID | grep -i "${partuuid}" | awk '{print $1}' | head -n 1
    ${part_dev}=    Strip String    ${part_dev}
    Should Not Be Empty    ${part_dev}

    ${pkname}=    Execute Command In Terminal    lsblk -no PKNAME ${part_dev} | head -n 1
    ${pkname}=    Strip String    ${pkname}
    Should Not Be Empty    ${pkname}
    VAR    ${disk_dev}=    /dev/${pkname}

    ${part_num}=    Execute Command In Terminal
    ...    printf '%s' "${part_dev}" | sed -n 's/.*[^0-9]\\([0-9][0-9]*\\)$/\\1/p'
    ${part_num}=    Strip String    ${part_num}
    Should Match Regexp    ${part_num}    ^[0-9]+$

    IF    ${already_exists} and ${force}
        # Remove any existing "Ubuntu custom" entries (collect bootnums first, then delete one by one)
        @{dst_nums}=    Get Bootnums For Label    ${custom_label}
        FOR    ${n}    IN    @{dst_nums}
            Execute Command In Terminal    efibootmgr -b ${n} -B
        END
    END

    # Create the new entry (efibootmgr expects a UEFI-style path; ensure a single leading backslash)
    Execute Command In Terminal
    ...    efibootmgr --create --disk ${disk_dev} --part ${part_num} --label "${custom_label}" --loader "\\${loader}"

    ${dst_num}=    Get Bootnum For Label    ${custom_label}
    ${order}=    Get BootOrder
    ${new_order}=    Prepend Bootnum To Bootorder    ${dst_num}    ${order}
    Execute Command In Terminal    efibootmgr -o ${new_order}

    RETURN    ${dst_num}

Extract Loader From EfiLine
    [Arguments]    ${line}
    ${txt}=    Replace String    ${line}    \r    ${EMPTY}
    ${matches}=    Get Regexp Matches    ${txt}    /File\\(([^)]*)\\)    1
    Should Not Be Empty    ${matches}

    ${loader}=    Get From List    ${matches}    0
    ${loader}=    Strip String    ${loader}
    ${loader}=    Replace String    ${loader}    "    ${EMPTY}
    Should Not Be Empty    ${loader}

    RETURN    ${loader}

Extract Partuuid From EfiLine
    [Arguments]    ${line}
    ${matches}=    Get Regexp Matches    ${line}    HD\\([^,]*,[^,]*,([0-9a-fA-F-]{36}),    1
    Should Not Be Empty    ${matches}
    ${partuuid}=    Get From List    ${matches}    0
    RETURN    ${partuuid}

Prepend Bootnum To Bootorder
    [Arguments]    ${bootnum}    ${bootorder}
    # Removes bootnum (case-insensitive) then prepends it.
    ${new}=    Execute Command In Terminal
    ...    echo "${bootorder}" | awk -v B="${bootnum}" -F, 'BEGIN{b=tolower(B)}{out=B; for(i=1;i<=NF;i++){x=$i; if(tolower(x)!=b && x!="") out=out "," x} print out}'
    ${new}=    Strip String    ${new}
    Should Match Regexp    ${new}    ^[0-9A-Fa-f]{4}(,[0-9A-Fa-f]{4})*$
    RETURN    ${new}
