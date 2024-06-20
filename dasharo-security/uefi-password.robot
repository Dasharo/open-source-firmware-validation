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
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${UEFI_PASSWORD_SUPPORT}    UEFI setup password not supported
# If this suite fails in unexpected place, we will cause the next suites to fail
# because some password may be set.
Suite Teardown      Run Keywords
...                     Run Keyword If Any Tests Failed    Flash Firmware    ${FW_FILE}
...                     AND
...                     Log Out And Close Connection


*** Variables ***
@{DEFAULT_PASSWORD}=    1    q    a    z    X    S    W    @
@{WRONG_PASSWORD}=      w    r    o    n    g


*** Test Cases ***
PSW001.001 Check Password Setup option availability and default state
    [Documentation]    This test aims to verify whether User Password Management
    ...    submenu is available and, whether all options in the submenu have
    ...    correct default state.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW001.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW001.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${pass_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    ${menu_correct_status}=    Run Keyword And Return Status
    ...    Check User Password Management Menu Default State    ${pass_mgr_menu}
    Should Be True    ${menu_correct_status}

PSW002.001 Password setting mechanism correctness checking
    [Documentation]    This test aims to verify whether Change Admin Password
    ...    option works correctly - after restarting the device and trying
    ...    to enter the Setup Menu, a window to enter the password will be
    ...    displayed
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW002.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW002.001 not supported
    Power On
    Set Password 5 Times
    Power On
    Enter Setup Menu Tianocore
    ${output}=    Read From Terminal Until    password
    Should Contain    ${output}    Please input admin password

PSW003.001 Attempt to log in with a correct password
    [Documentation]    This test aims to verify whether, after entering the
    ...    correct Setup password, the Setup menu will be displayed.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW003.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW003.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    Type In The Password    ${DEFAULT_PASSWORD}
    # "ontinue" is a string that appears both in correct password screen
    # as well as in incorrect
    ${output}=    Read From Terminal Until    ontinue
    Should Not Contain    ${output}    Incorrect password

PSW004.001 Attempt to log in with an incorrect password
    [Documentation]    This test aims to verify whether, after entering
    ...    the incorrect Setup password, the message about the demand for
    ...    re-entering the password will be displayed.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW004.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW004.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    Type In The Password    ${WRONG_PASSWORD}
    # "ontinue" is a string that appears both in correct password screen
    # as well as in incorrect
    ${output}=    Read From Terminal Until    ontinue
    Should Contain    ${output}    Incorrect password

PSW005.001 Attempt to log in with an incorrect password 3 times
    [Documentation]    This test aims to verify whether, after entering
    ...    the incorrect Setup password, the message about the demand for
    ...    re-entering the password will be displayed.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW005.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW005.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    FOR    ${counter}    IN RANGE    0    2
        Type In The Password    ${WRONG_PASSWORD}
        Press Key N Times    1    ${ENTER}
        Sleep    0.5s
    END
    Type In The Password    ${WRONG_PASSWORD}
    Sleep    1s
    ${output}=    Read From Terminal
    Should Contain    ${output}    reset system

PSW006.001 Attempt to turn off setup password functionality
    [Documentation]    This test aims to verify whether there is a
    ...    possibility to turn off the Setup Password functionality by entering
    ...    empty password.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW006.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW006.001 not supported
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    Type In The Password    ${DEFAULT_PASSWORD}
    ${setup_menu}=    Get Setup Menu Construction
    ${pass_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    ${index}=    Get Index Of Matching Option In Menu    ${pass_mgr_menu}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    Type In BIOS Password    ${DEFAULT_PASSWORD}
    Press Key N Times    2    ${ENTER}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press Key N Times    1    ${ENTER}
    Power On
    Enter Setup Menu Tianocore
    Sleep    1s
    ${output}=    Read From Terminal
    Should Not Contain    ${output}    Please input admin password

PSW007.001 Attempt to set non-compilant password
    [Documentation]    This test aims to verify whether the attempt to set
    ...    a non-compilant password will be rejected.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW007.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW007.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${pass_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    ${index}=    Get Index Of Matching Option In Menu    ${pass_mgr_menu}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    Type In New Disk Password    ${WRONG_PASSWORD}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Not Contain    ${result}    New password is updated successfully

PSW008.001 Attempt to set old password
    [Documentation]    UEFI Setup password feature has been equipped with an
    ...    additional functionality that prevents re-setting one of the last 5
    ...    access passwords. This test aims to verify whether the attempt to
    ...    set old password again will be rejected.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    PSW008.001 not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    PSW008.001 not supported
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${pass_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    ${index}=    Get Index Of Matching Option In Menu    ${pass_mgr_menu}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    Type In New Disk Password    ${DEFAULT_PASSWORD}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Not Contain    ${result}    New password is updated successfully


*** Keywords ***
Set Password 5 Times
    [Documentation]    Sets the password 5 times to reset the same password
    ...    counter
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${pass_mgr_menu}=    Enter Submenu From Snapshot And Return Construction
    ...    ${setup_menu}
    ...    User Password Management
    ${index}=    Get Index Of Matching Option In Menu    ${pass_mgr_menu}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    @{password1}=    Create List    m    j    u    7    ^    Y    H    E
    @{password2}=    Create List    n    h    y    6    %    T    G    B
    @{password3}=    Create List    b    g    t    5    $    R    F    V
    @{password4}=    Create List    v    f    r    4    *    E    D    C
    @{password5}=    Create List    x    s    w    2    !    Q    A    Z
    @{passwords}=    Create List    ${password1}    ${password2}    ${password3}    ${password4}    ${password5}
    Type In New Disk Password    ${password1}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press Key N Times    2    ${ENTER}
    FOR    ${cnt}    IN RANGE    0    4
        Type In BIOS Password    ${passwords}[${cnt}]
        ${ind}=    Evaluate    ${cnt}+1
        Type In New Disk Password    ${passwords}[${ind}]
        ${result}=    Read From Terminal Until    ENTER to continue
        Should Contain    ${result}    New password is updated successfully
        Press Key N Times    2    ${ENTER}
    END
    Type In BIOS Password    ${passwords}[-1]
    Type In New Disk Password    ${DEFAULT_PASSWORD}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press Key N Times    1    ${ENTER}
