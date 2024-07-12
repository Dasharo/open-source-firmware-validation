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
Resource            ../keys.robot
Resource            ../lib/tpm.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Measured Boot Suite Setup
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${PCRS_TO_CHECK}=       [0-79]|14


*** Test Cases ***
MBO001.001 Measured Boot support
    [Documentation]    Check whether Measured Boot is functional and
    ...    measurements are stored into the TPM.
    ${pcr_hashes}=    Get PCRs State From Linux    [0-3]
    FOR    ${pcr_hash}    IN    @{pcr_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${unique_values_str}=    Evaluate    ''.join(set("${hash}"))
        Should Not Be Equal    ${unique_values_str}    F    ignore_case=${TRUE}
        Should Not Be Equal    ${unique_values_str}    0    ignore_case=${TRUE}
    END

MBO002.001 Check if event log PCRs match actual values
    [Documentation]    Check whether PCRs values calculated from event log match
    ...    actual PCRs values
    Validate PCRs Against Event Log    /sys/kernel/security/tpm0/binary_bios_measurements

MBO003.001 Changing Secure Boot certificate changes only PCR-7
    [Documentation]    Check if changes to Secure Boot certificates influence
    ...    PCR-7 value and only PCR-7
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${SECURE_BOOT_SUPPORT}    Secure Boot tests are not supported
    Restore Secure Boot Defaults
    ${sb_menu}=    Reenter Menu And Return Construction
    Disable Secure Boot    ${sb_menu}
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    ${default_hashes}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}

    Power On
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${sb_menu}=    Enter Advanced Secure Boot Keys Management And Return Construction    ${sb_menu}
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction    ${sb_menu}    DBX Options
    ${sb_menu}=    Enter Submenu From Snapshot And Return Construction    ${sb_menu}    Delete Signature
    Enter Submenu From Snapshot    ${sb_menu}    Delete All Signature List
    Read From Terminal Until    Press 'Y' to delete signature list
    Write Into Terminal    Y
    Sleep    1s
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{default_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        IF    '/7' in '${pcr}'
            Should Not Be Equal    ${hash}    ${new_hash}
        ELSE
            Should Be Equal    ${hash}    ${new_hash}
        END
    END

MBO004.001 Changing Dasharo network boot settings changes only PCR-1
    [Documentation]    Check if changes to Dasharo security settings influence PCR-1
    ...    value and only PCR-1
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT}    Tests in Dasharo Networking Menu are not supported
    Power On
    Boot Ubuntu And Login To Root
    @{hashes_before_changes}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}

    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Dasharo System Features    ${menu}
    ${menu}=    Enter Dasharo Submenu    ${menu}    Networking Options
    ${network_boot_state}=    Get Option State    ${menu}    Enable network boot
    ${new_network_boot_state}=    Evaluate    not ${network_boot_state}
    Set Option State    ${menu}    Enable network boot    ${new_network_boot_state}
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{hashes_before_changes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        IF    ${{'${pcr}'.endswith('/1')}}
            Should Not Be Equal    ${hash}    ${new_hash}
        ELSE
            Should Be Equal    ${hash}    ${new_hash}
        END
    END

MBO004.002 Changing Dasharo USB settings changes only PCR-1
    [Documentation]    Check if changes to Dasharo USB settings influence PCR-1
    ...    value and only PCR-1
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${USB_MASS_STORAGE_SUPPORT}    Tests in Dasharo USB Menu are not supported
    Power On
    Boot Ubuntu And Login To Root
    @{hashes_before_changes}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}

    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Dasharo System Features    ${menu}
    ${menu}=    Enter Dasharo Submenu    ${menu}    USB Configuration
    ${usb_storage_state}=    Get Option State    ${menu}    Enable USB Mass Storage
    ${new_usb_storage_state}=    Evaluate    not ${usb_storage_state}
    Set Option State    ${menu}    Enable USB Mass Storage    ${new_usb_storage_state}
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{hashes_before_changes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        IF    ${{'${pcr}'.endswith('/1')}}
            Should Not Be Equal    ${hash}    ${new_hash}
        ELSE
            Should Be Equal    ${hash}    ${new_hash}
        END
    END

MBO004.003 Changing Dasharo APU settings changes only PCR-1
    [Documentation]    Check if changes to Dasharo APU settings influence PCR-1
    ...    value and only PCR-1
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${APU_CONFIGURATION_MENU_SUPPORT}    Tests in Dasharo APU Menu are not supported
    Power On
    Boot Ubuntu And Login To Root
    @{hashes_before_changes}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}

    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Dasharo APU Configuration    ${menu}
    ${core_boost_state}=    Get Option State    ${menu}    Core Performance Boost
    ${new_core_boost_state}=    Evaluate    not ${core_boost_state}
    Set Option State    ${menu}    Core Performance Boost    ${new_core_boost_state}
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{hashes_before_changes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        IF    ${{'${pcr}'.endswith('/1')}}
            Should Not Be Equal    ${hash}    ${new_hash}
        ELSE
            Should Be Equal    ${hash}    ${new_hash}
        END
    END

MBO005.001 Flashing firmware and reset to defaults results in same measurement
    [Documentation]    Reset to defaults results in the same measurements as the
    ...    one done after flashing
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    Tests with "Reset to defaults" are not supported
    ${fw}=    Get Variable Value    $FW_FILE    ${EMPTY}
    Skip If    "${fw}" == "${EMPTY}"    No firmware to flash
    Flash Firmware    ${FW_FILE}

    Power Cycle On
    Boot Ubuntu And Login To Root
    ${default_pcr_state}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}

    Restore SB And Tianocore Defaults And Reset

    Boot Ubuntu And Login To Root
    ${reset_pcr_state}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}
    Lists Should Be Equal    ${default_pcr_state}    ${reset_pcr_state}

MBO005.002 Multiple reset to defaults results in identical measurements
    [Documentation]    Resetting Dasharo configuration twice will give the same
    ...    PCRs measurements
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    Tests with "Reset to defaults" are not supported
    ${default_hashes}=    Get Default PCRs State

    Restore SB And Tianocore Defaults And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{default_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        Should Be Equal    ${hash}    ${new_hash}
    END

MBO006.001 Identical configuration results in identical measurements
    [Documentation]    Check if same configuration state results in same PCR
    ...    values regardless how this state was achieved
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT} and not ${USB_MASS_STORAGE_SUPPORT}
    ...    Platform doesn't support neither Networking or USB menu tests
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    Tests with "Reset to defaults" are not supported
    ${default_hashes}=    Get Default PCRs State

    Restore SB And Tianocore Defaults And Reset

    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Dasharo System Features    ${menu}
    IF    ${USB_MASS_STORAGE_SUPPORT}
        ${menu}=    Enter Dasharo Submenu    ${menu}    USB Configuration
        ${option}=    Set Variable    Enable USB Mass Storage
    ELSE
        ${menu}=    Enter Dasharo Submenu    ${menu}    Networking Options
        ${option}=    Set Variable    Enable network boot
    END
    ${option_state}=    Get Option State    ${menu}    ${option}
    ${new_option_state}=    Evaluate    not ${option_state}
    Set Option State    ${menu}    ${option}    ${new_option_state}
    Save Changes
    ${menu}=    Reenter Menu And Return Construction
    Set Option State    ${menu}    ${option}    ${option_state}
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{default_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        Should Be Equal    ${hash}    ${new_hash}
    END

MBO006.002 Identical configuration after reset results in identical measurements
    [Documentation]    Check if same configuration state achieved by resetting
    ...    state to default results in same PCR values
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    Tests in firmware are not supported
    Skip If    not ${DASHARO_NETWORKING_MENU_SUPPORT} and not ${USB_MASS_STORAGE_SUPPORT}
    ...    Platform supports neither Networking nor USB menu tests
    Skip If    not ${RESET_TO_DEFAULTS_SUPPORT}    Tests with "Reset to defaults" are not supported
    ${default_hashes}=    Get Default PCRs State

    Restore SB And Tianocore Defaults And Reset

    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${menu}=    Enter Dasharo System Features    ${menu}
    IF    ${USB_MASS_STORAGE_SUPPORT}
        ${menu}=    Enter Dasharo Submenu    ${menu}    USB Configuration
        ${option}=    Set Variable    Enable USB Mass Storage
    ELSE
        ${menu}=    Enter Dasharo Submenu    ${menu}    Networking Options
        ${option}=    Set Variable    Enable network boot
    END
    ${option_state}=    Get Option State    ${menu}    ${option}
    ${new_option_state}=    Evaluate    not ${option_state}
    Set Option State    ${menu}    ${option}    ${new_option_state}
    Save Changes
    Reset To Defaults Tianocore
    Save Changes And Reset

    Boot Ubuntu And Login To Root
    FOR    ${pcr_hash}    IN    @{default_hashes}
        ${pcr}    ${hash}=    Split String    ${pcr_hash}    separator=:
        ${new_hash}=    Execute Command In Terminal    cat ${pcr}
        Should Be Equal    ${hash}    ${new_hash}
    END


*** Keywords ***
Get Default PCRs State
    [Documentation]    First time this keyword is called it resets platform
    ...    configuration to default and then returns PCRs values. Next call
    ...    return values measured in first call (remembers value in whole
    ...    Test Suite).
    ${default_pcr_state}=    Get Variable Value    $DEFAULT_PCR_STATE_SUITE
    IF    ${default_pcr_state} is ${NONE}
        Restore SB And Tianocore Defaults And Reset
        Boot Ubuntu And Login To Root
        ${default_pcr_state}=    Get PCRs State From Linux    ${PCRS_TO_CHECK}
        Set Suite Variable    $DEFAULT_PCR_STATE_SUITE    ${default_pcr_state}
    END
    RETURN    ${default_pcr_state}

Boot Ubuntu And Login To Root
    [Documentation]    Boots Ubuntu and logins as root
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User

Restore SB And Tianocore Defaults And Reset
    [Documentation]    Restores Secure Boot and Tianocore to defaults and then
    ...    restarts
    Restore Secure Boot Defaults
    Reset To Defaults Tianocore
    Save Changes And Reset

Measured Boot Suite Setup
    Prepare Test Suite
    Skip If    not ${MEASURED_BOOT_SUPPORT}    Measured boot is not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    Tests in Ubuntu are not supported
    Power On
    Boot Ubuntu And Login To Root
    Detect Or Install Package    tpm2-tools
    # Disable service that adds dbx certificates which could interfere with tests
    Execute Command In Terminal    systemctl disable secureboot-db.service
