*** Settings ***
Library             SSHLibrary    timeout=90 seconds
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             Process
Library             OperatingSystem
Library             String
Library             RequestsLibrary
Library             Collections
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
Suite Setup         Run Keyword    Prepare Test Suite
Suite Teardown      Run Keyword    Log Out And Close Connection


*** Test Cases ***
PSW001.001 Check Password Setup option availability and default state
    [Documentation]    This test aims to verify whether User Password Management
    ...    submenu is available and, whether all options in the submenu have
    ...    correct default state.
    Skip If    not ${tests_in_firmware_support}    PSW001.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW001.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Enter Setup Menu Option    User Password Management
    ${entries}=    Get Setup Submenu Construction    Esc=Exit
    ${menu_correct_status}=    Run Keyword And Return Status
    ...    Check User Password Management menu default state
    ...    ${entries}
    Should Be True    ${menu_correct_status}

PSW002.001 Password setting mechanism correctness checking
    [Documentation]    This test aims to verify whether Change Admin Password
    ...    option works correctly - after restarting the device and trying
    ...    to enter the Setup Menu, a window to enter the password will be
    ...    displayed
    Skip If    not ${tests_in_firmware_support}    PSW002.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW002.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Set password 5 times
    Power On
    Enter Setup Menu Tianocore
    ${output}=    Read From Terminal Until    password
    Should Contain    ${output}    Please input admin password

PSW003.001 Attempt to log in with a correct password
    [Documentation]    This test aims to verify whether, after entering the
    ...    correct Setup password, the Setup menu will be displayed.
    Skip If    not ${tests_in_firmware_support}    PSW003.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW003.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    ${password}=    Set Variable    1    q    a    z    X    S    W    @
    Type in the password    ${password}
    # "ontinue" is a string that appears both in correct password screen
    # as well as in incorrect
    ${output}=    Read From Terminal Until    ontinue
    Should Not Contain    ${output}    Incorrect password

PSW004.001 Attempt to log in with an incorrect password
    [Documentation]    This test aims to verify whether, after entering
    ...    the incorrect Setup password, the message about the demand for
    ...    re-entering the password will be displayed.
    Skip If    not ${tests_in_firmware_support}    PSW004.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW004.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    ${wrong_password}=    Set Variable    w    r    o    n    g
    Type in the password    ${wrong_password}
    # "ontinue" is a string that appears both in correct password screen
    # as well as in incorrect
    ${output}=    Read From Terminal Until    ontinue
    Should Contain    ${output}    Incorrect password

PSW005.001 Attempt to log in with an incorrect password 3 times
    [Documentation]    This test aims to verify whether, after entering
    ...    the incorrect Setup password, the message about the demand for
    ...    re-entering the password will be displayed.
    Skip If    not ${tests_in_firmware_support}    PSW005.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW005.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    ${wrong_password}=    Set Variable    w    r    o    n    g
    FOR    ${counter}    IN RANGE    0    2
        Type in the password    ${wrong_password}
        Press key n times    1    ${ENTER}
        Sleep    0.5s
    END
    Type in the password    ${wrong_password}
    Sleep    1s
    ${output}=    Read From Terminal
    Should Contain    ${output}    reset system

PSW006.001 Attempt to turn off setup password functionality
    [Documentation]    This test aims to verify whether there is a
    ...    possibility to turn off the Setup Password functionality by entering
    ...    empty password.
    Skip If    not ${tests_in_firmware_support}    PSW006.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW006.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Read From Terminal Until    password
    ${password}=    Set Variable    1    q    a    z    X    S    W    @
    Type in the password    ${password}
    Enter Setup Menu Option    User Password Management
    ${menu_construction}=    Get Setup Submenu Construction    Esc=Exit
    ${index}=    Get Index of Matching option in menu    ${menu_construction}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press key n times and enter    ${index}    ${ARROW_DOWN}
    Type in BIOS password    ${password}
    Press key n times    2    ${ENTER}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press key n times    1    ${ENTER}
    Power On
    Enter Setup Menu Tianocore
    Sleep    1s
    ${output}=    Read From Terminal
    Should Not Contain    ${output}    Please input admin password

PSW007.001 Attempt to set non-compilant password
    [Documentation]    This test aims to verify whether the attempt to set
    ...    a non-compilant password will be rejected.
    Skip If    not ${tests_in_firmware_support}    PSW007.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW007.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Enter Setup Menu Option    User Password Management
    ${menu_construction}=    Get Setup Submenu Construction    Esc=Exit
    ${index}=    Get Index of Matching option in menu    ${menu_construction}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press key n times and enter    ${index}    ${ARROW_DOWN}
    ${password}=    Set Variable    w    r    o    n    g
    Type in new disk password    ${password}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Not Contain    ${result}    New password is updated successfully

PSW008.001 Attempt to set old password
    [Documentation]    UEFI Setup password feature has been equipped with an
    ...    additional functionality that prevents re-setting one of the last 5
    ...    access passwords. This test aims to verify whether the attempt to
    ...    set old password again will be rejected.
    Skip If    not ${tests_in_firmware_support}    PSW008.001 not supported
    Skip If    not ${tests_in_ubuntu_support}    PSW008.001 not supported
    Skip If    not ${uefi_password_support}
    Power On
    Enter Setup Menu Tianocore
    Enter Setup Menu Option    User Password Management
    ${menu_construction}=    Get Setup Submenu Construction    Esc=Exit
    ${index}=    Get Index of Matching option in menu    ${menu_construction}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press key n times and enter    ${index}    ${ARROW_DOWN}
    ${password}=    Set Variable    1    q    a    z    X    S    W    @
    Type in new disk password    ${password}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Not Contain    ${result}    New password is updated successfully


*** Keywords ***
Set password 5 times
    [Documentation]    Sets the password 5 times to reset the same password
    ...    counter
    Enter Setup Menu Tianocore
    Enter Setup Menu Option    User Password Management
    ${menu_construction}=    Get Setup Submenu Construction    Esc=Exit
    ${index}=    Get Index of Matching option in menu    ${menu_construction}    Change Admin Password
    Should Not Be Equal    '${index}'    -1    The option was not found in menu
    # we assume that there is an option in menu "Admin Password Status" which is
    # not accessible, hence we subtract one from received index
    ${index}=    Evaluate    ${index}-1
    Press key n times and enter    ${index}    ${ARROW_DOWN}
    ${password1}=    Set Variable    m    j    u    7    ^    Y    H    E
    ${password2}=    Set Variable    n    h    y    6    %    T    G    B
    ${password3}=    Set Variable    b    g    t    5    $    R    F    V
    ${password4}=    Set Variable    v    f    r    4    *    E    D    C
    ${password5}=    Set Variable    x    s    w    2    !    Q    A    Z
    ${password}=    Set Variable    1    q    a    z    X    S    W    @
    ${passwords}=    Create List    ${password1}    ${password2}    ${password3}    ${password4}    ${password5}
    Type in new disk password    ${password1}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press key n times    2    ${ENTER}
    FOR    ${cnt}    IN RANGE    0    4
        Type in BIOS password    ${passwords}[${cnt}]
        ${ind}=    Evaluate    ${cnt}+1
        Type in new disk password    ${passwords}[${ind}]
        ${result}=    Read From Terminal Until    ENTER to continue
        Should Contain    ${result}    New password is updated successfully
        Press key n times    2    ${ENTER}
    END
    Type in BIOS password    ${passwords}[-1]
    Type in new disk password    ${password}
    ${result}=    Read From Terminal Until    ENTER to continue
    Should Contain    ${result}    New password is updated successfully
    Press key n times    1    ${ENTER}
