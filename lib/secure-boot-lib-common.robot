*** Settings ***
Documentation       Collection of common keywords related to UEFI Secure Boot

Library             ../lib/secure-boot-lib-common.py
Resource            ../keywords.robot


*** Keywords ***
Check If Certificate Images For Tests Exists
    [Documentation]    This keyword checks if images used in UEFI Secure Boot
    ...    tests exists on host PC.
    ${images_list}=    Create List    BAD_FORMAT    BAD_KEYS    ECDSA256    ECDSA384
    ...    ECDSA521    EXPIRED    GOOD_KEYS    INTERMEDIATE    NOT_SIGNED
    ...    RSA2048    RSA3072    RSA4096
    FOR    ${image}    IN    @{images_list}
        ${image_path}=    Set Variable    ${CURDIR}/../scripts/secure-boot/images/${image}.img
        OperatingSystem.File Should Exist
        ...    ${image_path}
        ...    Image ${image}.img does not exist! Please run ./scripts/secure-boot/generate-images/sb-img-wrapper.sh script.
    END

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

Autoenroll Secure Boot Certificates
    [Documentation]    Enrolls Secure boot certificates automatically using tool
    ...    for automatic provisioning
    # 1. Erase Secure Boot Keys
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    ${key_menu}=    Enter Key Management And Return Construction    ${sb_menu}
    Erase All Secure Boot Keys    ${key_menu}
    Save Changes And Reset    3    5

    # 2. Boot to Automatic provisioning tool
    Boot Dasharo Tools Suite    USB    ${TRUE}

    # 3. Enable SB after provisioning
    ${sb_menu}=    Enter Secure Boot Menu And Return Construction
    Enable Secure Boot    ${sb_menu}
    Save Changes And Reset

Remove Old Secure Boot Keys In OS
    [Documentation]    Removes all files and directories in
    ...    `/usr/share/secureboot` which is used by sbctl in the operating
    ...    system
    ${out}=    Execute Command In Terminal    rm -rf /usr/share/secureboot

Generate Secure Boot Keys In OS
    [Documentation]    Generates new Secure Boot keys using sbctl.
    ...    Returns true if succeeded.
    ${out}=    Execute Command In Terminal    sbctl create-keys
    ${sb_status}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    Secure boot keys created!
    RETURN    ${sb_status}

Enroll Secure Boot Keys In OS
    [Documentation]    Enrolls current keys to EFI using sbctl.
    ...    Returns true if succeeded.
    [Arguments]    ${result}
    ${out}=    Execute Command In Terminal    sbctl enroll-keys --yes-this-might-brick-my-machine
    IF    ${result} == True
        ${sb_status}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    Enrolled keys to the EFI variables!
    ELSE
        ${sb_status}=    Run Keyword And Return Status
        ...    Should Contain    ${out}    failed to parse key
    END
    RETURN    ${sb_status}

Sign All Boot Components In OS
    [Documentation]    Signs boot components with current keys using sbctl
    ${cmd}=    Execute Command In Terminal
    ...    sbctl verify | awk -F ' ' '{print $2}' | tail -n+2 | xargs -I "#" sbctl sign "#"

Compare KEK Certificate Using Mokutil In DTS
    [Documentation]    Compares two KEK certificates. It takes as argument the
    ...    source of the certificate and acquire it. Second KEK certificate is
    ...    taken as an output from mokutil --kek command executed in DTS.
    [Arguments]    ${first_certificate}
    ${is_https_link}=    Run Keyword And Return Status    Should Contain    ${first_certificate}    https://
    IF    ${is_https_link} == ${TRUE}
        ${cmd}=    Execute Command In Terminal    wget ${first_certificate} -O /tmp/first_certificate.crt
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

Generate Wrong Format Keys And Move Them
    [Documentation]    Generates elliptic curve keys and moves them to the
    ...    desired location.
    [Arguments]    ${name}    ${location}
    ${cmd}=    Execute Command In Terminal
    ...    openssl ecparam -genkey -name secp384r1 -out ${name}.key && openssl req -new -x509 -key ${name}.key -out ${name}.pem -days 365 -subj "/CN=3mdeb_test"
    ${cmd}=    Execute Command In Terminal    mv ${name}.key ${location}
    ${cmd}=    Execute Command In Terminal    mv ${name}.pem ${location}
