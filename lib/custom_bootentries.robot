*** Settings ***
Documentation       Library for managing custom EFI bootentries. Targeted for
...                 tests that run without serial connection and rely on boot order.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Keywords ***
Get BootOrder
    ${out}=    Execute Command In Terminal    efibootmgr | sed -n 's/^BootOrder: *//p'
    ${out}=    Strip String    ${out}
    Should Match Regexp    ${out}    ^[0-9A-Fa-f]{4}(,[0-9A-Fa-f]{4})*$
    RETURN    ${out}

Get Custom Bootentry Name
    [Arguments]    ${os_id}
    ${bootname}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${os_id}
    VAR    ${custom_bootname}=    ${bootname} OSFV
    RETURN    ${custom_bootname}

Get Bootnum For OS
    [Arguments]    ${os_id}
    VAR    ${label}=    ${ENV_ID_OS_BOOTMENU_NAMES[${os_id}]}
    ${boot}=    Get Bootnum For Label    ${label}
    RETURN    ${boot}

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

Get Bootnums For OS
    [Arguments]    ${os_id}
    ${label}=    Get From Dictionary    ${ENV_ID_OS_BOOTMENU_NAMES}    ${os_id}
    ${out}=    Get Bootnums For Label    ${label}
    RETURN    ${out}

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
        Log    ${custom_label} Already exists at ${bootnums}    level=WARN
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
        @{dst_nums}=    Get Bootnums For Label    ${custom_label}
        Log    Removing all existing ${custom_label} entries: ${dst_nums}    level=WARN
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
