*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=390 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         TPM2 Suite Setup
Suite Teardown      Log Out And Close Connection
Test Setup          Flush TPM Contexts


*** Test Cases ***
TPMCMD001.001 Check if both SHA1 and SHA256 PCRs are enabled (Ubuntu)
    [Documentation]    This test aims to verify that `PCRALLOCATE` function
    ...    works properly. It allows the user to specify a PCR
    ...    allocation for the TPM.
    Skip If    ${SHA1_ENABLED} != ${SHA256_ENABLED}    Only one bank is enabled
    Should Be True    ${SHA1_ENABLED}
    Should Be True    ${SHA256_ENABLED}

TPMCMD002.001 PCRREAD Function Verification (Ubuntu)
    [Documentation]    This test aims to verify that PCRREAD function works
    ...    properly. Function reads contains of PCR banks and
    ...    returns it to the terminal.
    Skip If    not ${SHA1_ENABLED} and not ${SHA256_ENABLED}    No PCR banks enabled
    ${out}=    Execute Linux Command    tpm2_pcrread
    Should Contain    ${out}    sha1:
    Should Contain    ${out}    sha256:
    Should Contain    ${out}    0x0000000000000000000000000000000000000000
    Should Contain    ${out}    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

TPMCMD003.001 PCREXTEND And PCRRESET Functions (Ubuntu)
    [Documentation]    This test aims to verify that PCREXTEND and PCRRESET
    ...    functions are working properly.
    Skip If    not ${SHA1_ENABLED} and not ${SHA256_ENABLED}    No PCR banks enabled
    ${sha1}=    Set Variable    f1d2d2f924e986ac86fdf7b36c94bcdf32beec15
    ${sha256}=    Set Variable    b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c
    ${sha1_0s}=    Evaluate    "0" * 40
    ${sha256_0s}=    Evaluate    "0" * 64
    Execute Linux Command    tpm2_pcrreset 23
    ${out1}=    Execute Linux Command    tpm2_pcrread
    Execute Linux Command    tpm2_pcrextend 23:sha1=${sha1},sha256=${sha256}
    ${out2}=    Execute Linux Command    tpm2_pcrread
    Execute Linux Command    tpm2_pcrreset 23
    ${out3}=    Execute Linux Command    tpm2_pcrread
    # Append shasum to default PCR value of all 0s
    ${sha1}=    Evaluate    "0" * 40 + "${sha1}"
    ${sha256}=    Evaluate    "0" * 64 + "${sha256}"
    # Calculate shasum of result
    ${sha1}=    Execute Linux Command    echo -n ${sha1} | xxd -r -p | sha1sum
    ${sha1}=    Set Variable    ${sha1.split()}[0]
    ${sha256}=    Execute Linux Command    echo -n ${sha256} | xxd -r -p | sha256sum
    ${sha256}=    Set Variable    ${sha256.split()}[0]
    # Compare with PCR values reported by TPM
    IF    ${SHA1_ENABLED}
        Should Contain    ${out1}    23: 0x${sha1_0s}
        Should Contain    ${out2}    23: 0x${sha1.upper()}
        Should Contain    ${out3}    23: 0x${sha1_0s}
    END
    IF    ${SHA256_ENABLED}
        Should Contain    ${out1}    23: 0x${sha256_0s}
        Should Contain    ${out2}    23: 0x${sha256.upper()}
        Should Contain    ${out3}    23: 0x${sha256_0s}
    END

TPMCMD003.002 PCREXTEND And PCRRESET Functions - locality protections (Ubuntu)
    [Documentation]    This test aims to verify that PCREXTEND and PCRRESET
    ...    functions are working properly when trying to modify protected PCRs.
    Skip If    not ${SHA1_ENABLED} and not ${SHA256_ENABLED}    No PCR banks enabled
    ${sha1}=    Generate Random String    40    [NUMBERS]abcdef
    ${sha256}=    Generate Random String    64    [NUMBERS]abcdef
    ${out1}=    Execute Linux Command    tpm2_pcrreset 18
    ${out2}=    Execute Linux Command    tpm2_pcrextend 18:sha1=${sha1},sha256=${sha256}
    ${out3}=    Execute Linux Command    tpm2_pcrread
    Should Contain    ${out1}    tpm:warn(2.0): bad locality
    Should Contain    ${out2}    tpm:warn(2.0): bad locality
    Should Contain    ${out3}    18: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

TPMCMD004.001 PCREVENT Function (Ubuntu)
    [Documentation]    This test aims to verify that PCREVENT function is
    ...    working properly.
    Skip If    not ${SHA1_ENABLED} and not ${SHA256_ENABLED}    No PCR banks enabled
    Execute Linux Command    tpm2_pcrreset 23
    ${out}=    Execute Linux Command    tpm2_pcrread
    ${sha1}=    Evaluate    "0" * 40
    ${sha256}=    Evaluate    "0" * 64
    IF    ${SHA1_ENABLED}    Should Contain    ${out}    23: 0x${sha1}
    IF    ${SHA256_ENABLED}    Should Contain    ${out}    23: 0x${sha256}
    Execute Linux Command    echo "foo" > data
    ${out}=    Execute Linux Command    tpm2_pcrevent 23 data
    # Calculate file shasums and compare with result of tpm2_pcrevent
    ${sha1}=    Execute Linux Command    sha1sum data
    ${sha1}=    Set Variable    ${sha1.split()}[0]
    ${sha256}=    Execute Linux Command    sha256sum data
    ${sha256}=    Set Variable    ${sha256.split()}[0]
    Execute Linux Command    rm -f data
    IF    ${SHA1_ENABLED}    Should Contain    ${out}    sha1: ${sha1}
    IF    ${SHA256_ENABLED}    Should Contain    ${out}    sha256: ${sha256}
    # Append shasum to default PCR value of all 0s
    ${sha1}=    Evaluate    "0" * 40 + "${sha1}"
    ${sha256}=    Evaluate    "0" * 64 + "${sha256}"
    # Calculate shasum of result
    ${sha1}=    Execute Linux Command    echo -n ${sha1} | xxd -r -p | sha1sum
    ${sha1}=    Set Variable    ${sha1.split()}[0]
    ${sha256}=    Execute Linux Command    echo -n ${sha256} | xxd -r -p | sha256sum
    ${sha256}=    Set Variable    ${sha256.split()}[0]
    # Compare with PCR values reported by TPM
    ${out}=    Execute Linux Command    tpm2_pcrread
    IF    ${SHA1_ENABLED}    Should Contain    ${out}    23: 0x${sha1.upper()}
    IF    ${SHA256_ENABLED}
        Should Contain    ${out}    23: 0x${sha256.upper()}
    END

TPMCMD005.001 CREATEPRIMARY Function Verification (Ubuntu)
    [Documentation]    This test aims to verify that CREATEPRIMARY function
    ...    works as expected. This command is used to create a
    ...    primary object under one of the hierarchies: Owner,
    ...    Platform, Endorsement, NULL.
    ${out}=    Execute Linux Command    tpm2_createprimary -c primary.ctx    60
    Execute Linux Command    rm -f primary.ctx
    Should Contain    ${out}    value: sha256
    Should Contain    ${out}    value: fixedtpm|fixedparent|sensitivedataorigin|userwithauth|restricted|decrypt
    Should Contain    ${out}    bits: 2048

TPMCMD006.001 NVDEFINE and NVUNDEFINE Functions Verification (Ubuntu)
    [Documentation]    This test aims to verify that NVDEFINE and NVUNDEFINE
    ...    functions are working as expected. Those functions are
    ...    used to define and undefine a TPM Non-Volatile index.
    Execute Linux Command    tpm2_nvdefine -C o -s 32 -a "ownerread|policywrite|ownerwrite" 1
    Execute Linux Command    echo "nvtest" > nv.dat
    Execute Linux Command    tpm2_nvwrite -C o -i nv.dat 1
    # NV data is usually padded with 0xFF which Python doesn't like, change it to 0x00
    ${out1}=    Execute Linux Command    tpm2_nvread -C o -s 32 1 | tr '\\377' '\\000'
    Execute Linux Command    tpm2_nvundefine -C o 1
    ${out2}=    Execute Linux Command    tpm2_nvread -C o -s 32 1 2>&1
    Execute Linux Command    rm -f nv.dat
    Should Contain    ${out1}=    nvtest
    Should Contain    ${out2}=    ERROR: Unable to run tpm2_nvread

TPMCMD007.001 CREATE Function (Ubuntu)
    [Documentation]    This test aims to verify that CREATE function works as
    ...    expected. It will create an object using all the default
    ...    values and store the TPM sealed private and public
    ...    portions to the paths specified via `-u` and `-r`
    ...    respectively.
    Execute Linux Command    tpm2_createprimary -c primary.ctx    60
    ${out}=    Execute Linux Command    tpm2_create -C primary.ctx -u obj.pub -r obj.priv
    Execute Linux Command    rm -f primary.ctx obj.pub obj.priv
    Should Contain    ${out}    value: sha256
    Should Contain    ${out}    value: fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign
    Should Contain    ${out}    bits: 2048

TPMCMD007.002 CREATELOADED Function (Ubuntu)
    [Documentation]    This test aims to verify that CREATELOADED function works
    ...    as expected. It will create an object using all the
    ...    default values and store key context to the path
    ...    specified via `-c`.
    Execute Linux Command    tpm2_createprimary -c primary.ctx    60
    ${out}=    Execute Linux Command    tpm2_create -C primary.ctx -c obj.key
    Execute Linux Command    rm -f primary.ctx obj.key
    Should Contain    ${out}    value: sha256
    Should Contain    ${out}    value: fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign
    Should Contain    ${out}    bits: 2048

TPMCMD008.001 Signing the file (Ubuntu)
    [Documentation]    Check whether the TPM supports file signing.
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -c primary_key.ctx    60
    Execute Linux Tpm2 Tools Command    tpm2_create -u key.pub -r key.priv -C primary_key.ctx
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    echo "my secret" > secret.data
    Execute Linux Tpm2 Tools Command    tpm2_sign -c key.ctx -o sig.rssa secret.data
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_verifysignature -c key.ctx -s sig.rssa -m secret.data
    Execute Linux Command    rm -f primary_key.ctx key.pub key.priv key.ctx sig.rssa secret.data

TPMCMD009.001 Encryption and Decryption of the file (Ubuntu)
    [Documentation]    Check whether the TPM supports the encryption and
    ...    decryption of the file.
    ${out}=    Execute Linux Tpm2 Tools Command    tpm2_getcap commands
    ${passed}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    TPM2_EncryptDecrypt
    # At least one must be implemented, but both are caught by one test
    Skip If    not ${passed}    TPM doesn't supports TPM2_EncryptDecrypt nor TPM2_EncryptDecrypt2
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -c primary_key.ctx    60
    Execute Linux Tpm2 Tools Command    tpm2_create -u key.pub -r key.priv -C primary_key.ctx -Gaes128
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c key.ctx
    Execute Linux Command    echo "my secret" > secret.data
    # Avoid getting 'WARN: Using a weak IV, try specifying an IV'
    Execute Linux Command    dd if=/dev/zero bs=1 count=16 of=iv.bin
    Execute Linux Tpm2 Tools Command    tpm2_encryptdecrypt -c key.ctx -o secret.enc secret.data -t iv.bin
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_encryptdecrypt -d -c key.ctx -o secret.dec secret.enc -t iv.bin
    ${out}=    Execute Linux Command    cat secret.dec
    Execute Linux Command    rm -f primary_key.ctx key.pub key.priv key.ctx secret.enc secret.dec secret.data iv.bin
    Should Contain    ${out}    my secret

TPMCMD010.001 Hashing the file (Ubuntu)
    [Documentation]    Check whether the TPM supports file hashing.
    Execute Linux Command    echo "my secret" > secret.data
    Execute Linux Tpm2 Tools Command    tpm2_hash -o hash.out -t ticket.out secret.data
    ${out1}=    Execute Linux Command    ls
    ${out2}=    Execute Linux Command    find . -empty -name hash.out
    ${out3}=    Execute Linux Command    find . -empty -name ticket.out
    Execute Linux Command    rm -f hash.out ticket.out secret.data
    Should Contain    ${out1}    hash.out
    Should Contain    ${out1}    ticket.out
    Should Not Contain    ${out2}    hash.out
    Should Not Contain    ${out3}    ticket.out

TPMCMD011.001 Performing HMAC operation on the file (Ubuntu)
    [Documentation]    Check whether the TPM supports HMAC operation.
    Execute Linux Tpm2 Tools Command    tpm2_createprimary -c primary_key.ctx    60
    Execute Linux Tpm2 Tools Command    tpm2_create -u key.pub -r key.priv -C primary_key.ctx -G hmac
    Flush TPM Contexts
    Execute Linux Tpm2 Tools Command    tpm2_load -C primary_key.ctx -u key.pub -r key.priv -c hmac.key
    Execute Linux Command    echo "my secret" > secret.data
    Execute Linux Tpm2 Tools Command    tpm2_hmac -c hmac.key -o hmac.out secret.data
    ${out1}=    Execute Linux Command    ls
    ${out2}=    Execute Linux Command    find . -empty -name hmac.out
    Execute Linux Command    rm -f hmac.out hmac.key secret.data primary_key.ctx key.pub key.priv
    Should Contain    ${out1}    hmac.out
    Should Not Contain    ${out2}    hmac.out


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

TPM2 Suite Setup
    Prepare Test Suite
    Skip If    not ${TPM_SUPPORT}    TPM tests not supported
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    TPM commands tests supported only on Ubuntu
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Detect Or Install Package    tpm2-tools
    ${passed}=    Run Keyword And Return Status
    ...    Check If SHA1 And SHA256 Banks Are Enabled
    IF    not ${passed}
        # Restore default allocations in case any bank was disabled and reboot
        Execute Linux Command    tpm2_pcrallocate
        Execute Reboot Command
        Boot System Or From Connected Disk    ubuntu
        Login To Linux
        Switch To Root User
    END
    ${sha1_enabled}    ${sha256_enabled}=    Check Which TPM2 Banks Are Enabled
    Set Suite Variable    $SHA1_ENABLED    ${sha1_enabled}
    Set Suite Variable    $SHA256_ENABLED    ${sha256_enabled}
