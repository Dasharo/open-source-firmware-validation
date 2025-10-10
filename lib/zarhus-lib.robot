*** Settings ***
Resource    terminal.robot
Resource    bios/menus.robot
Resource    ../keywords.robot
Resource    dts-zarhus.robot


*** Variables ***
${DEVICE_OS_USERNAME}=          user
${DEVICE_OS_PASSWORD}=          12345
${ENCRYPTION_PASSWORD}=         123456
${DEVICE_OS_HOSTNAME}=          genericx86-64
${DEVICE_OS_USER_PROMPT}=       ${DEVICE_OS_HOSTNAME}:~$


*** Keywords ***
Login To Zarhus OS
    [Documentation]    Logs into Zarhus OS, enter decryption password if needed
    ...
    ...    === Requirements ===
    ...    - Zarhus OS should be queued to boot without intervention
    ...    - `Set Zarhus Features` keyword called beforehand e.g. in suite
    ...    \ preparation
    ...    - First boot setup done (set encryption password, user password changed)
    ...
    ...    === Effects ===
    ...    - Logs into Zarhus OS
    Set Prompt For Terminal    ${DEVICE_OS_USER_PROMPT}
    IF    "encryption" in ${ZARHUS_FEATURES}
        Wait For Checkpoint And Write
        ...    Enter disk encryption password:    ${ENCRYPTION_PASSWORD}
    END
    Wait For Checkpoint And Write    ${DEVICE_OS_HOSTNAME} login:    ${DEVICE_OS_USERNAME}
    Wait For Checkpoint And Write    Password:    ${DEVICE_OS_PASSWORD}
    # Workaround, as Read From Terminal Until Prompt fails to find prompt
    Press Enter
    Read From Terminal Until Prompt

Boot Zarhus OS
    [Documentation]    Boots and logs into Zarhus OS. Assume Zarhus OS is
    ...    default boot option.
    ...
    ...    === Requirements ===
    ...    - Zarhus OS should be default boot option
    ...    - `Set Zarhus Features` keyword called beforehand e.g. in suite
    ...    \ preparation
    ...    - First boot setup done (set encryption password, user password changed)
    ...
    ...    === Effects ===
    ...    - Power platform on
    ...    - Boots and logs into Zarhus OS
    Power On
    Login To Zarhus OS

Flash Zarhus OS
    [Documentation]    Boot into DTS and flash Zarhus OS on /dev/``${device}``.
    ...
    ...    === Requirements ===
    ...
    ...    === Arguments ===
    ...    - ``${zarhus_os_file}``: ``string`` - Path to Zarhus `.wic.gz` file
    ...    \ on Host OS
    ...    - ``${device}``: ``string`` - device on which to flash Zarhus OS
    ...    - Enough RAM in DUT to copy ``${zarhus_os_file}`` to /tmp/
    ...
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Enables Network Boot
    ...    - Boots and stays in DTS shell after flashing
    [Arguments]    ${zarhus_os_file}    ${device}
    Boot Dasharo Tools Suite    iPXE
    VAR    ${os_username_old}=    ${DEVICE_OS_USERNAME}
    VAR    ${os_password_old}=    ${DEVICE_OS_PASSWORD}
    VAR    ${DEVICE_OS_USERNAME}=    root    scope=Test
    VAR    ${DEVICE_OS_PASSWORD}=    ${EMPTY}    scope=Test
    Enter Shell In DTS
    Execute Command In Terminal    systemctl start sshd
    Send File To DUT    ${zarhus_os_file}    /tmp/zarhus.wic.gz
    Execute Command In Terminal Should Succeed
    ...    test -b /dev/${device}    err_msg=/dev/${device} block device doesn't exist!
    Execute Command In Terminal Should Succeed
    ...    set -o pipefail; gunzip -c /tmp/zarhus.wic.gz | dd of=/dev/${device}
    ...    err_msg=Flashing Zarhus OS failed!
    ...    timeout=5m
    # Using `scope=Suite` because `scope=Test` resulted in those variables
    # having root/${EMPTY} values in tests (after suite setup finished)
    VAR    ${DEVICE_OS_USERNAME}=    ${os_username_old}    scope=Suite
    VAR    ${DEVICE_OS_PASSWORD}=    ${os_password_old}    scope=Suite

Install Zarhus OS
    [Documentation]    Prepare Zarhus OS for testing. Flash it to
    ...    ``${TARGET_DEVICE}``, or /dev/sda if testing on QEMU and add it
    ...    as a default boot option
    ...
    ...    === Requirements ===
    ...    - ``${ZARHUS_WIC_GZ_FILE}`` defined with path to Zarhus OS `.wic.gz` image
    ...    - ``${TARGET_DEVICE}`` defined if testing on hardware.
    ...
    ...    === Arguments ===
    ...
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Flashes ``${ZARHUS_WIC_GZ_FILE}`` to /dev/sda if running on QEMU or to
    ...    \ /dev/${TARGET_DEVICE}
    ...    - Enables Network Boot
    ...    - Adds new, default, Boot Entry to `\EFI\BOOT\bootx64.efi` on first
    ...    \ partition
    Variable Should Exist    ${ZARHUS_WIC_GZ_FILE}
    OperatingSystem.File Should Exist    ${ZARHUS_WIC_GZ_FILE}
    IF    '${MANUFACTURER}' == 'QEMU'
        VAR    ${device}=    sda
    ELSE
        Variable Should Exist    ${TARGET_DEVICE}
        VAR    ${device}=    ${TARGET_DEVICE}
    END
    Flash Zarhus OS    ${ZARHUS_WIC_GZ_FILE}    ${device}
    # ZarhusOS will be first in BootOrder
    Execute Command In Terminal Should Succeed
    ...    mount -o remount,rw efivarfs
    ...    Failed to remount efivarfs as read-writable
    Execute Command In Terminal Should Succeed
    ...    efibootmgr --disk "/dev/${device}" --part 1 --create --label "ZarhusOS" --loader '\\EFI\\BOOT\\bootx64.efi'
    ...    Failed to create new Boot Entry

Zarhus First Boot Setup
    [Documentation]    First boot setup (set up encryption password, change
    ...    user password)
    ...
    ...    === Requirements ===
    ...    - Should be called before Zarhus starts booting
    ...
    ...    === Arguments ===
    ...
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Sets encryption password if using encryption feature
    ...    - Sets user password
    ...    - Reboots and enters Dasharo setup menu after finishing
    IF    "encryption" in ${ZARHUS_FEATURES}
        Wait For Checkpoint And Write
        ...    Enter disk encryption password:    ${ENCRYPTION_PASSWORD}
        Wait For Checkpoint And Write
        ...    Verify password:    ${ENCRYPTION_PASSWORD}
        # encryption, especially on QEMU might take a while
        Set DUT Response Timeout    5m
    END
    Wait For Checkpoint And Write    ${DEVICE_OS_HOSTNAME} login:    ${DEVICE_OS_USERNAME}
    Wait For Checkpoint And Write    New password:    ${DEVICE_OS_PASSWORD}
    Wait For Checkpoint And Write    Re-enter new password:    ${DEVICE_OS_PASSWORD}
    Read From Terminal Until    passwd: password changed.
    Set Prompt For Terminal    ${DEVICE_OS_USER_PROMPT}
    Press Enter
    Read From Terminal Until Prompt
    Execute Command In Terminal    sync
    Power On
    Enter Setup Menu Tianocore

Prepare Zarhus OS
    [Documentation]    Prepare Zarhus OS for testing, install it and boot once
    ...    to setup everything e.g. encryption password and user password
    ...    depending on Zarhus features.
    ...
    ...    === Requirements ===
    ...
    ...    === Arguments ===
    ...
    ...    === Return Value ===
    ...
    ...    === Effects ===
    ...    - Sets Suite variable ``${ZARHUS_FEATURES}`` via with
    ...    \ `Set Zarhus Features` keyword
    ...    - Enables Network Boot
    ...    - Flashes ``${ZARHUS_WIC_GZ_FILE}`` on disk
    ...    - Boots and configures Zarhus OS
    Set Zarhus Features
    Install Zarhus OS
    Execute Reboot Command
    Zarhus First Boot Setup

Set Zarhus Features
    [Documentation]    Set features from ``${FEATURES}`` variable to
    ...    ``${ZARHUS_FEATURES}`` list with Suite scope. Features should
    ...    be split with comma.
    ${variable_exists}=    Run Keyword And Return Status
    ...    Variable Should Exist    \${FEATURES}
    IF    ${variable_exists}
        @{features}=    Split String    ${FEATURES}    separator=,
    ELSE
        VAR    @{features}=    @{EMPTY}
    END
    VAR    @{ZARHUS_FEATURES}=    @{features}    scope=Suite

Execute Command In Terminal With Sudo
    [Documentation]    Execute `sudo ${command}` and enter sudo password.
    ...    Before doing that, forget all sudo passwords. If
    ...    ``${wait_for_prompt}`` and ``${verify}`` is ``${TRUE}`` then verify
    ...    that command succeeded
    [Arguments]    ${command}    ${wait_for_prompt}=${TRUE}    ${verify}=${TRUE}
    Write Into Terminal    sudo -k ${command}
    Wait For Checkpoint And Write    Password:    ${DEVICE_OS_PASSWORD}
    IF    ${wait_for_prompt}
        ${out}=    Read From Terminal Until Prompt
        IF    ${verify}
            ${rc}=    Execute Command In Terminal    echo $?
            Should Be Equal As Integers    ${rc}    0
        END
        RETURN    ${out}
    END
