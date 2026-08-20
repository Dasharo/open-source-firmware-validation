*** Settings ***
Library         Collections
Library         OperatingSystem
Library         Process
Library         String
Library         Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library         SSHLibrary    timeout=90 seconds
Library         RequestsLibrary
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite
...                 AND
...                 Skip If    not ${CMOS_CLEAR_SUPPORT}    CMOS clear tests not supported

Default Tags    automated


*** Variables ***
@{DEFAULT_PASSWORD}=    1    q    a    z    X    S    W    @


*** Test Cases ***
CMOS003.101 Clearing CMOS Does Not Reset Setup Password (EDK2 UEFI)
    [Documentation]    This test attempts to ensure that the Setup Password
    ...    isn't cleared by resetting CMOS.
    [Tags]    automated    semiauto    not_semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CMOS003.101 not supported
    Skip If    not ${UEFI_PASSWORD_SUPPORT}    CMOS003.101 not supported
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}
        Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CMOS003.101 requires firmware support
        Power On
        Set Password 5 Times
        Save Changes And Reset
        Clear Cmos With Fallback
        Power On
        Enter Setup Menu Tianocore
        Sleep    1s
        ${output}=    Read From Terminal
        Should Contain    ${output}    Please input admin password
    ELSE
        Log    Tests in firmware not supported. This test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}
        Execute Manual Step    [1/10] Power on DUT
        Execute Manual Step
        ...    [2/10] Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
        Execute Manual Step    [3/10] Enter User Password Management
        Execute Manual Step    [4/10] Change admin password to a new one
        Execute Manual Step    [5/10] Save setup configuration with F10 key, confirm with Y key
        Execute Manual Step    [6/10] Power off DUT
        Execute Manual Step
        ...    [7/10] Unplug the AC, disconnect battery, disconnect the CMOS battery and wait ~60 seconds
        Execute Manual Step    [8/10] Power on DUT
        Execute Manual Step
        ...    [9/10] Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
        Execute Manual Step
        ...    [10/10] Verify that after the CMOS reset, UEFI Menu still requires entering password to enter
    END
    [Teardown]    Run Keyword If    '${TEST_STATUS}' != 'SKIP'    CMOS003 Teardown

CMOS004.101 Clearing CMOS Resets Hybrid Graphics Mode Option (EDK2 UEFI)
    [Documentation]    This test attempts to verify whether there is a possibility to reset
    ...    the Hybrid Graphic Mode firmware option to default by resetting CMOS.
    [Tags]    automated    semiauto    not_semiauto
    Skip If    not ${NVIDIA_GRAPHICS_CARD_SUPPORT}    CMOS004.101 not supported
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}
        Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CMOS004.101 requires firmware support
        Power On
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
        Set Option State    ${pwr_menu}    Hybrid Graphics Mode    iGPU Only
        Save Changes And Reset
        Clear Cmos With Fallback
        Power On
        ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
        ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
        ${pwr_menu}=    Enter Dasharo Submenu    ${dasharo_menu}    Power Management Options
        ${gpu_mode}=    Get Option State    ${pwr_menu}    Hybrid Graphics Mode
        Should Be Equal    ${gpu_mode}    NVIDIA Optimus
    ELSE
        Log    Tests in firmware not supported. This test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}
        ...    This is a semiauto test.
        Execute Manual Step    [1/13] Power on DUT
        Execute Manual Step
        ...    [2/13] Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
        Execute Manual Step    [3/13] Enter Dasharo System Features submenu
        Execute Manual Step    [4/13] Enter Power Management Options submenu
        Execute Manual Step    [5/13] Set value of "Hybrid Graphics Mode" to "iGPU Only"
        Execute Manual Step    [6/13] Save setup configuration with F10 key, confirm with Y key
        Execute Manual Step    [7/13] Power off DUT
        Execute Manual Step
        ...    [8/13] Unplug the AC, disconnect battery, disconnect the CMOS battery and wait ~60 seconds
        Execute Manual Step    [9/13] Power on DUT, and check whether the screen works correctly
        Execute Manual Step
        ...    [10/13] Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
        Execute Manual Step    [11/13] Enter Dasharo System Features submenu
        Execute Manual Step    [12/13] Enter Power Management Options submenu
        Execute Manual Step
        ...    [13/13] Verify that the "Hybrid Graphics Mode" option is set to "NVIDIA Optimus", and boot into Ubuntu
    END
    [Teardown]    Run Keyword If    '${TEST_STATUS}' != 'SKIP'    Restore Boot Order After CMOS Clear

CMOS001.201 Clearing CMOS Resets Firmware Settings (Ubuntu)
    [Documentation]    Verify that clearing CMOS resets firmware settings to their defaults.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CMOS001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    IF    ${DASHARO_USB_MENU_SUPPORT}
        Set UEFI Option    UsbDriverStack    ${FALSE}
    END
    IF    ${DASHARO_NETWORKING_MENU_SUPPORT}
        Set UEFI Option    NetworkBoot    ${TRUE}
    END
    Clear Cmos With Fallback
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    IF    ${DASHARO_USB_MENU_SUPPORT}
        ${after}=    Get UEFI Option    UsbDriverStack
        Should Be True    ${after}
    END
    IF    ${DASHARO_NETWORKING_MENU_SUPPORT}
        ${after}=    Get UEFI Option    NetworkBoot
        Should Not Be True    ${after}
    END
    [Teardown]    Run Keywords
    ...    Restore Default UEFI Options
    ...    AND
    ...    Run Keyword If    '${TEST_STATUS}' != 'SKIP'    Restore Boot Order After CMOS Clear

CMOS002.201 Clearing CMOS Resets Bios Lock Option (Ubuntu)
    [Documentation]    Check whether clearing CMOS resets Bios Lock option.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    CMOS002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    Set UEFI Option    LockBios    ${FALSE}
    Clear Cmos With Fallback
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    ${after}=    Get UEFI Option    LockBios
    Should Be True    ${after}
    [Teardown]    Run Keywords
    ...    Restore Default UEFI Options
    ...    AND
    ...    Run Keyword If    '${TEST_STATUS}' != 'SKIP'    Restore Boot Order After CMOS Clear


*** Keywords ***
Clear Cmos With Fallback
    [Documentation]    Clears CMOS via RTE, otherwise instructs
    ...    tester to manually disconnect the battery
    IF    ${DUT_HAS_CMOS_RESET}
        Rte Psu Off
        Rte Clear Cmos
    ELSE
        Log    RTE CMOS clear not supported. Test becomes semiauto.    level=WARN
        Skip If    'semiauto' not in ${INCLUDE_TAGS}
        Execute Manual Step
        ...    Power off the device, unplug AC, disconnect battery, disconnect the CMOS battery and wait ~60 seconds
        Execute Manual Step    Reconnect the CMOS battery, connect the battery and plug the AC
        IF    $POWER_CTRL == 'none'
            Execute Manual Step    Power the device back on manually and boot into Ubuntu
        END
    END

Restore Default UEFI Options
    [Documentation]    Reset modified UEFI options after failed test.
    Power On
    Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
    IF    ${DASHARO_USB_MENU_SUPPORT}
        Set UEFI Option    UsbDriverStack    ${TRUE}
    END
    IF    ${DASHARO_NETWORKING_MENU_SUPPORT}
        Set UEFI Option    NetworkBoot    ${FALSE}
    END
    Set UEFI Option    LockBios    ${TRUE}

Restore Boot Order After CMOS Clear
    [Documentation]    Re-runs BPS009 logic to restore the custom boot entry.
    ...    that CMOS clear wiped.
    IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        Boot And Login To OS    ${DEFAULT_BOOT_OS_ID}
        Switch To Root User
        ${custom_bootnum}=    Ensure Custom Entry    ${DEFAULT_BOOT_OS_ID}    force=${TRUE}
        ${bootorder}=    Get BootOrder
        BootOrder Should Start With Bootnum    ${bootorder}    ${custom_bootnum}
    END

Set Password 5 Times
    [Documentation]    Sets the password 5 times to reset the password counter
    ...    and set a default password.
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
    VAR    @{password1}=    m    j    u    7    ^    Y    H    E
    VAR    @{password2}=    n    h    y    6    %    T    G    B
    VAR    @{password3}=    b    g    t    5    $    R    F    V
    VAR    @{password4}=    v    f    r    4    *    E    D    C
    VAR    @{password5}=    x    s    w    2    !    Q    A    Z
    VAR    @{passwords}=    ${password1}    ${password2}    ${password3}    ${password4}    ${password5}
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

Turn Off Password Functionality
    [Documentation]    Resets the Setup Password if it's set.
    Power On
    Enter Setup Menu Tianocore
    Sleep    1s
    ${output}=    Read From Terminal
    IF    "Please input admin password" not in """${output}"""    RETURN
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

CMOS003 Teardown
    [Documentation]    Cleans up password state in UEFI menu
    IF    ${TESTS_IN_FIRMWARE_SUPPORT}
        Turn Off Password Functionality
    ELSE
        IF    '${TEST_STATUS}' != 'FAIL'
            Execute Manual Step    Power on DUT
            Execute Manual Step
            ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
            Execute Manual Step    Enter the admin password you set earlier in this test
            Execute Manual Step    Enter User Password Management
            Execute Manual Step    Change admin password to blank, to remove password protection
            Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
        END
        Execute Manual Step    Boot into Ubuntu
    END
    Restore Boot Order After CMOS Clear
