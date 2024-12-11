*** Settings ***
Documentation       This suite verifies the correct operation of keywords parsing Secure Boot menus from the lib/secure-boot-lib.robot.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
Enter Secure Boot Menu
    [Documentation]    Test Enter Secure Boot Menu kwd
    Power On
    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Secure Boot Configuration
    Should Contain    ${out}    Current Secure Boot State

Enter Secure Boot Menu And Return Construction
    [Documentation]    Test Enter Secure Boot Menu And Return Construction kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[-1]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Enter Advanced Secure Boot Keys Management
    [Documentation]    Test Enter Advanced Secure Boot Keys Management kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enter Advanced Secure Boot Keys Management    ${sb_menu}
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    Advanced Secure Boot Keys Management
    Should Contain    ${out}    Reset to default Secure Boot Keys
    Should Contain    ${out}    Erase all Secure Boot Keys

Enter Advanced Secure Boot Keys Management And Return Construction
    [Documentation]    Test Enter Advanced Secure Boot Keys Management And Return Construction kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Log    ${advanced_menu}
    Should Contain    ${advanced_menu}    > Reset to default Secure Boot Keys
    Should Contain    ${advanced_menu}    > Erase all Secure Boot Keys
    Should Not Contain    ${advanced_menu}    Individual key management:
    Should Contain    ${advanced_menu}    > PK Options
    Should Contain    ${advanced_menu}    > KEK Options
    Should Contain    ${advanced_menu}    > DB Options
    Should Contain    ${advanced_menu}    > DBX Options

Reset To Default Secure Boot Keys
    [Documentation]    Test Reset To Default Secure Boot Keys kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset

    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Not Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${out}    Custom and enroll the keys/PK first.

Erase All Secure Boot Keys
    [Documentation]    Test Erase All Secure Boot Keys kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset

    Enter Secure Boot Menu
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    To enable Secure Boot, set Secure Boot Mode to
    Should Contain    ${out}    Custom and enroll the keys/PK first.

Secure Boot Menu Parsing With Default Keys
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[1]    ^Enable Secure Boot \\[.\\].*$
    Should Match Regexp    ${sb_menu}[2]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Secure Boot Menu Parsing With Erased Keys
    [Documentation]    Test Enter Secure Boot Menu And Return Construction kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Save Changes And Reset

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Should Not Contain    ${sb_menu}    Secure Boot Configuration
    Should Match Regexp    ${sb_menu}[0]    ^Current Secure Boot State.*$
    Should Match Regexp    ${sb_menu}[1]    ^Secure Boot Mode \\<.*\\>.*$
    Should Not Contain    ${sb_menu}    To enable Secure Boot, set Secure Boot Mode to
    Should Not Contain    ${sb_menu}    Custom and enroll the keys/PK first.

Return Secure Boot State
    [Documentation]    Test Return Secure Boot State kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain Any    ${sb_state}    Enabled    Disabled

Make Sure That Keys Are Provisioned
    [Documentation]    Test Make Sure That Keys Are Provisioned kwd
    # 1. Erase All SB keys
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${advanced_menu}
    Exit From Current Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    Should Not Contain Match    ${sb_menu}    Enable Secure Boot [*

    # 2. Call tke kwd and make sure that the keys are provisioned
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Should Contain Match    ${sb_menu}    Enable Secure Boot [*

    # 3. Restore default SB keys
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Reset To Default Secure Boot Keys    ${advanced_menu}
    Exit From Current Menu
    ${sb_menu}=    Get Secure Boot Menu Construction
    Should Contain Match    ${sb_menu}    Enable Secure Boot [*

    # 4. Call tke kwd and make sure that the keys are still provisioned
    ${sb_menu}=    Make Sure That Keys Are Provisioned    ${sb_menu}
    Should Contain Match    ${sb_menu}    Enable Secure Boot [*

Enable Secure Boot
    [Documentation]    Test Enable Secure Boot kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain    ${sb_state}    Enabled

Disable Secure Boot
    [Documentation]    Test Disable Secure Boot kwd
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    Save Changes And Reset

    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_state}=    Return Secure Boot State    ${sb_menu}
    Should Contain    ${sb_state}    Disabled

Enable and Disable Secure Boot Multiple Times
    [Documentation]    Test Enabling and Disabling Secure Boot 5 times
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    FOR    ${index}    IN RANGE    5
        Enable Secure Boot    ${sb_menu}
        Save Changes And Reset

        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        ${sb_state}=    Return Secure Boot State    ${sb_menu}
        Should Contain    ${sb_state}    Enabled

        Disable Secure Boot    ${sb_menu}
        Save Changes And Reset

        ${sb_menu}=    Enter Secure Boot Menu And Return Construction
        ${sb_state}=    Return Secure Boot State    ${sb_menu}
        Should Contain    ${sb_state}    Disabled
    END

Enter Enroll Signature Using File In DB Options
    [Documentation]    Test if we can enter File Manager in DB Options, correctly parsing all menus on our way.
    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${advanced_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    Log    ${advanced_menu}

    ${db_opts_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${advanced_menu}
    ...    DB Options
    ...    opt_only=${TRUE}
    Log    ${db_opts_menu}
    Should Contain    ${db_opts_menu}    > Enroll Signature
    Should Contain    ${db_opts_menu}    > Delete Signature

    ${enroll_sig_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${db_opts_menu}
    ...    Enroll Signature
    ...    opt_only=${FALSE}
    Log    ${enroll_sig_menu}
    Should Contain    ${enroll_sig_menu}    > Enroll Signature Using File
    Should Contain    ${enroll_sig_menu}    Signature GUID _
    Should Contain    ${enroll_sig_menu}    > Commit Changes and Exit
    Should Contain    ${enroll_sig_menu}    > Discard Changes and Exit

    Enter Submenu From Snapshot    ${enroll_sig_menu}    Enroll Signature Using File
    ${out}=    Read From Terminal Until    Esc=Exit
    Should Contain    ${out}    File Explorer
