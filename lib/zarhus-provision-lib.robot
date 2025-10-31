*** Settings ***
Resource    zarhus-lib.robot


*** Variables ***
${ENCRYPTED_STORAGE_PASSWORD}=      1234567
${ENCRYPTED_STORAGE_PROMPT}=        Enter password for encrypted storage:


*** Keywords ***
Flash Bootstrap USB
    [Documentation]    Flash Bootstrap USB (``${bootstrap_file}``) to first
    ...    available USB stick or if there already is bootstrap USB then it
    ...    overwrites it
    [Arguments]    ${bootstrap_file}
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS

    ${rc}=    Execute Command In Terminal And Return RC    test -b /dev/disk/by-label/zarhus-dtrpb
    IF    ${rc} == 0
        ${part_device}=    Execute Command In Terminal
        ...    basename "\$(realpath /dev/disk/by-label/zarhus-dtrpb)"
        ${device}=    Execute Command In Terminal
        ...    basename "\$(realpath "/sys/class/block/${part_device}/..")"
    ELSE
        ${device}=    Get First USB Stick In Linux
    END

    # Send bootstrap image directly to USB stick
    Execute Command In Terminal    systemctl start sshd
    Send File To DUT Directly    ${bootstrap_file}    /dev/${device}

    # Add boot menu to make sure it's default boot option
    Execute Command In Terminal Should Succeed
    ...    mount -o remount,rw efivarfs
    ...    Failed to remount efivarfs as read-writable
    Execute Command In Terminal Should Succeed
    ...    efibootmgr --disk "/dev/${device}" --part 1 --create --label "Zarhus Bootstrap" --loader '\\EFI\\BOOT\\bootx64.efi'
    ...    Failed to create new Boot Entry for bootstrap USB stick

Install ZPB OS
    [Documentation]    Install Zarhus Provisioning Box OS via ZPB bootstrap USB
    ...
    ...    === Requirements ===
    ...    - ``${ZARHUS_BOOTSTRAP_FILE}`` defined with path to Zarhus OS
    ...    \ Bootstrap image. Flashed directly on USB.
    ...
    ...    === Arguments ===
    ...    - ``${disk}``: ``string`` - device on which to install Zarhus OS
    ...
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Flashes ``${ZARHUS_BOOTSTRAP_FILE}`` to USB stick on hardware
    ...    - Runs `install.sh` script from bootstrap image which installs ZPB
    ...    \ OS on ``${disk}`` and flashes pre-configured firmware image
    [Arguments]    ${disk}=nvme0n1
    OperatingSystem.File Should Exist    ${ZARHUS_BOOTSTRAP_FILE}

    VAR    ${os_username_old}=    ${DEVICE_OS_USERNAME}
    VAR    ${os_password_old}=    ${DEVICE_OS_PASSWORD}
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=Test
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=Test
    IF    '${MANUFACTURER}' == 'QEMU'
        Boot Dasharo Tools Suite    iPXE
    ELSE
        Make Sure That Flash Locks Are Disabled
        Set UEFI Option    MeMode    Disabled (HAP)
        Flash Bootstrap USB    ${ZARHUS_BOOTSTRAP_FILE}
        # Boot into bootstrap USB stick
        Execute Reboot Command
        Set DUT Response Timeout    2m
        Wait For Checkpoint    ${DTS_CHECKPOINT}
    END
    Enter Shell In DTS

    # Mount partition containing install script
    Execute Command In Terminal Should Succeed
    ...    mount /dev/disk/by-label/zarhus-dtrpb /mnt

    IF    '${MANUFACTURER}' == 'QEMU'
        Execute Command In Terminal Should Succeed
        ...    gunzip -c /mnt/zarhus-base-image-genericx86-64.rootfs.wic.gz >/dev/${disk}
        ...    timeout=5m
    ELSE
        # Run install.sh script
        Write Into Terminal    ./mnt/install.sh
        # To remove output from lsblk listing available disks
        Read From Terminal Until    Select target disk
        # Read available selections
        ${selection}=    Read From Terminal Until    Enter selection
        ${selection_lines}=    Split To Lines    ${selection}
        VAR    ${selected_line}=    ${EMPTY}
        FOR    ${line}    IN    @{selection_lines}
            IF    """${disk}""" in """${line}"""
                VAR    ${selected_line}=    ${line}
                BREAK
            END
        END
        IF    """${disk}""" not in """${selected_line}"""
            Fail    Couldn't find ${disk} in output of install.sh script
        END
        # return `<x>` from `<x>) ${device}`
        ${index}=    Replace String Using Regexp
        ...    ${selected_line}    \(\\d+\).*    \\1
        Write Into Terminal    ${index}
        Wait For Checkpoint And Write    Type 'YES' to continue:    YES
        Read From Terminal Until    You can now reboot the platform
        Read From Terminal Until Prompt
        ${rc}=    Execute Command In Terminal    echo $?
        Should Be Equal As Integers    ${rc}    0
    END
    Execute Command In Terminal    sync

    VAR    ${DEVICE_OS_USERNAME}=    ${os_username_old}    scope=Suite
    VAR    ${DEVICE_OS_PASSWORD}=    ${os_password_old}    scope=Suite

    # Make sure we can enter setup menu after flashing
    Execute Reboot Command
    Set DUT Response Timeout    3m
    Enter Setup Menu Tianocore

Prepare ZPB OS
    [Documentation]    Install ZPB OS via ZPB bootstrap USB and do first boot
    ...    setup.
    ...
    ...    === Requirements ===
    ...    - ``${ZARHUS_BOOTSTRAP_FILE}`` defined with path to Zarhus OS
    ...    \ Bootstrap image.
    ...
    ...    === Arguments ===
    ...    - ``${disk}``: ``string`` - device on which to install Zarhus OS
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Flashes ``${ZARHUS_BOOTSTRAP_FILE}`` to first detected USB stick
    ...    - If running on QEMU adds 3 USB emulated sticks, with one being
    ...    \ bootstrap file and 2 other are temporary files
    ...    - Clears devices under /dev/disk/by-label/luks_dtrpb-storage and
    ...    \ /dev/disk/by-label/luks_backup-storage if those exist
    ...    - Runs `install.sh` script from bootstrap image which installs ZPB
    ...    \ OS on ``${disk}`` and flashes pre-configured firmware image
    ...    - Runs first boot setup of Zarhus OS
    [Arguments]    ${disk}=nvme0n1
    IF    '${MANUFACTURER}' == 'QEMU'
        VAR    ${disk}=    sda
        VAR    ${STORAGE_1}=    ${EMPTY}    scope=Suite
        VAR    ${STORAGE_2}=    ${EMPTY}    scope=Suite
        ${storage_1}=    Run    mktemp -p ${TEMPDIR} encrypted_storage.XXXXXXXX
        ${storage_2}=    Run    mktemp -p ${TEMPDIR} encrypted_storage.XXXXXXXX
        Run    dd if=/dev/zero of="${storage_1}" bs=1 count=0 seek=300M
        Run    dd if=/dev/zero of="${storage_2}" bs=1 count=0 seek=300M
        Add USB To Qemu
        ...    ${ZARHUS_BOOTSTRAP_FILE}    bootstrap    read_only=${FALSE}    removable=${TRUE}
        Add USB To Qemu
        ...    ${storage_1}    storage_1    read_only=${FALSE}    removable=${TRUE}
        Add USB To Qemu
        ...    ${storage_2}    storage_2    read_only=${FALSE}    removable=${TRUE}

        # On hardware this'll be done by configuring firmware binary before
        # flashing it
        Power On Ex    force_reboot=${TRUE}
        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
        Erase All Secure Boot Keys    ${advanced_menu}
        Save Changes And Reset
        Set UEFI Option    OptionROMExecutionPolicy    Disable all OptionROMs
    END
    Set Zarhus Features
    Install ZPB OS    ${disk}
    # Dasharo issue - can't modify Dasharo Security BIOS config after this
    # moment. Boot from USB as we can't enable Network Boot.
    Power On Ex    force_reboot=${TRUE}
    Boot Dasharo Tools Suite    USB
    Enter Shell In DTS
    # Make sure Zarhus is first boot entry
    Execute Command In Terminal Should Succeed
    ...    mount -o remount,rw efivarfs
    ...    Failed to remount efivarfs as read-writable
    Execute Command In Terminal Should Succeed
    ...    efibootmgr --disk "/dev/${disk}" --part 1 --create --label "ZarhusOS" --loader '\\EFI\\BOOT\\bootx64.efi'
    VAR    ${storage_main}=    /dev/disk/by-label/luks_dtrpb-storage
    VAR    ${storage_backup}=    /dev/disk/by-label/luks_backup-storage
    Execute Command In Terminal
    ...    test -b ${storage_main} && dd if=/dev/zero of=${storage_main} bs=1M count=100
    Execute Command In Terminal
    ...    test -b ${storage_backup} && dd if=/dev/zero of=${storage_backup} bs=1M count=100
    Execute Reboot Command
    Zarhus First Boot Setup

Setup ZPB
    [Documentation]    Setup Provisioning Box. After this step ZPB should be
    ...    ready to be used for provisioning binaries.
    ...    Load ZPB OS dependencies, provision Intel Boot Guard, Provision
    ...    Secure Boot. Doesn't enroll TPM.
    ...
    ...    === Requirements ===
    ...    - IF running on hardware, at least 2 USB sticks, with one being ZPB
    ...    \ bootstrap
    ...    - 'Prepare ZPB OS' called beforehand
    ...    - Should be called only once per `Prepare ZPB OS`
    ...
    ...    === Arguments ===
    ...
    ...    === Effects ===
    ...    - Creates encrypted storage on first available USB
    ...    - Provisions Secure Boot
    ...    - On hardware:
    ...    - Provisions Intel Boot Guard (**Without** fusing)
    ...    - Ends up in BIOS Setup Menu
    Boot Zarhus OS
    Create Encrypted Storage
    IF    '${MANUFACTURER}' != 'QEMU'
        # Provision Intel BtG
        Write Into Terminal    zarhus prepare --no-eom
        Set DUT Response Timeout    5m
        Wait For Checkpoint And Write    ${ENCRYPTED_STORAGE_PROMPT}    ${ENCRYPTED_STORAGE_PASSWORD}
        Wait For Checkpoint And Write
        ...    Choose your Intel BootGuard keys name (without spaces)    ZPB_IBG
        Wait For Checkpoint And Press Enter    Press Enter to reboot
        # Wait for update to finish
        Login To Zarhus OS
    END
    Set UEFI Option    MeMode    Enabled
    Boot Zarhus OS

    ${status}=    Execute Command In Terminal    zarhus status
    IF    '${MANUFACTURER}' != 'QEMU'
        Should Contain    ${status}    Boot Guard: Enabled
    END
    Should Contain    ${status}    Secure Boot: Disabled
    IF    '${MANUFACTURER}' != 'QEMU'
        Should Contain    ${status}    Fusing state: Unlocked
        ...    !! Make sure you didn't fuse your platform !!
    END

    # Provision Secure Boot
    Write Into Terminal    zarhus provision-secure-boot
    Wait For Checkpoint And Write    ${ENCRYPTED_STORAGE_PROMPT}    ${ENCRYPTED_STORAGE_PASSWORD}
    Wait For Checkpoint And Write    Choose your Secure Boot keys name:    ZPB_SB
    Wait For Checkpoint    Secure boot was provisioned! Make sure to reboot
    Read From Terminal Until Prompt
    Execute Command In Terminal    sync
    IF    '${MANUFACTURER}' == 'QEMU'
        Power On Ex    force_reboot=${TRUE}
        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        Enable Secure Boot    ${sb_menu}
        Save Changes And Reset
    ELSE
        Execute Reboot In ZPB OS
    END
    Login To Zarhus OS
    ${status}=    Execute Command In Terminal    zarhus status
    Should Contain    ${status}    Secure Boot: Enabled

Create Encrypted Storage
    [Documentation]    Create encrypted storage via `zarhus storage create`
    ...
    ...    === Requirements ===
    ...    - Logged into ZPB OS
    ...    - At least 1, non-encrypted USB stick
    ...
    ...    === Arguments ===
    ...    ``${allow_bootstrap}``: ``bool`` = ``${FALSE} - allow to choose
    ...    \ bootstrap USB to use as encrypted storage
    ...
    ...    === Effects ===
    ...    - Creates encrypted storage on first available USB that is not
    ...    \ bootstrap one (unless ``${allow_bootstrap}`` is true)
    [Arguments]    ${allow_bootstrap}=${FALSE}
    Write Into Terminal    zarhus storage create
    ${choices}=    Read From Terminal Until    Your choice:

    ${choices}=    Get Lines Containing String    ${choices}    /dev/
    @{choices_list}=    Split To Lines    ${choices}
    Should Not Be Empty    ${choices_list}
    VAR    ${choice}=    ${EMPTY}
    IF    ${allow_bootstrap}
        VAR    ${choice}=    0
    ELSE
        FOR    ${possible_choice}    IN    @{choices_list}
            IF    not "zarhus-dtrpb" in """${possible_choice}"""
                # return `<x>` in `<x>: ...`
                ${choice}=    Replace String Using Regexp
                ...    ${possible_choice}    ^\(\\d+\):.*    \\1
                BREAK
            END
        END
        Should Not Be Empty    ${choice}
    END
    Write Into Terminal    ${choice}
    Wait For Checkpoint And Write    is it correct? [y|N]    y
    Wait For Checkpoint And Write    ${ENCRYPTED_STORAGE_PROMPT}    ${ENCRYPTED_STORAGE_PASSWORD}
    Wait For Checkpoint And Write
    ...    Verify password:    ${ENCRYPTED_STORAGE_PASSWORD}
    Read From Terminal Until    Success!
    Read From Terminal Until Prompt

Teardown ZPB Test Suite
    [Documentation]    Remove USB files if running on QEMU
    IF    '${MANUFACTURER}' == 'QEMU'
        Remove USB From Qemu    bootstrap
        Remove USB From Qemu    storage_1
        Remove USB From Qemu    storage_2
        ${status}=    Run Keyword And Return Status
        ...    Variable Should Exist    STORAGE_1
        IF    ${status}    Run    test -f "${STORAGE_1}" && rm ${STORAGE_1}
        ${status}=    Run Keyword And Return Status
        ...    Variable Should Exist    STORAGE_2
        IF    ${status}    Run    test -f "${STORAGE_2}" && rm ${STORAGE_2}
    END

Execute Reboot In ZPB OS
    [Documentation]    Call `sudo reboot`.
    Write Into Terminal    sudo reboot
