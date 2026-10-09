*** Settings ***
Documentation       Keywords for driving Heads over the serial console. Heads
...                 mirrors its dialogs (text-mode whiptail) and prompts to the
...                 serial console, so the menus can be read and answered there.
...                 Notes on dialogs:
...                 - a dialog is fully drawn once its bottom right corner (┘)
...                 was printed, read up to it before answering
...                 - menu entries are chosen by typing their tag and Enter,
...                 as separate writes with a small delay
...                 - tags are case-sensitive, e.g. 'r' and 'R' differ


*** Variables ***
# Timeout for a Heads dialog to show up, e.g. after a reflash or a boot
${HEADS_DIALOG_TIMEOUT}=    600s
# Defaults of OEM Factory Reset / Re-Ownership with default options
${HEADS_TPM_PASS}=          12345678
${HEADS_ADMIN_PIN}=         12345678
${HEADS_USER_PIN}=          123456
${HEADS_TOTP_SECRET}=       ${EMPTY}
# Heads on QEMU (platform-configs/qemu-heads.robot), set here so they can be
# overridden on the command line:
# Directory for test data made at runtime (USB images, GPG test keys)
${HEADS_QEMU_WORKDIR}=      /tmp/osfv/heads
# Unmodified Heads ROM of the board under test, for "Add GPG key to
# standalone BIOS image and flash"; the test is skipped when empty
${HEADS_ROM_FILE}=          ${EMPTY}
# USB security dongle given to QEMU (HEADS_USB_TOKEN of qemu-run.sh): nk3,
# canokey or none; tests needing a dongle are skipped with none
${HEADS_USB_TOKEN}=         nk3
# Bootable ISO for "Boot from USB"; the test is skipped when empty
${HEADS_TEST_ISO}=          ${EMPTY}


*** Keywords ***
Detect Heads Main Menu
    [Documentation]    Keyword waits and detects Heads main menu. Content of
    ...    main menu window is returned. Dialogs Heads shows before the main
    ...    menu are answered to continue to it:
    ...    - "No /boot Partition Found" (no OS installed)
    ...    - "GPG signing key unavailable" (no USB Security dongle with keys)
    ...    - "TOTP Generation Failed" / "HOTP Validation Failed" (no secret
    ...    sealed yet, e.g. after OEM Factory Reset): ignored, the tests
    ...    generate a new secret from the menu when they need one
    ...    - "GPG keyring empty" (freshly flashed ROM): ignored
    ...    - "OEM Factory Reset / Re-Ownership" (offered on a clean boot: OS
    ...    installed, no GPG keys, dongle present): cancelled
    ...    - "TPM State Inconsistent" (TPM rollback counter gone): continued
    ...    Fails right away on any other dialog, showing it. ${answered} is
    ...    the title of a dialog the caller just answered, whose redraws are
    ...    skipped.
    [Arguments]    ${answered}=${EMPTY}
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}
    # Choosing an entry redraws the dialog before it closes: skip redraws of
    # the dialog just answered, answer each dialog once. Titles may contain
    # color codes, so compare by substring.
    # "TPM State Inconsistent" (26 rows) is taller than the 24 row serial
    # console: its title and bottom corner are not drawn there, so also
    # stop at its last entry
    VAR    ${rollback_answered}=    ${FALSE}
    FOR    ${i}    IN RANGE    20
        ${output}=    Read From Terminal Until Regexp
        ...    ┘|TPM rollback protection[\\s\\S]*?Continue to main menu
        ${titles}=    Get Regexp Matches    ${output}    ┤\\s*([^├]*?)\\s*├    1
        IF    ${titles}
            VAR    ${title}=    ${titles}[-1]
        ELSE
            VAR    ${title}=    ${EMPTY}
        END
        IF    'Cannot verify TPM rollback protection' in $output and not $rollback_answered
            # TPM counter of /boot/kexec_rollback.txt gone, e.g. after a TPM
            # reset by "Clear GPG key(s) and reset all user settings":
            # continue, OEM Factory Reset or a TPM reset fixes it
            Choose Heads Option    m
            VAR    ${rollback_answered}=    ${TRUE}
            CONTINUE
        END
        IF    $answered and $answered in $title    CONTINUE
        IF    'Heads Boot Menu' in $title
            Sleep    1s
            RETURN    ${output}
        ELSE IF    'No /boot Partition Found' in $title
            VAR    ${HEADS_BOOT_PARTITION_FOUND}=    ${FALSE}    scope=SUITE
            Choose Heads Option    m
        ELSE IF    'GPG signing key unavailable' in $title
            Choose Heads Option    m
        ELSE IF    re.search('[TH]OTP Generation Failed|HOTP Validation Failed|GPG keyring empty', $title)
            # 'i' is not drawn when the entry list scrolls, but still works
            Choose Heads Option    i
        ELSE IF    'OEM Factory Reset / Re-Ownership' in $title and 'Complete' not in $title
            Focus Heads Dialog Buttons    ${output}
            # Tab moves the focus to <Cancel>
            Write Bare Into Terminal    \t
            Sleep    0.5s
            Write Bare Into Terminal    ${ENTER}
        ELSE IF    $title
            Fail    Unexpected Heads dialog before the main menu:\n${output}
        END
        IF    $title    VAR    ${answered}=    ${title}
    END
    Fail    Heads main menu not reached

Wait For Heads Dialog
    [Documentation]    Reads the serial console until the dialog titled
    ...    ${title} is fully drawn and returns what was read.
    [Arguments]    ${title}
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}
    Read From Terminal Until    ${title}
    ${output}=    Read From Terminal Until    ┘
    Sleep    0.5s
    RETURN    ${output}

Choose Heads Option
    [Documentation]    Chooses the entry tagged ${tag} in the menu currently
    ...    shown (already read from the terminal).
    [Arguments]    ${tag}
    Write Bare Into Terminal    ${tag}
    Sleep    0.5s
    Write Bare Into Terminal    ${ENTER}

Choose From Heads Menu
    [Documentation]    Waits for the menu titled ${title}, checks that it has
    ...    the entry ${tag} ${text} and chooses it. Returns the menu.
    [Arguments]    ${title}    ${tag}    ${text}
    ${menu}=    Wait For Heads Dialog    ${title}
    Heads Menu Should Have Option    ${menu}    ${tag}    ${text}
    Choose Heads Option    ${tag}
    RETURN    ${menu}

Heads Menu Should Have Option
    [Documentation]    Checks that ${menu} (a menu read from the terminal)
    ...    has the entry tagged ${tag} with text ${text}.
    [Arguments]    ${menu}    ${tag}    ${text}
    ${text_re}=    Regexp Escape    ${text}
    Should Match Regexp    ${menu}    ${tag}\\s+${text_re}

Answer Heads Yes No
    [Documentation]    Waits for the yes/no dialog titled ${title} and answers
    ...    it: Yes (the first button) or No. Returns the dialog.
    [Arguments]    ${title}    ${answer}=Yes
    ${dialog}=    Wait For Heads Dialog    ${title}
    Focus Heads Dialog Buttons    ${dialog}
    IF    '${answer}' == 'No'
        # Tab moves the focus to the second button
        Write Bare Into Terminal    \t
        Sleep    0.5s
    END
    Write Bare Into Terminal    ${ENTER}
    RETURN    ${dialog}

Focus Heads Dialog Buttons
    [Documentation]    A dialog with more text than fits on the screen gets
    ...    a scrollable text box (with a scrollbar), which has the focus at
    ...    first: Tab moves it to the first button.
    [Arguments]    ${dialog}
    IF    '↓' in $dialog
        Write Bare Into Terminal    \t
        Sleep    0.5s
    END

Confirm Heads Message
    [Documentation]    Waits for the message dialog titled ${title} and
    ...    confirms it. Returns the dialog.
    [Arguments]    ${title}
    ${dialog}=    Wait For Heads Dialog    ${title}
    Focus Heads Dialog Buttons    ${dialog}
    Write Bare Into Terminal    ${ENTER}
    RETURN    ${dialog}

Answer Heads Prompt
    [Documentation]    Waits for the text prompt ${prompt} and answers it with
    ...    ${answer} followed by Enter.
    [Arguments]    ${prompt}    ${answer}=${EMPTY}
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}
    Read From Terminal Until    ${prompt}
    Sleep    0.5s
    Write Into Terminal    ${answer}

Answer Heads Key Prompt
    [Documentation]    Waits for the single key prompt ${prompt}, e.g.
    ...    "[Y/n]:", and answers it with ${key} (Enter takes the default).
    [Arguments]    ${prompt}    ${key}=${ENTER}
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}
    Read From Terminal Until    ${prompt}
    Sleep    0.5s
    Write Bare Into Terminal    ${key}

Open Heads Options Menu
    [Documentation]    Opens "Options" from the main menu, which must have
    ...    been read already, e.g. by Detect Heads Main Menu. Returns it.
    Choose Heads Option    o
    ${menu}=    Wait For Heads Dialog    Heads Options
    RETURN    ${menu}

Open Heads GPG Menu
    [Documentation]    Opens "Options" -> "GPG Options" from the main menu,
    ...    which must have been read already. Returns the GPG menu.
    ${options}=    Open Heads Options Menu
    Heads Menu Should Have Option    ${options}    g    GPG Options -->
    Choose Heads Option    g
    ${menu}=    Wait For Heads Dialog    GPG Management Menu
    RETURN    ${menu}

Power On Into Heads Main Menu
    [Documentation]    Powers the DUT on and waits for Heads' main menu,
    ...    which is returned. Sets ${HEADS_BOOT_PARTITION_FOUND} to whether
    ...    Heads found a /boot partition on this boot.
    VAR    ${HEADS_BOOT_PARTITION_FOUND}=    ${TRUE}    scope=SUITE
    Power On
    ${menu}=    Detect Heads Main Menu
    RETURN    ${menu}

Heads Boot Partition Should Be Found
    [Documentation]    Fails unless Heads found a /boot partition on the last
    ...    Power On Into Heads Main Menu. Heads seals TOTP/HOTP secrets only
    ...    with /boot signed by the dongle's key, which needs an OS installed
    ...    with a separate, unencrypted /boot partition.
    Should Be True    ${HEADS_BOOT_PARTITION_FOUND}
    ...    Heads found no /boot partition, needed to seal TOTP/HOTP secrets (see Heads in docs/qemu.md)

Wait For Heads Power Off
    [Documentation]    Answers the prompts of Heads' reboot (on QEMU boards
    ...    Heads powers off instead) until the VM stopped. Only for QEMU.
    Set DUT Response Timeout    60s
    FOR    ${i}    IN RANGE    10
        ${status}=    Get Qemu Status
        IF    '${status}' != 'running'    BREAK
        # No prompt in time: press Enter anyway, it may be waiting for one
        Run Keyword And Ignore Error    Read From Terminal Until Regexp
        ...    (continue reboot or 'r'|final reboot syscall|QEMU board - press Enter)
        Sleep    0.5s
        Write Bare Into Terminal    ${ENTER}
    END
    ${status}=    Get Qemu Status
    Should Not Be Equal    ${status}    running    DUT did not power off
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}

Attach Heads USB Image
    [Documentation]    Attaches the USB disk image ${path} to the VM, writable.
    [Arguments]    ${path}
    Add USB To Qemu    img_path=${path}    name=heads    read_only=${FALSE}    removable=${TRUE}

Detach Heads USB Image
    [Documentation]    Detaches the USB disk image attached by Attach Heads USB
    ...    Image, so its content can be read on the host.
    Remove USB From Qemu    name=heads

Heads Select USB File
    [Documentation]    Waits for Heads' file picker (title ${title}) and
    ...    picks the entry whose path ends with ${name}.
    [Arguments]    ${title}    ${name}
    # The picker is wider than the 80 column serial console, so its right
    # border (and bottom right corner) is not drawn: wait for the entry.
    Set DUT Response Timeout    ${HEADS_DIALOG_TIMEOUT}
    Read From Terminal Until    ${title}
    ${name_re}=    Regexp Escape    ${name}
    ${dialog}=    Read From Terminal Until Regexp    \\d+\\s+/media/\\S*${name_re}
    Sleep    1s
    ${index}=    Get Regexp Matches    ${dialog}    (\\d+)\\s+/media/\\S*${name_re}    1
    Should Not Be Empty    ${index}    ${name} not offered in "${title}"
    Choose Heads Option    ${index}[0]

Get Heads GPG Keyring
    [Documentation]    From the main menu (already read), lists the GPG
    ...    keyring via "Options" -> "GPG Options" and returns the listing.
    Open Heads GPG Menu
    Choose Heads Option    l
    ${keyring}=    Read Heads Scrolled Message    GPG Keyring
    RETURN    ${keyring}

Read Heads Scrolled Message
    [Documentation]    Waits for the message dialog titled ${title}, pages
    ...    through its text if it does not fit on the screen, confirms it and
    ...    returns all the text read.
    [Arguments]    ${title}
    ${dialog}=    Wait For Heads Dialog    ${title}
    IF    '↓' in $dialog
        FOR    ${i}    IN RANGE    10
            # Page Down while the text box has the focus
            Write Bare Into Terminal    \x1b[6~
            Sleep    1s
            ${more}=    Read From Terminal
            VAR    ${dialog}=    ${dialog}    ${more}    separator=\n
        END
    END
    Focus Heads Dialog Buttons    ${dialog}
    Write Bare Into Terminal    ${ENTER}
    RETURN    ${dialog}

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
    VAR    @{tpm_pcrs}=    @{EMPTY}
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

Heads VM Should Be Powered Off
    [Documentation]    Checks that the VM stopped (the guest powered off).
    ...    Only for QEMU, which keeps running with -no-shutdown.
    ${status}=    Get Qemu Status
    Should Not Be Equal    ${status}    running    DUT did not power off

Prepare Heads GPG Test Data
    [Documentation]    Generates two GPG test keys on the host and USB disk
    ...    images with their public keys, once per suite. Sets the suite
    ...    variables ${HEADS_KEY1}, ${HEADS_KEY1_FINGERPRINT},
    ...    ${HEADS_USB_KEY1} and the same for key 2.
    ${done}=    Get Variable Value    ${HEADS_KEY1_FINGERPRINT}    ${EMPTY}
    IF    '${done}' != '${EMPTY}'    RETURN
    ${key}    ${fingerprint}    ${usb}=    Prepare Heads GPG Test Key    1
    VAR    ${HEADS_KEY1}=    ${key}    scope=SUITE
    VAR    ${HEADS_KEY1_FINGERPRINT}=    ${fingerprint}    scope=SUITE
    VAR    ${HEADS_USB_KEY1}=    ${usb}    scope=SUITE
    ${key}    ${fingerprint}    ${usb}=    Prepare Heads GPG Test Key    2
    VAR    ${HEADS_KEY2}=    ${key}    scope=SUITE
    VAR    ${HEADS_KEY2_FINGERPRINT}=    ${fingerprint}    scope=SUITE
    VAR    ${HEADS_USB_KEY2}=    ${usb}    scope=SUITE

Prepare Heads GPG Test Key
    [Documentation]    Generates GPG test key ${n} on the host and a USB disk
    ...    image with its public key. Returns the public key file, the key
    ...    fingerprint and the USB disk image.
    [Arguments]    ${n}
    ${key}    ${fingerprint}=    Generate GPG Test Key    ${HEADS_QEMU_WORKDIR}/key${n}
    ...    uid=OSFV Heads Test ${n} <osfv-heads-${n}@example.com>
    VAR    ${usb}=    ${HEADS_QEMU_WORKDIR}/usb-key${n}.img
    Create Heads USB Image    ${usb}    ${key}
    RETURN    ${key}    ${fingerprint}    ${usb}

Answer Heads Prompts Until
    [Documentation]    Answers Heads' prompts and dialogs with the defaults of
    ...    OEM Factory Reset (TPM Owner Passphrase and dongle Admin PIN
    ...    ${HEADS_TPM_PASS}/${HEADS_ADMIN_PIN}, User PIN ${HEADS_USER_PIN},
    ...    default answers) until ${stop} (a regexp) is read. Fails on a dialog
    ...    it does not know, showing its content. Returns everything read.
    ...    The TOTP secret printed by Heads is stored in ${HEADS_TOTP_SECRET}.
    [Arguments]    ${stop}    ${timeout}=${HEADS_DIALOG_TIMEOUT}
    Set DUT Response Timeout    ${timeout}
    VAR    ${all}=    ${EMPTY}
    # Title of the dialog answered last: choosing an entry redraws the dialog
    # before it closes, which must not be answered again
    VAR    ${answered}=    ${EMPTY}
    VAR    @{prompts}=
    ...    TPM Owner Passphrase[^:\\n]{0,120}:
    ...    Enter [^:\\n]{0,120}PIN[^:\\n]{0,120}:
    ...    Wrong PIN[^:\\n]{0,120}:
    ...    \\[[yY]/[nN]\\]:
    ...    [Pp]ress Enter to (?:continue|configure)[^:\\n]{0,40}
    ...    Insert your [^\\n]{0,40} and press Enter[^\\n]{0,20}
    ...    ┘
    VAR    ${any}=    (?:${stop})    @{prompts}    separator=|
    FOR    ${i}    IN RANGE    100
        ${out}=    Read From Terminal Until Regexp    ${any}
        VAR    ${all}=    ${all}    ${out}    separator=${EMPTY}
        Store Heads TOTP Secret    ${out}
        ${stopped}=    Run Keyword And Return Status    Should Match Regexp    ${out}    ${stop}
        IF    ${stopped}    RETURN    ${all}
        Heads Output Should Not Have Error    ${out}    ${stop}
        # A prompt-like line inside a dialog (e.g. "│ TPM Owner Passphrase:"
        # in the summary of the secrets) is not a prompt: read the dialog
        ${last}=    Evaluate    $out.rsplit('\\n', 1)[-1].lstrip()
        IF    $last.startswith('│')
            ${rest}=    Read From Terminal Until    ┘
            VAR    ${out}=    ${out}    ${rest}    separator=${EMPTY}
            VAR    ${all}=    ${all}    ${rest}    separator=${EMPTY}
        END
        ${tail}=    Get Substring    ${out}    -400
        IF    $out.rstrip().endswith('┘')
            ${titles}=    Get Regexp Matches    ${out}    ┤\\s*([^├]*?)\\s*├    1
            IF    ${titles}
                VAR    ${title}=    ${titles}[-1]
            ELSE
                VAR    ${title}=    ${EMPTY}
            END
            IF    'Heads Boot Menu' in $title
                # The flow ended early, e.g. after an error message
                ${before}=    Get Substring    ${all}    -6000
                Fail    Back in the Heads main menu before "${stop}". Output before:\n${before}
            END
            IF    '${title}' != '${answered}'
                Answer Heads Dialog    ${out}
                VAR    ${answered}=    ${title}
            END
            CONTINUE
        ELSE IF    'TPM Owner Passphrase' in $tail
            Sleep    0.5s
            Write Into Terminal    ${HEADS_TPM_PASS}
        ELSE IF    'User PIN' in $tail
            Sleep    0.5s
            Write Into Terminal    ${HEADS_USER_PIN}
        ELSE IF    'PIN' in $tail and $tail.rstrip().endswith(':')
            Sleep    0.5s
            Write Into Terminal    ${HEADS_ADMIN_PIN}
        ELSE IF    'scanned the QR code above' in $tail and '[y/N]' in $tail
            Sleep    0.5s
            Write Bare Into Terminal    y
        ELSE IF    '[Y/n]' in $tail or '[y/N]' in $tail
            Sleep    0.5s
            Write Bare Into Terminal    ${ENTER}
        ELSE IF    'ress Enter' in $tail
            Sleep    0.5s
            Write Bare Into Terminal    ${ENTER}
        ELSE
            CONTINUE
        END
        VAR    ${answered}=    ${EMPTY}
    END
    Fail    "${stop}" not reached

Store Heads TOTP Secret
    [Documentation]    Stores the TOTP secret, if Heads printed one in
    ...    ${output}, in ${HEADS_TOTP_SECRET}.
    [Arguments]    ${output}
    ${secret}=    Get Regexp Matches    ${output}    TOTP secret for manual input[^:]*: ([A-Z2-7]+)    1
    IF    ${secret}
        VAR    ${HEADS_TOTP_SECRET}=    ${secret}[-1]    scope=SUITE
    END

Heads Output Should Not Have Error
    [Documentation]    Fails with Heads' message when ${output} has one of
    ...    its fatal errors ("!!! ERROR: ... !!!", from DIE): the flow
    ...    waiting for ${stop} failed, don't continue past it.
    [Arguments]    ${output}    ${stop}
    ${errors}=    Get Regexp Matches    ${output}    !!! ERROR: ([^\\n]*?) !!!    1
    IF    ${errors}    Fail    Heads failed before "${stop}": ${errors}[-1]

Answer Heads Dialog
    [Documentation]    Answers a dialog met by Answer Heads Prompts Until.
    [Arguments]    ${dialog}
    IF    'Measured Integrity Report' in $dialog or ('Choose an action' in $dialog and 'Continue' in $dialog)
        # Measured Integrity Report: continue ('c' in all its variants, even
        # when the entries are scrolled out of view)
        Choose Heads Option    c
    ELSE IF    'No /boot Partition Found' in $dialog
        Choose Heads Option    m
    ELSE IF    '<Ok>' in $dialog and '<Cancel>' not in $dialog and '<Yes>' not in $dialog
        # Message box, e.g. "touch the dongle when requested"
        ${box}=    Get Regexp Matches    ${dialog}    ┌[^┌]*$
        IF    ${box}
            VAR    ${box}=    ${box}[-1]
        ELSE
            VAR    ${box}=    ${dialog}
        END
        Log    Dismissing Heads message:\n${box}    WARN
        Sleep    0.5s
        Focus Heads Dialog Buttons    ${dialog}
        Write Bare Into Terminal    ${ENTER}
    ELSE IF    '<Yes>' in $dialog or '<Continue>' in $dialog
        Sleep    0.5s
        Focus Heads Dialog Buttons    ${dialog}
        Write Bare Into Terminal    ${ENTER}
    ELSE
        Fail    Unexpected Heads dialog:\n${dialog}
    END

Heads TOTP Should Match
    [Documentation]    Checks the TOTP shown in Heads' main menu ${menu}
    ...    against the one computed from ${HEADS_TOTP_SECRET}.
    [Arguments]    ${menu}
    ${totp_dut}=    Get Regexp Matches    ${menu}    TOTP: (\\d{6})    1
    Should Not Be Empty    ${totp_dut}    No TOTP in the main menu
    Should Not Be Empty    ${HEADS_TOTP_SECRET}    TOTP secret was not captured
    ${totp_real}=    Get Totps Around Now From Uri    otpauth://totp/heads?secret=${HEADS_TOTP_SECRET}
    Should Contain    ${totp_real}    ${totp_dut}[0]

Finish Heads Flow In Main Menu
    [Documentation]    Completes a flow run with Answer Heads Prompts Until
    ...    "Heads Boot Menu|continue reboot or": goes through the reboot
    ...    (a power off on QEMU) if Heads asked for one, and returns the
    ...    main menu.
    [Arguments]    ${output}
    IF    'continue reboot or' in $output
        Sleep    0.5s
        Write Bare Into Terminal    ${ENTER}
        Wait For Heads Power Off
        ${menu}=    Power On Into Heads Main Menu
    ELSE
        ${menu}=    Read From Terminal Until    ┘
    END
    RETURN    ${menu}

Generate Heads TOTP And HOTP
    [Documentation]    From the main menu (already read), generates new
    ...    TOTP/HOTP secrets and returns the main menu shown afterwards.
    Open Heads Options Menu
    Choose Heads Option    t
    Choose From Heads Menu    TPM/TOTP/HOTP Options    g    Generate new TOTP/HOTP secret
    ${output}=    Answer Heads Prompts Until    Heads Boot Menu|continue reboot or
    ${menu}=    Finish Heads Flow In Main Menu    ${output}
    RETURN    ${menu}

Heads HOTP Should Not Fail
    [Documentation]    Checks that the main menu ${menu} does not report an
    ...    HOTP failure (boards without HOTP show none).
    [Arguments]    ${menu}
    Should Not Match Regexp    ${menu}    HOTP: *(Error|Invalid|Failed)
