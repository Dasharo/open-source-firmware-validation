*** Settings ***
Library     OperatingSystem
Library     String


*** Keywords ***
Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_flushcontext -t
    Execute Linux Tpm2 Tools Command    tpm2_flushcontext -l
    Execute Linux Tpm2 Tools Command    tpm2_flushcontext -s

Check Which TPM2 Banks Are Enabled
    [Documentation]    Checks which Bank is enabled, returns tuple (bool, bool)
    ${out}=    Execute Linux Command    tpm2_getcap pcrs
    ${sha1}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${out}
    ...    sha1: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    ${sha256}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${out}
    ...    sha256: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
    RETURN    ${sha1}    ${sha256}

Check If SHA1 And SHA256 Banks Are Enabled
    ${sha1}    ${sha256}=    Check Which TPM2 Banks Are Enabled
    Should Be True    ${sha1}
    Should Be True    ${sha256}

Check TPM2 Banks State After FW Changes
    [Documentation]    Verifies the state of TPM Banks. Fails test if they are different than input.
    [Arguments]    ${sha1_desired}    ${sha256_desired}
    Save Changes And Reset
    Read From Terminal Until    Press F12 to change the boot measurements to use PCR bank(s) of the TPM
    Press Key N Times    1    ${F12}
    Prepare TPM Test On Linux
    ${sha1}    ${sha256}=    Check Which TPM2 Banks Are Enabled
    Should Be Equal    ${sha1}    ${sha1_desired}
    Should Be Equal    ${sha256}    ${sha256_desired}
