*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../lib/tpm.robot
Resource            ../lib/tpm2.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    ${TPM_SUPPORTED_VERSION} == None    TPM tests not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
TPM001.101 TPM Support (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM is initialized,
    ...    detected and logged correctly by FW via cbmem, directly in Ubuntu
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM001.101 not supported
    Prepare TPM Test On Linux
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM002.101 Verify TPM version (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the firmware.
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM002.101 not supported
    Prepare TPM Test On Linux
    ${result}=    Run Keyword And Ignore Error    Validate Expected TPM Chip Via Cbmem Console Log
    IF    '${result}[0]' == 'FAIL'
        Log To Console    \nChip detection failed, attempting cbmem log detection\n
        Validate Expected TPM Version Via Cbmem TPM Eventlog
    END

TPM003.101 Check TPM Physical Presence Interface (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is supported by the firmware and the log can be detected
    ...    with cbmem within Ubuntu
    Skip If    '${DEFAULT_BOOT_OS_ID}' not in ${TESTED_LINUX_DISTROS}    TPM003.101 not supported
    Prepare TPM Test On Linux
    ${out}=    Execute Command In Terminal    cbmem -1 | grep PPI
    Should Contain    ${out}    PPI: Pending OS request
    Should Contain    ${out}    PPI: OS response

TPM004.101 Check TPM Clear procedure (EDK2 UEFI)
    [Documentation]    Verifies the TPM Clear procedure. Takes ownership of the TPM,
    ...    confirms ownership is set, clears the TPM via firmware, then confirms
    ...    ownership was reset. Runs a TPM Clear at the start to ensure a known state.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}

    VAR    ${take_ownership}=
    ...    Open a terminal and run the following to take ownership of the TPM:
    ...    tpm2_changeauth --quiet -c owner pass
    ...    tpm2_changeauth --quiet -c lockout pass
    ...    tpm2_createprimary -Q --hierarchy=o --key-context=/tmp/test --key-auth=pass2 -P pass
    ...    tpm2_evictcontrol -Q -C o -P pass -c /tmp/test 0x81000001
    ...    rm /tmp/test
    ...    separator=\n

    VAR    ${check_ownership}=
    ...    Run the following to test whether ownership is currently set:
    ...    tpm2_changeauth --quiet -c owner 2>/dev/null
    ...    echo $?
    ...    Result 1 = ownership IS set
    ...    Result 0 = ownership is NOT set
    ...    separator=\n

    VAR    ${clear_tpm}=
    ...    Reboot and clear the TPM via firmware:
    ...    1. Enter the BIOS -> Device Manager -> TCG2 Configuration.
    ...    2. Select "TPM2 Operation", press Enter, choose "TPM2 ClearControl(NO) + Clear".
    ...    3. Save and reboot. When prompted, press F12 to clear the TPM.
    ...    separator=\n

    Execute Manual Step    [1/8] Power on the DUT and boot into the BIOS.
    Execute Manual Step    [2/8] ${clear_tpm}
    Execute Manual Step    [3/8] Boot into the system and log in.
    Execute Manual Step    [4/8] ${take_ownership}
    Execute Manual Step
    ...    [5/8] ${check_ownership}\nExpected: output is 1, the command fails.

    Execute Manual Step    [6/8] ${clear_tpm}
    Execute Manual Step    [7/8] Boot into the system and log in.
    Execute Manual Step
    ...    [8/8] ${check_ownership}\nExpected: output is 0, the command succeeds

TPM005.101 Check TPM Hash Algorithm Support SHA1 (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM supports needed hash algorithm (SHA1).
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the BIOS.
    Execute Manual Step    [3/5] Enter Device Manager.
    Execute Manual Step    [4/5] Enter TCG2 Configuration
    Execute Manual Step    [5/5] Scroll down to "TPM2 Hardware Supported Hash Algorithm"
    Execute Manual Step    [Expected result] The entry should contain SHA1.

TPM006.101 Check TPM Hash Algorithm Support SHA256 (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM supports needed hash algorithm (SHA256).
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the BIOS.
    Execute Manual Step    [3/5] Enter Device Manager.
    Execute Manual Step    [4/5] Enter TCG2 Configuration
    Execute Manual Step    [5/5] Scroll down to "TPM2 Hardware Supported Hash Algorithm"
    Execute Manual Step    [Expected result] The entry should contain SHA256.

TPM007.101 Check TPM Hash Algorithm Support SHA384 (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM supports needed hash algorithm (SHA384).
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the BIOS.
    Execute Manual Step    [3/5] Enter Device Manager.
    Execute Manual Step    [4/5] Enter TCG2 Configuration
    Execute Manual Step    [5/5] Scroll down to "TPM2 Hardware Supported Hash Algorithm"
    Execute Manual Step    [Expected result] The entry should contain SHA384.

TPM008.101 Check TPM Hash Algorithm Support SHA512 (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM supports needed hash algorithm (SHA512).
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Execute Manual Step    [1/5] Power on the DUT.
    Execute Manual Step    [2/5] Boot into the BIOS.
    Execute Manual Step    [3/5] Enter Device Manager.
    Execute Manual Step    [4/5] Enter TCG2 Configuration
    Execute Manual Step    [5/5] Scroll down to "TPM2 Hardware Supported Hash Algorithm"
    Execute Manual Step    [Expected result] The entry should contain SHA512.

TPM011.101 Change active PCR banks with TPM PPI (EDK2 UEFI)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is working properly in the firmware by changing active TPM PCR banks.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM011.101 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM011.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM011.101 not supported
    Power On
    Enter The TCG Configuration Menu
    Get Menu Construction    checkpoint=Esc=Exit
    Press Key N Times    1    ${ARROW_UP}
    ${menu}=    Get Menu Construction    checkpoint=Esc=Exit
    ${sha1_value}=    Get Option State    ${menu}    PCR Bank: SHA1
    ${sha256_value}=    Get Option State    ${menu}    PCR Bank: SHA256
    ${sha1_position}=    Count Arrows Up To Reach The Option    PCR Bank: SHA1
    ${sha256_position}=    Count Arrows Up To Reach The Option    PCR Bank: SHA256
    IF    ${TPM_MULTIPLE_BANK_SUPPORT} == ${TRUE}
        # Set all PCR Banks to True
        ${target_option_index}=    Search For Option Not Visible After Entering Menu    TPM2 Operation
        Reenter Menu
        Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
        VAR    ${checkpoint}=    \---------------------------------------------------------------------/
        ${tpm2_operation_menu}=    Get Menu Construction    ${checkpoint}    0    0
        Enter Submenu From Snapshot    ${tpm2_operation_menu}    TCG2 LogAllDigests
        Save Changes And Reset
        Enter The TCG Configuration Menu
    END
    # Order of checks below cannot be changed without changing desired TPM2 Banks states
    # sha1 = True, sha256 = False
    Reenter Menu
    IF    ${sha1_value} and not ${sha256_value}
        Log To Console    \nPCR banks already in the desired state
    ELSE
        IF    not ${sha1_value}
            Press Key N Times And Enter    ${sha1_position}    ${ARROW_UP}
            Reenter Menu
        END
        IF    ${sha256_value}
            Press Key N Times And Enter    ${sha256_position}    ${ARROW_UP}
            Reenter Menu
        END
        Check TPM2 Banks State After FW Changes    ${TRUE}    ${FALSE}
        Execute Reboot Command
        Enter The TCG Configuration Menu
    END
    # sha1 = False, sha256 = True
    Press Key N Times And Enter    ${sha256_position}    ${ARROW_UP}
    Reenter Menu
    Press Key N Times And Enter    ${sha1_position}    ${ARROW_UP}
    Reenter Menu
    Check TPM2 Banks State After FW Changes    ${FALSE}    ${TRUE}
    IF    ${TPM_MULTIPLE_BANK_SUPPORT} == ${TRUE}
        Execute Reboot Command
        Enter The TCG Configuration Menu
        # Get to the starting state: sha1 = True, sha256 = True
        Press Key N Times And Enter    ${sha1_position}    ${ARROW_UP}
        Check TPM2 Banks State After FW Changes    ${TRUE}    ${TRUE}
    END

TPM014.101 TPM single bank detection (EDK2 UEFI)
    [Documentation]    Test verifies if only one PCR bank is active, finds inactive
    ...    PCR bank, activates it, then reboots.
    ...    If platform supports only single PCR bank, firmware pop-up is handled.
    ...    After reboot, state of PCR banks in firmware is verified.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM014.101 not supported
    Variable Should Exist    ${TPM_MULTIPLE_BANK_SUPPORT}
    Power On
    Enter The TCG Configuration Menu
    &{banks_state}=    Check TPM PCR Banks State In FW
    Reenter Menu
    &{banks_positions}=    Get TPM PCR Banks Menu Positions In FW    ${banks_state}

    VAR    ${active_banks}=    ${0}
    VAR    ${bank_to_set}=    ${EMPTY}
    FOR    ${state_name}    IN    @{banks_state}
        IF    '$bank_to_set == $EMPTY'
            IF    ${banks_state["${state_name}"]} == ${FALSE}
                VAR    ${bank_to_set}=    ${state_name}
            END
        END
        IF    ${banks_state["${state_name}"]} == ${TRUE}
            VAR    ${active_banks}=    ${active_banks+1}
            VAR    ${active_bank}=    ${state_name}
        END
    END

    Should Be Equal As Integers    ${active_banks}    1    More than one PCR bank active at the beginning

    Toggle TPM PCR Bank In FW    ${banks_positions}    ${bank_to_set}
    Save Changes And Reset

    Read From Terminal Until
    ...    Press F12 to change the boot measurements to use PCR bank(s) of the TPM
    Press Key N Times    1    ${F12}

    IF    ${TPM_MULTIPLE_BANK_SUPPORT} == ${FALSE}
        Single PCR Bank Confirm In FW Popup    ${bank_to_set}

        Read From Terminal Until
        ...    Press F12 to change the boot measurements to use PCR bank(s) of the TPM
        Press Key N Times    1    ${F12}
    END

    Enter The TCG Configuration Menu
    ${banks_state_after}=    Check TPM PCR Banks State In FW
    ${expected_state}=    Prepare Dictionary Containing Expected PCRs State    ${banks_state}
    ...    ${active_bank}    ${bank_to_set}
    Dictionaries Should Be Equal    ${expected_state}    ${banks_state_after}    PCR Bank state not as expected.

TPM015.101 Check if platform is vulnerable to TPM GPIO reset (EDK2 UEFI)
    [Documentation]    This test aims to verify that the platform
    ...    is not vulnerable to a TPM GPIO reset attack.
    ...    This test requires a writable USB drive to be available for the DUT!
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM015.101 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM015.101 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM015.101 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs
    Prepare TPM GPIO Reset Utility

    # Checking if platform config present in tpm-gpio-fail
    ${detect_output}=    Execute Command In Terminal    /home/ubuntu/tpm-gpio-fail/detect/tpm-gpio-detect
    Skip If    'unknown platform' in '''${detect_output}'''    Test for platform not implemented

    # Booting into DTS to perform TPM GPIO reset test
    ${ubuntu_partition}=    Execute Command In Terminal    df -P . | sed -n '\$s/[[:blank:]].*//p'
    ${usb_partition}=    Get First USB Stick In Linux
    Sleep    5
    Log To Console    Booting into DTS...
    Power On
    Boot Dasharo Tools Suite Via IPXE Shell    https://boot.dasharo.com/dts/dts.ipxe
    Wait For DTS To Boot
    Enter Shell In DTS
    Execute Command In Terminal    mkdir /mnt/test
    Execute Command In Terminal    mkdir /mnt/usb
    Execute Command In Terminal    mount ${ubuntu_partition} /mnt/test
    Execute Command In Terminal    mount /dev/${usb_partition} /mnt/usb
    Log To Console    Running TPM reset test...

    # Running test (will cause serial to cut off) and waiting for it to finish
    Write Into Terminal
    ...    /mnt/test/home/ubuntu/tpm-gpio-fail/reset/tpm-gpio-assert > /mnt/usb/tpm-gpio-assert.log && sync
    Sleep    30

    # Restarting after test and checking the results
    Log To Console    Restarting after trying TPM reset...
    Power On
    Boot Dasharo Tools Suite Via IPXE Shell    https://boot.dasharo.com/dts/dts.ipxe
    Wait For DTS To Boot
    Enter Shell In DTS
    Execute Command In Terminal    mkdir /mnt/usb
    Execute Command In Terminal    mount /dev/${usb_partition} /mnt/usb
    ${assert_output}=    Execute Command In Terminal    cat /mnt/usb/tpm-gpio-assert.log
    Should Not Contain    ${assert_output}    RESULT: DW0 write verified

TPM001.201 TPM Support (Ubuntu)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Verify Presence Of Any PCRs Via Sysfs

TPM002.201 Verify TPM Version (Ubuntu)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    [Tags]    automated    minimal-regression
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM002.201 not supported
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Validate Expected TPM Version Via Sysfs

TPM003.201 Check TPM Physical Presence Interface (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM003.201 not supported
    Prepare TPM Test On Linux    ${ENV_ID_UBUNTU}
    Check TPM Physical Presence Interface

TPM009.201 Encrypt and Decrypt non-rootfs partition (Ubuntu)
    [Documentation]    Test encrypting and decrypting non-rootfs partition using TPM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM009.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM009.201 not supported
    Execute Manual Step    [1/7] Power on the DUT.
    Execute Manual Step    [2/7] Boot into the system.
    Execute Manual Step    [3/7] Log into the system by using the proper login and password.
    VAR    ${msg}=
    ...    [4/7] Create ext4 formatted LUKS partition with "hello-world" named file on it using following commands:
    ...    fallocate -l 20MB test-partition
    ...    dd if=/dev/urandom bs=1 count=32 status=none > key
    ...    cryptsetup luksFormat -q --key-file=key test-partition
    ...    cryptsetup luksOpen --key-file=key test-partition test-partition
    ...    mkfs.ext4 /dev/mapper/test-partition
    ...    mount /dev/mapper/test-partition /mnt
    ...    touch /mnt/hello-world
    ...    umount /dev/mapper/test-partition
    ...    cryptsetup luksClose test-partition
    ...    separator=\n
    Execute Manual Step    ${msg}
    VAR    ${msg}=
    ...    [5/7] Create the sealing object by executing the following commands:
    ...    tpm2_createprimary -Q -C o -c prim.ctx
    ...    cat key | tpm2_create -Q -g sha256 -u seal.pub -r seal.priv -i- -C prim.ctx
    ...    tpm2_load -Q -C prim.ctx -u seal.pub -r seal.priv -n seal.name -c seal.ctx
    ...    tpm2_evictcontrol -C o -c seal.ctx 0x81010001
    ...    tpm2_unseal -Q -c 0x81010001 > key
    ...    separator=\n
    Execute Manual Step    ${msg}
    VAR    ${msg}=
    ...    [6/7] Check a file stored on the partition by executing the following commands:
    ...    cryptsetup luksOpen ./test-partition --key-file=key test-partition
    ...    mount /dev/mapper/test-partition /mnt
    ...    ls /mnt | grep hello-world
    ...    separator=\n
    Execute Manual Step    ${msg}
    VAR    ${msg}=
    ...    [7/7] Clean up by executing the following commands:
    ...    umount /mnt
    ...    cryptsetup luksClose test-partition
    ...    rm -f key seal.* prim.* test-partition
    ...    tpm2_evictcontrol -c 0x81010001
    ...    separator=\n
    Execute Manual Step    ${msg}
    Execute Manual Step    [Expected result] The output in step 5 should contain "hello-world".

TPM010.201 Encrypt and Decrypt rootfs partition (Ubuntu)
    [Documentation]    Test encrypting and decrypting rootfs partition using TPM.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM010.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM010.201 not supported
    Execute Manual Step    [1/18] Power on the DUT.
    Execute Manual Step    [2/18] Boot into the BIOS.
    Execute Manual Step    [3/18] Enter the Boot Maintenance Manager.
    Execute Manual Step    [4/18] Enter Boot Options.
    Execute Manual Step    [5/18] Enter Add Boot Option.
    Execute Manual Step    [6/18] Enter the "ubuntu-enc" volume.
    Execute Manual Step    [7/18] Go to "<EFI>/<ubuntu>" and select "shimx64.efi".
    Execute Manual Step    [8/18] Go to "Input the description" and enter "ubuntu-enc-rootfs".
    Execute Manual Step    [9/18] Go to "Commit Changes and Exit" and press Enter.
    Execute Manual Step    [10/18] Save the changes and reset.
    Execute Manual Step    [11/18] Enter the boot menu and choose the newly added option.
    Execute Manual Step    [12/18] Unlock the rootfs with your password.
    Execute Manual Step    [13/18] Log into the system by using the proper login and password.
    VAR    ${msg}=
    ...    [14/18] Bind clevis by executing the following command:
    ...    echo \${UBUNTU_PASSWORD} | clevis luks bind -d /dev/disk/by-label/encrypted-rootfs tpm2 '{"pcr_ids":"0,1,2,3,7"}' -s 1
    ...    where \${UBUNTU_PASSWORD} is your password.
    ...    separator=\n
    Execute Manual Step    ${msg}
    Execute Manual Step    [15/18] Reboot the system.
    Execute Manual Step    [16/18] Wait for the partition to be unlocked.
    Execute Manual Step    [17/18] Log into the system.
    VAR    ${msg}=
    ...    [18/18] Clean up by executing the following command:
    ...    clevis luks unbind -d /dev/vda3 -f -s 1
    ...    separator=\n
    Execute Manual Step    ${msg}
    Execute Manual Step    [Expected result 1/2] In step 12 you should be prompted to unlock the rootfs.
    Execute Manual Step    [Expected result 2/2] In step 16 the partition should be unlocked automatically.

TPM012.201 Check if the ChangeEPS works (Ubuntu)
    [Documentation]    Check if the `TPM2 ChangeEPS` setup menu option works properly.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM012.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM012.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs
    Detect Or Install Package    tpm2-tools
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -C e -c primary_key.ctx    60
    Execute Linux Tpm2 Tools Command    tpm2_create -u key.pub -r key.priv -C primary_key.ctx
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    echo "my secret" > secret.data
    Execute Linux Tpm2 Tools Command    tpm2_sign -c key.ctx -o sig.rssa secret.data
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_verifysignature -c key.ctx -s sig.rssa -m secret.data
    Execute Linux Command    rm -f primary_key.ctx sig.rssa secret.data
    Execute Reboot Command
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_manager_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot
    ...    ${device_manager_menu}
    ...    TCG2 Configuration
    ${target_option_index}=    Search For Option Not Visible After Entering Menu    TPM2 Operation
    Reenter Menu
    Press Key N Times And Enter    ${target_option_index}    ${ARROW_DOWN}
    VAR    ${checkpoint}=    \---------------------------------------------------------------------/
    ${tpm2_operation_menu}=    Get Menu Construction    ${checkpoint}    0    0
    Enter Submenu From Snapshot    ${tpm2_operation_menu}    TPM2 ChangeEPS
    Save Changes And Reset
    Read From Terminal Until
    ...    Press F12 to clear and change identity of the TPM
    Press Key N Times    1    ${F12}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -C e -c primary_key.ctx    60
    Flush TPM Contexts
    ${result}=    Run Keyword And Ignore Error    Execute Linux Tpm2 Tools Command
    ...    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    rm -f primary_key.ctx key.pub key.priv key.ctx
    IF    '${result}[0]' == 'FAIL'
        Should Contain    ${result}[1]    0x1DF
    ELSE
        FAIL    msg=tpm2_load should result in an error.\n
    END

TPM013.201 TPM PPI Prompt (Ubuntu)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface pop-up is displayed upon sending a PPI request to the TPM,
    ...    and that the requested operation is performed only if the user
    ...    accepts it.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM013.201 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM013.201 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM013.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM013.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User

    TPM2 Set Owner Key Password Linux
    ${set}=    TPM2 Check Owner Key Password Set
    Should Be True    ${set}
    TPM2 PPI Request Clear TPM Linux

    # Deny changes
    Execute Reboot Command
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${ESC}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${set}=    TPM2 Check Owner Key Password Set
    Should Be True    ${set}
    TPM2 PPI Request Clear TPM Linux

    # Accept changes
    Execute Reboot Command
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${F12}
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    ${set}=    TPM2 Check Owner Key Password Set
    Should Not Be True    ${set}

TPM015.201 Check if platform is vulnerable to TPM GPIO reset (Ubuntu)
    [Documentation]    This test aims to verify that the platform
    ...    is not vulnerable to a TPM GPIO reset attack
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM015.201 not Supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    TPM015.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs
    Prepare TPM GPIO Reset Utility

    # Checking if platform config present in tpm-gpio-fail
    ${detect_output}=    Execute Command In Terminal    /home/ubuntu/tpm-gpio-fail/detect/tpm-gpio-detect
    Skip If    'unknown platform' in '''${detect_output}'''    Test for platform not implemented

    # Manual steps to perform TPM GPIO reset test
    ${ubuntu_partition}=    Execute Command In Terminal    df -P . | sed -n '\$s/[[:blank:]].*//p'
    Execute Manual Step
    ...    [1/5] Restart DUT and boot into Dasharo Tools Suite either by iPXE Network Boot or DTS USB drive.
    Execute Manual Step    [2/5] Press S to enter DTS shell
    Execute Manual Step
    ...    [3/5] Mount Ubuntu partition using "mkdir /mnt/test && mount ${ubuntu_partition} /mnt/test"
    Execute Manual Step    [4/5] Run "/mnt/test/home/ubuntu/tpm-gpio-fail/reset/tpm-gpio-assert"
    Execute Manual Step
    ...    [5/5] Are PCRs preserved (not cleared)? OR Is the result "not vulnerable (assertion skipped)"?
    ...    PCRs were able to be cleared.

TPM001.202 TPM Support (Fedora)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the Linux OS.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM001.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Verify Presence Of Any PCRs Via Sysfs

TPM002.202 Verify TPM Version (Fedora)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    [Tags]    automated    minimal-regression
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM002.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Validate Expected TPM Version Via Sysfs

TPM003.202 Check TPM Physical Presence Interface (Fedora)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    TPM003.202 not supported
    Prepare TPM Test On Linux    ${ENV_ID_FEDORA}
    Check TPM Physical Presence Interface

TPM001.205 TPM Support (XCP-NG)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from the XCP-NG OS.
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM001.205 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Verify Presence Of Any PCRs Via Sysfs

TPM002.205 Verify TPM version (XCP-NG)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the XCP-NG OS.
    [Tags]    automated    minimal-regression
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM002.205 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Validate Expected TPM Version Via Sysfs

TPM003.205 Check TPM Physical Presence Interface (XCP-NG)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the XCP-NG OS.
    Skip If    '${ENV_ID_XCP_NG}' not in ${TESTED_LINUX_DISTROS}    TPM003.205 not supported
    Power On
    Boot And Login To OS    ${ENV_ID_XCP_NG}
    Verify Presence Of TPM Via Sysfs
    Check TPM Physical Presence Interface

TPM001.301 TPM Support (Windows)
    [Documentation]    Check whether the TPM is initialized correctly and the
    ...    PCRs can be accessed from Windows.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM001.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal    get-tpm
    ${tpm_present}=    Get Lines Matching Regexp    ${out}    ^TpmPresent\\s+:\\s.*$
    ${tpm_ready}=    Get Lines Matching Regexp    ${out}    ^TpmReady\\s+:\\s.*$
    ${tpm_enabled}=    Get Lines Matching Regexp    ${out}    ^TpmEnabled\\s+:\\s.*$
    Should Contain    ${tpm_present}    True
    Should Contain    ${tpm_ready}    True
    Should Contain    ${tpm_enabled}    True

TPM002.301 Verify TPM Version (Windows)
    [Documentation]    This test aims to verify that the TPM version is
    ...    correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM002.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal
    ...    tpmtool getdeviceinformation
    Should Contain    ${out}    TPM Version: 2.0

TPM003.301 Check TPM Physical Presence Interface (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface is correctly recognized by the operating system.
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM003.301 not supported
    Power On
    Boot And Login To Windows
    ${out}=    Execute Command In Terminal    tpmtool getdeviceinformation
    Should Contain    ${out}    PPI Version: 1.3

TPM013.301 TPM PPI Prompt (Windows)
    [Documentation]    This test aims to verify that the TPM Physical Presence
    ...    Interface pop-up is displayed upon sending a PPI request to the TPM,
    ...    and that the requested operation is performed only if the user
    ...    accepts it.
    Skip If    not ${TPM_SUPPORTED_VERSION} == 2    TPM013.301 not supported
    Skip If    not ${TESTS_IN_WINDOWS_SUPPORT}    TPM013.301 not supported
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    TPM013.301 not supported
    Power On
    Boot And Login To Windows

    ${owner_key}=    TPM2 Get Owner Key Windows
    TPM2 PPI Request Clear TPM Windows

    # Deny changes
    Execute Reboot Command    os=windows
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${ESC}
    Boot And Login To Windows
    ${new_key}=    TPM2 Get Owner Key Windows
    Should Be Equal    ${new_key}    ${owner_key}
    TPM2 PPI Request Clear TPM Windows

    # Accept changes
    Execute Reboot Command    os=windows
    ${prompt}=    Read From Terminal Until
    ...    Press ESC to reject this change request and continue
    Should Contain    ${prompt}    clear the TPM
    Press Key N Times    1    ${F12}
    Boot And Login To Windows
    ${new_key}=    TPM2 Get Owner Key Windows
    Should Not Be Equal As Strings    ${new_key}    ${owner_key}

TPM001.401 TPM Support (ESXi)
    [Documentation]    Check whether the TPM is detected and supported in ESXi.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    TPM001.401 not supported
    Execute Manual Step    [1/3] Power on the DUT and boot into ESXi
    Execute Manual Step    [2/3] Access the ESXi console and run: esxcli hardware tpm get
    Execute Manual Step    [3/3] Confirm the TPM is detected and its status shows as present/supported

TPM002.401 Verify TPM version (ESXi)
    [Documentation]    Check whether the correct TPM version is reported in ESXi.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    TPM002.401 not supported
    Execute Manual Step    [1/3] Power on the DUT and boot into ESXi
    Execute Manual Step    [2/3] Access the ESXi console and run: esxcli hardware tpm get
    Execute Manual Step    [3/3] Confirm the TPM version reported matches the expected version (TPM 2.0)

TPM003.401 Check TPM Physical Presence Interface (ESXi)
    [Documentation]    Check whether the TPM Physical Presence Interface is available in ESXi.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_ESXI_SUPPORT}    TPM003.401 not supported
    Execute Manual Step    [1/3] Power on the DUT and boot into ESXi
    Execute Manual Step    [2/3] Access the ESXi console and check TPM PPI availability
    Execute Manual Step    [3/3] Confirm the TPM Physical Presence Interface is accessible in ESXi


*** Keywords ***
Prepare TPM Test On Linux
    [Documentation]    Run common actions required for TPM tests in Linux
    [Arguments]    ${env_id}=${DEFAULT_BOOT_OS_ID}
    Power On
    Boot System Or From Connected Disk    ${env_id}
    Login To Linux
    Switch To Root User
    Verify Presence Of TPM Via Sysfs

Check TPM Physical Presence Interface
    ${out}=    Execute Command In Terminal    cat /sys/class/tpm/tpm0/ppi/version
    IF    '${TPM_SUPPORTED_VERSION}' == '1'
        Should Contain    ${out}    1.2
    ELSE IF    '${TPM_SUPPORTED_VERSION}' == '2'
        Should Contain    ${out}    1.3
    ELSE
        Fail    Invalid expected version, please verify config
    END

TPM2 Set Owner Key Password Linux
    [Documentation]    Set the owner key password for the TPM2
    [Arguments]    ${password}=tpm2pass
    Execute Command In Terminal    sudo tpm2_changeauth -c o ${password}

TPM2 Check Owner Key Password Set
    [Documentation]    Check if the owner key password is set for the TPM2
    ${out}=    Execute Command In Terminal    sudo tpm2_getcap properties-variable
    ${out}=    Get Lines Matching Regexp    ${out}    ownerAuthSet    partial_match=True
    ${status}=    Run Keyword And Return Status    Should Contain    ${out}    1
    RETURN    ${status}

TPM2 PPI Request Clear TPM Linux
    [Documentation]    Clear the TPM using the TPM PPI in Linux
    # 5 - PPI function ClearTPM, PPI Specification, Family “1.2” and “2.0”
    #    Version 1.30 Revision 00.52 table 2
    Execute Command In Terminal    echo 5 | sudo tee /sys/class/tpm/tpm0/ppi/request

TPM2 PPI Request Clear TPM Windows
    [Documentation]    Clear the TPM using the TPM PPI in Windows
    # 5 - PPI function ClearTPM, PPI Specification, Family “1.2” and “2.0”
    #    Version 1.30 Revision 00.52 table 2
    Execute Command In Terminal    Clear-Tpm -UsePPI    timeout=300s

TPM2 Get Owner Key Windows
    [Documentation]    Check if the owner key password is set for the TPM2
    ${out}=    Execute Command In Terminal    Get-Tpm    timeout=300s
    ${key}=    Get Lines Matching Regexp    ${out}    OwnerAuth    partial_match=True
    ${key}=    Get Regexp Matches    ${key}    OwnerAuth\ +:\ (.*)    1
    RETURN    ${key}

Prepare TPM GPIO Reset Utility
    [Documentation]    Clone and build the utility to test form gpio reset vulnerability
    Detect Or Install Package    tpm2-tools
    Detect Or Install Package    make
    Detect Or Install Package    gcc
    Detect Or Install Package    git
    Detect Or Install Package    libpci-dev
    Clone Git Repository    https://github.com/tlaurion/tpm-gpio-fail.git
    Set Prompt For Terminal    root@3mdeb:/home/ubuntu
    Execute Command In Terminal    cd tpm-gpio-fail
    Execute Command In Terminal    git checkout minimal-platform-fork
    Sleep    10
    Execute Command In Terminal    rm reset/tpm-gpio-assert
    Execute Command In Terminal    rm detect/tpm-gpio-detect
    Execute Command In Terminal    make all
    Log To Console    \ntpm-gpio-fail download successful.
    Execute Command In Terminal    sync
