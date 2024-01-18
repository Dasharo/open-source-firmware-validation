*** Settings ***
Documentation       Collection of common keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Keywords ***
Check Secure Boot In Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    # The string in dmesg may be in two forms:
    # secureboot: Secure boot disabled
    # or just:
    # Secure boot disabled
    ${out}=    Execute Command In Terminal    dmesg | grep "Secure boot"
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
