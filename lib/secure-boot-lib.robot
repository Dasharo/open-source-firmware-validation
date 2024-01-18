*** Settings ***
Documentation       Collection of keywords related to UEFI Secure Boot

Library             ../lib/secure-boot-lib.py
Resource            ../keywords.robot


*** Variables ***
${GOOD_KEYS_URL}=           https://cloud.3mdeb.com/index.php/s/SjM5dQGji4XDAni/download/good_keys.img
${GOOD_KEYS_NAME}=          good_keys.img
${GOOD_KEYS_SHA256}=        13de737ba50c8d14a88aaf5314a938fb6826e18ba8f337470ee490b17dd6bea8
${NOT_SIGNED_URL}=          https://cloud.3mdeb.com/index.php/s/zmJXxGG4piGB2Me/download/not_signed.img
${NOT_SIGNED_NAME}=         not_signed.img
${NOT_SIGNED_SHA256}=       15dc0a250b73c3132b1d7c5f8e81f00cc34d899c3ddecbb838a8cd0b66c4f608
${BAD_KEYS_URL}=            https://cloud.3mdeb.com/index.php/s/BJPbSqRH6NdbRym/download/bad_keys.img
${BAD_KEYS_NAME}=           bad_keys.img
${BAD_KEYS_SHA256}=         6da92bd97d4b4ca645fa98dcdfdc0c6876959e5b815a36f1f7759bc5463e7b19
${BAD_FORMAT_URL}=          https://cloud.3mdeb.com/index.php/s/AsBnATiHTZQ6jae/download/bad_format.img
${BAD_FORMAT_NAME}=         bad_format.img
${BAD_FORMAT_SHA256}=       59d17bc120dfd0f2e6948a2bfdbdf5fb06eddcb44f9a053a8e7b8f677e21858c
${INTERMEDIATE_URL}=        https://cloud.3mdeb.com/index.php/s/LSQ7NAJyEGbnRNk/download/intermediate_db.img
${INTERMEDIATE_NAME}=       intermediate_db.img
${INTERMEDIATE_SHA256}=     5261340f3de5c3e70a11273c9bb94a3d01cb34302504982ba7ac179be0de4439
${RSA2_K_TEST_NAME}=        hello_rsa2k_test.img
${RSA2_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/85KSa7EFaMtnJQS/download/hello_rsa2k_test.img
${RSA2_K_TEST_SHA256}=      5007aa3051c847eca519d31e3446951012520e103b12deaee7daf29a10354ed4
${RSA3_K_TEST_NAME}=        hello_rsa3k_test.img
${RSA3_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/7pwazGCojdeWDMX/download/hello_rsa3k_test.img
${RSA3_K_TEST_SHA256}=      7f62edb71d2567ce7fcd009c274bd012bf8b60a9072a9470e11fc6d9966359d9
${RSA4_K_TEST_NAME}=        hello_rsa4k_test.img
${RSA4_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/gD54FSWfrYqr2Gz/download/hello_rsa4k_test.img
${RSA4_K_TEST_SHA256}=      abab541a7c676b40a2a1d58d22d5fe4c6a236b83c1e833d5bfd18a03b7664026
${ECDSA256_TEST_NAME}=      hello_ecdsa256_test.img
${ECDSA256_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/aBmETzTJGeGNg3t/download/hello_ecdsa256_test.img
${ECDSA256_TEST_SHA256}=    979f8b24cb09f6e10a71f736799340dc16a081a6e4a6d009ca65e0cebeb890bd
${ECDSA384_TEST_NAME}=      hello_ecdsa384_test.img
${ECDSA384_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/dcmckksf2qx9AoD/download/hello_ecdsa384_test.img
${ECDSA384_TEST_SHA256}=    181c1e9f8051f80677f489aec9ac11ce311bb2a1f6ee6a659d7ae7ca2fbc1bf4
${ECDSA521_TEST_NAME}=      hello_ecdsa521_test.img
${ECDSA521_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/cmybRxzmKx2dATW/download/hello_ecdsa521_test.img
${ECDSA521_TEST_SHA256}=    cbd90c85b6d4c0c59f45da600c8b63e70b858330b2a27924253e6bf014906240
${EXPIRED_URL}=             https://cloud.3mdeb.com/index.php/s/ReBEXy9yXTGWGyb/download/expired_cert.img
${EXPIRED_NAME}=            expired_cert.img
${EXPIRED_SHA256}=          831c4f0ec9bf4e40a80e15deb16d76a60524e91bd9e9ebe07847e1ea7021079a


*** Keywords ***
Get Secure Boot Menu Construction
    [Documentation]    Secure Boot menu is very different than all
    ...    of the others so we need a special keyword for parsing it.
    ...    Return only selectable entries. If some menu option is not
    ...    selectable (grayed out) it will not be in the menu construction
    ...    list.
    [Arguments]    ${checkpoint}=Esc=Exit    ${lines_top}=1    ${lines_bot}=1
    ${out}=    Read From Terminal Until    ${checkpoint}
    # At first, parse the menu as usual
    ${menu}=    Parse Menu Snapshot Into Construction    ${out}    ${lines_top}    ${lines_bot}
    ${enable_sb_can_be_selected}=    Run Keyword And Return Status
    ...    List Should Not Contain Value
    ...    ${menu}
    ...    To enable Secure Boot, set Secure Boot Mode to
    # If we have a help message indicating keys are not provisioned,
    # we drop this help message end Enable Secure Boot option (which is
    # not selectable) from the menu construction.
    IF    ${enable_sb_can_be_selected} == ${FALSE}
        Remove Values From List
        ...    ${menu}
        ...    To enable Secure Boot, set Secure Boot Mode to
        ...    Custom and enroll the keys/PK first.
        ...    Enable Secure Boot [ ]
        ...    Enable Secure Boot [X]
    END
    RETURN    ${menu}

Enter Secure Boot Menu
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on.
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${device_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    Device Manager
    Enter Submenu From Snapshot    ${device_mgr_menu}    Secure Boot Configuration

Enter Secure Boot Menu And Return Construction
    [Documentation]    This keyword enters Secure Boot menu after the platform was powered on. Returns Secure Boot menu construction.
    Enter Secure Boot Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    RETURN    ${sb_menu}

Enter Advanced Secure Boot Keys Management
    [Documentation]    Enables Secure Boot Custom Mode and enters Advanced Management menu.
    [Arguments]    ${sb_menu}
    Set Option State    ${sb_menu}    Secure Boot Mode    Custom Mode
    # After selecting Custom Mode, the Advanced Menu is one below
    Press Key N Times And Enter    1    ${ARROW_DOWN}

Enter Advanced Secure Boot Keys Management And Return Construction
    [Documentation]    Enables Secure Boot Custom Mode and enters Advanced Management menu.
    [Arguments]    ${sb_menu}
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    ${menu}=    Get Submenu Construction    opt_only=${TRUE}
    RETURN    ${menu}

Reset To Default Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Reset to default Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter

Erase All Secure Boot Keys
    [Documentation]    This keyword assumes that we are in the Advanced Secure
    ...    Boot menu already.
    [Arguments]    ${advanced_menu}
    Enter Submenu From Snapshot    ${advanced_menu}    Erase all Secure Boot Keys
    Read From Terminal Until    Are you sure?
    Press Enter

Return Secure Boot State
    [Documentation]    Returns the state of Secure Boot as reported in the Secure Boot Configuration menu
    [Arguments]    ${sb_menu}
    ${index}=    Get Index Of Matching Option In Menu    ${sb_menu}    Secure Boot State
    ${sb_state}=    Get From List    ${sb_menu}    ${index}
    ${sb_state}=    Remove String    ${sb_state}    Secure Boot State
    ${sb_state}=    Strip String    ${sb_state}
    RETURN    ${sb_state}

Make Sure That Keys Are Provisioned
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${need_reset}=    Run Keyword And Return Status    Should Not Contain Match    ${sb_menu}    Enable Secure Boot *
    IF    ${need_reset} == ${TRUE}
        ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
        Reset To Default Secure Boot Keys    ${advanced_menu}
        Exit From Current Menu
        ${sb_menu}=    Get Secure Boot Menu Construction
    END
    RETURN    ${sb_menu}

Enable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Set Option State    ${sb_menu}    Enable Secure Boot    ${TRUE}

Disable Secure Boot
    [Documentation]    Expects to be executed when in Secure Boot configuration menu.
    [Arguments]    ${sb_menu}
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Set Option State    ${sb_menu}    Enable Secure Boot    ${FALSE}

Check Secure Boot In Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Linux Command    dmesg | grep secureboot
    Should Contain Any    ${out}    disabled    enabled
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    enabled
    RETURN    ${sb_status}

Check Secure Boot In Windows
    [Documentation]    Keyword checks Secure Boot state in Windows.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Command In Terminal    Confirm-SecureBootUEFI
    Should Contain Any    ${out}    True    False
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    True
    RETURN    ${sb_status}

Enter Enroll DB Signature Using File In DB Options
    [Documentation]    Keyword checks Secure Boot state in Windows.
    [Arguments]    ${advanced_menu}
    ${db_opts_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${advanced_menu}
    ...    DB Options
    ...    opt_only=${TRUE}
    ${enroll_sig_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${db_opts_menu}
    ...    Enroll Signature
    ...    opt_only=${FALSE}
    Enter Submenu From Snapshot    ${enroll_sig_menu}    Enroll Signature Using File

Enter Volume In File Explorer
    [Documentation]    Enter the given volume
    [Arguments]    ${target_volume}
    # 1. Read out the whole File Explorer menu
    ${volumes}=    Get Submenu Construction    opt_only=${TRUE}
    Log    ${volumes}
    # 2. See if our label is within these entries
    ${index}=    Get Index Of Matching Option In Menu    ${volumes}    ${target_volume}    ${TRUE}
    # 3. If yes, go to the selected label
    IF    ${index} != -1
        Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
        # 4. If no, get the number of entries and go that many times below
    ELSE
        ${volumes_no}=    Get Length    ${volumes}
        Press Key N Times    ${volumes_no}    ${ARROW_DOWN}
        #    - check if the label is what we need, if yes, select
        FOR    ${in}    IN RANGE    20
            ${new_entry}=    Read From Terminal
            ${status}=    Run Keyword And Return Status
            ...    Should Contain    ${new_entry}    ${target_volume}
            IF    ${status} == ${TRUE}    BREAK
            IF    ${in} == 19    Fail    Volume not found
            Press Key N Times    1    ${ARROW_DOWN}
        END
        Press Key N Times    1    ${ENTER}
    END

Select File In File Explorer
    [Documentation]    Select the given file
    [Arguments]    ${target_file}
    # 1. Select desired file
    ${files}=    Get Submenu Construction
    Log    ${files}
    ${index}=    Get Index Of Matching Option In Menu    ${files}    ${target_file}
    # FIXME: We must add 1 due to empty selecatble space in File Manager
    Press Key N Times And Enter    ${index}+1    ${ARROW_DOWN}
    # 2. Save Changes
    ${enroll_sig_menu}=    Get Submenu Construction
    # Unselectable filename appears between options after file was selected
    Remove Values From List    ${enroll_sig_menu}    ${target_file}
    ${index}=    Get Index Of Matching Option In Menu    ${enroll_sig_menu}    Commit Changes and Exit
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}

Enter UEFI Shell
    [Documentation]    Boots given .efi file from UEFI shell.
    ...    Assumes that it is located on FS0.
    ${boot_menu}=    Enter Boot Menu Tianocore And Return Construction
    Enter Submenu From Snapshot    ${boot_menu}    UEFI Shell
    Read From Terminal Until    Shell>

Execute File In UEFI Shell
    # UEFI shell has different line ending than the one we have set for the
    # Telnet connection. We cannot change it while the connection is open.
    [Arguments]    ${file}
    Write Bare Into Terminal    fs0:
    Press Enter
    Read From Terminal Until    FS0:\\>
    Write Bare Into Terminal    ${file}
    Press Enter
    ${out}=    Read From Terminal Until    FS0:\\>
    RETURN    ${out}

Remove Old Secure Boot Keys In OS
    [Documentation]    Removes all files and directories in
    ...    `/usr/share/secureboot/keys/`
    Execute Linux Command Without Output    rm -rf /usr/share/secureboot/keys/*

Generate Secure Boot Keys In OS
    [Documentation]    Generates new Secure Boot keys using sbctl.
    ...    Returns true if succeeded.
    ${out}=    Execute Linux Command    sbctl create-keys
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    Secure boot keys created!
    RETURN    ${sb_status}

Enroll Secure Boot Keys In OS
    [Documentation]    Enrolls current keys to EFI using sbctl.
    ...    Returns true if succeeded.
    [Arguments]    ${result}
    ${out}=    Execute Linux Command    sbctl enroll-keys --yes-this-might-brick-my-machine
    IF    ${result} == True
        ${sb_status}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    Enrolled keys to the EFI variables!
        RETURN    ${sb_status}
    ELSE
        ${sb_status}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    failed to parse key
        RETURN    ${sb_status}
    END

Sign All Boot Components In OS
    [Documentation]    Signs boot components with current keys using sbctl
    Execute Linux Command    sbctl verify | awk -F ' ' '{print $2}' | tail -n+2 | xargs -I "#" sbctl sign "#"

Autoenroll Secure Boot Certificates
    [Documentation]    Enrolls Secure boot certificates automatically using tool
    ...    for automatic provisioning
    # 1. Erase Secure Boot Keys
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset    3    5

    # 2. Boot to Automatic provisioning tool
    Boot Dasharo Tools Suite    USB    True

    # 3. Enable SB after provisioning
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset

Compare KEK Certificate Using Mokutil In DTS
    [Documentation]    Compares two KEK certificates. It takes as argument the
    ...    source of the certificate and acquire it. Second KEK certificate is
    ...    taken as an output from mokutil --kek command executed in DTS.
    [Arguments]    ${first_certificate}
    ${is_https_link}=    Run Keyword And Return Status    Should Contain    ${first_certificate}    https://
    IF    ${is_https_link} == ${TRUE}
        Execute Command In Terminal    wget ${first_certificate} -O /tmp/first_certificate.crt
        ${first_certificate_string}=    Execute Command In Terminal
        ...    openssl x509 -in /tmp/first_certificate.crt -noout -text
    ELSE
        Log    Provided argument is not a link to download certificate    INFO
        FAIL
    END
    ${second_certificate_string}=    Execute Command In Terminal    mokutil --kek
    ${second_certificate_string}=    Convert Mokutil To Openssl Output    ${second_certificate_string}

    # 3. Compare the certificates
    Should Be Equal    ${first_certificate_string}    ${second_certificate_string}
