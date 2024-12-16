*** Settings ***
Documentation       Collection of keywords related to SeaBIOS.

# Here is comparison of terms with lib/bios/edk2.robot
# Tianocore -> SeaBIOS
# Setup Menu -> sortbootorder
#
Library             Collections
Library             String
Resource            common.robot


*** Keywords ***
Get Boot Menu Construction
    [Documentation]    Keyword allows to get and return boot menu construction.
    ${menu}=    Read From Terminal Until    TPM Configuration
    # Lines to strip:
    # Select boot device:
    #
    # 1. DVD/CD [AHCI/2: QEMU DVD-ROM ATAPI-4 DVD/CD]
    # 2. iPXE
    # 3. Payload [setup]
    # 4. Payload [memtest]
    #
    # t. TPM Configuration
    ${construction}=    Parse Menu Snapshot Into Construction    ${menu}    1    0
    RETURN    ${construction}

Get Option State
    [Documentation]    Gets menu construction and option name as arguments.
    ...    Returns option state, which can be: True or False.
    [Arguments]    ${menu}    ${option}
    ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
    ${value}=    Get Regexp Matches    ${menu}[${index}]    (Enabled|Disabled)

    RETURN    ${value}[0]

Set Option State
    [Documentation]    Gets menu construction option name, and desired state
    ...    as arguments. Return TRUE if the option was changed and FALSE if
    ...    option was already in target state.
    [Arguments]    ${menu}    ${option}    ${target_state}
    ${current_state}=    Get Option State    ${menu}    ${option}
    IF    '${current_state}' != '${target_state}'
        ${menu}=    Enter Submenu From Snapshot    ${menu}    ${option}
        RETURN    ${TRUE}
    ELSE
        RETURN    ${FALSE}
    END

Enter Boot Menu From Snapshot
    [Documentation]    Enter given Menu option
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract Boot Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}

Enter Submenu From Snapshot
    [Documentation]    Enter given Menu option and return construction
    [Arguments]    ${menu}    ${option}
    IF    '${menu}[3]' == '${EDK2_IPXE_CHECKPOINT}'
        ${index}=    Get Index Of Matching Option In Menu    ${menu}    ${option}
        Should Not Be Equal As Integers    ${index}    -1    msg=Option ${option} not found in menu
        Press Key N Times And Enter    ${index}    ${ARROW_DOWN}
    ELSE
        ${key}=    Extract Menu Key    ${menu}    ${option}
        Write Bare Into Terminal    ${key}
    END

Extract Boot Menu Key
    [Documentation]    Extract boot menu which should be hit to enter given Menu in SeaBIOS
    [Arguments]    ${menu}    ${option}
    FOR    ${item}    IN    @{menu}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${item}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${item}
            BREAK
        END
    END
    ${key}=    Set Variable    ${option.split('.')[0]}
    RETURN    ${key}

Extract Menu Key
    [Documentation]    Extract key which should be hit to toggle given sortbootorder Menu option
    [Arguments]    ${menu}    ${option}
    FOR    ${item}    IN    @{menu}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${item}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${item}
            BREAK
        END
    END
    ${key}=    Set Variable    ${option.split()[0]}
    RETURN    ${key}

Save Changes
    [Documentation]    This keyword saves introduced changes
    Write Bare Into Terminal    s

Enable Network/PXE Boot
    [Documentation]    Enable Network/PXE Boot and save.
    Enter Setup Menu
    ${menu}=    Get Menu Construction    Save configuration and exit    7    0
    Set Option State    ${menu}    Network/PXE boot    Enabled
    Save Changes

Enter TPM Configuration
    [Documentation]    Enter TPM Configuration with Boot Menu Construction.
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    Enter Submenu From Snapshot    ${menu}    TPM Configuration

Enter IPXE
    [Documentation]    Enter iPXE with Boot Menu Construction.
    Enable Network/PXE Boot
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    Enter Submenu From Snapshot    ${menu}    iPXE

# robocop: disable=unused-argument

Select Boot Menu Option
    [Documentation]    Select the boot menu option using the given index.
    ...    Accounts for indices counting from zero, and SeaBIOS options counting
    ...    from '1.'. Has to take a dummy parameter for compatibility with the
    ...    EDK2 version of this keyword.
    [Arguments]    ${index}    ${dummy}
    ${option}=    Evaluate    ${index} + 1
    Write Bare Into Terminal    '${option}'
# robocop: disable=unused-argument
