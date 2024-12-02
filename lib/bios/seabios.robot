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

Set Option State And Return Construction
    [Documentation]    Sets option to desired state and return construction.
    [Arguments]    ${menu}    ${option}    ${desired_state}
    ${current_state}=    Get Option State    ${menu}    ${option}

    IF    '${current_state}' == '${desired_state}'
        RETURN    ${menu}
    ELSE
        ${menu}=    Enter Menu From Snapshot And Return Sortbootorder Construction    ${menu}    ${option}
    END
    RETURN    ${menu}

Get Index Of Matching Option In Menu
    [Documentation]    This keyword returns the index of element that matches
    ...    one in given menu
    [Arguments]    ${menu_construction}    ${option}    ${ignore_not_found_error}=${FALSE}
    FOR    ${element}    IN    @{menu_construction}
        ${matches}=    Run Keyword And Return Status
        ...    Should Match    ${element}    *${option}*
        IF    ${matches}
            ${option}=    Set Variable    ${element}
            BREAK
        END
    END
    ${index}=    Get Index From List    ${menu_construction}    ${option}
    IF    ${ignore_not_found_error} == ${FALSE}
        Should Be True    ${index} >= 0    Option ${option} not found in the list
    END
    RETURN    ${index}

Enter Menu From Snapshot
    [Documentation]    Enter given Menu option
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}

Enter Menu From Snapshot And Return Sortbootorder Construction
    [Documentation]    Enter given sortbootorder Menu option and return construction
    [Arguments]    ${menu}    ${option}
    ${key}=    Extract Sortbootorder Menu Key    ${menu}    ${option}
    Write Bare Into Terminal    ${key}
    ${menu}=    Get Menu Construction    Save configuration and exit    7    0
    RETURN    ${menu}

Extract Menu Key
    [Documentation]    Extract key which should be hit to enter given Menu in SeaBIOS
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

Extract Sortbootorder Menu Key
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

Save Sortbootorder Changes
    [Documentation]    This keyword saves introduced changes
    Write Bare Into Terminal    s

Enable Network/PXE Boot
    [Documentation]    Enable Network/PXE Boot and save.
    Enter Setup Menu
    ${menu}=    Get Menu Construction    Save configuration and exit    7    0
    ${menu}=    Set Option State And Return Construction    ${menu}    Network/PXE boot    Enabled
    List Should Contain Value    ${menu}    n Network/PXE boot - Currently Enabled
    Save Sortbootorder Changes

Enter TPM Configuration
    [Documentation]    Enter TPM Configuration with Boot Menu Construction.
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    Enter Menu From Snapshot    ${menu}    TPM Configuration

Enter IPXE
    [Documentation]    Enter iPXE with Boot Menu Construction.
    Enable Network/PXE Boot
    Enter Boot Menu
    ${menu}=    Get Boot Menu Construction
    Enter Menu From Snapshot    ${menu}    iPXE
