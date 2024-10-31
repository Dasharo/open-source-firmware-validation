# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Keywords ***
Detect Heads Main Menu
    [Documentation]    Keyword waits and detects Heads main menu. Content of
    ...    main menu window is returned.
    Set DUT Response Timeout    300s
    Read From Terminal Until    Heads Boot Menu
    ${output}=    Read From Terminal Until    ┘
    Sleep    1s
    RETURN    ${output}

Enter Heads Recovery Shell
    [Documentation]    Keyword allows to enter Heads recovery shell from Heads
    ...    main menu.
    Write Bare Into Terminal    o
    Sleep    0.5s
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    ┘
    Sleep    0.5s
    Write Bare Into Terminal    x
    Sleep    0.5s
    Write Bare Into Terminal    ${ENTER}
    Sleep    0.5s
    Read From Terminal Until    User requested recovery shell
    Set Prompt For Terminal    ${HEADS_PROMPT}
    Read From Terminal Until Prompt

Get TPM PCRs
    [Documentation]    Keyword allows to gets and returns TPM PCRs from Heads
    ...    recovery shell.
    Write Into Terminal    cat /sys/class/tpm/tpm0/pcrs
    ${output}=    Read From Terminal Until Prompt
    @{output_split}=    Split String    ${output}    separator=\r\n
    @{tpm_pcrs}=    Create List
    FOR    ${line}    IN    @{output_split}
        IF    "${line}"!="${EMPTY}" and "${line}"!="${SPACE}"
            Append To List    ${tpm_pcrs}    ${line[:-1]}
        END
    END
    RETURN    ${tpm_pcrs}

Reboot Platform From Shell
    [Documentation]    Keyword allows to reboot platform by executing 'reboot'
    ...    from Heads shell. 'Execute reboot command' can't be used with Heads
    ...    because sysrq is used and output differs.
    Write Into Terminal    reboot
    Read From Terminal Until    sysrq: Resetting
