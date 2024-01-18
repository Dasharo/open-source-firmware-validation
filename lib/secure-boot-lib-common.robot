*** Settings ***
Documentation       Collection of common keywords related to UEFI Secure Boot

Resource            ../keywords.robot


*** Variables ***
${GOOD_KEYS_URL}=           https://cloud.3mdeb.com/index.php/s/cCNPbraZnTyoTai/download/GOOD_KEYS-2.img
${GOOD_KEYS_NAME}=          GOOD_KEYS-2.img
${GOOD_KEYS_SHA256}=        7573b97d3ae47755cffe43d80dfd447c6e163029f8ce26caafcdc5395e217fbd
${GOOD_KEYS_VOLUME}=        GOOD_KEYS
${NOT_SIGNED_URL}=          https://cloud.3mdeb.com/index.php/s/HFmo5XLQ4C2DBWE/download/NOT_SIGNED-2.img
${NOT_SIGNED_NAME}=         NOT_SIGNED-2.img
${NOT_SIGNED_SHA256}=       c8091ffba4bc94388e8813bf8b589766cdaa5255405942ba4ee6a32511ede729
${NOT_SIGNED_VOLUME}=       NOT_SIGNED
${BAD_KEYS_URL}=            https://cloud.3mdeb.com/index.php/s/Ae6f56C7jc9tntG/download/BAD_KEYS-2.img
${BAD_KEYS_NAME}=           BAD_KEYS-2.img
${BAD_KEYS_SHA256}=         1601928db6f7f51e074fd22a0fb9cc7f5c95199e8268cc80be6e40e8c4ffecda
${BAD_KEYS_VOLUME}=         BAD_KEYS
${BAD_FORMAT_URL}=          https://cloud.3mdeb.com/index.php/s/AsBnATiHTZQ6jae/download/bad_format.img
${BAD_FORMAT_NAME}=         bad_format.img
${BAD_FORMAT_SHA256}=       59d17bc120dfd0f2e6948a2bfdbdf5fb06eddcb44f9a053a8e7b8f677e21858c
${BAD_FORMAT_VOLUME}=       BAD_FORMAT_VOLUME
${INTERMEDIATE_URL}=        https://cloud.3mdeb.com/index.php/s/LSQ7NAJyEGbnRNk/download/intermediate_db.img
${INTERMEDIATE_NAME}=       intermediate_db.img
${INTERMEDIATE_SHA256}=     5261340f3de5c3e70a11273c9bb94a3d01cb34302504982ba7ac179be0de4439
${INTERMEDIATE_VOLUME}=     Unknown
${RSA2_K_TEST_NAME}=        hello_rsa2k_test.img
${RSA2_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/85KSa7EFaMtnJQS/download/hello_rsa2k_test.img
${RSA2_K_TEST_SHA256}=      5007aa3051c847eca519d31e3446951012520e103b12deaee7daf29a10354ed4
${RSA2_K_TEST_VOLUME}=      RSA2K_LABEL
${RSA3_K_TEST_NAME}=        hello_rsa3k_test.img
${RSA3_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/7pwazGCojdeWDMX/download/hello_rsa3k_test.img
${RSA3_K_TEST_SHA256}=      7f62edb71d2567ce7fcd009c274bd012bf8b60a9072a9470e11fc6d9966359d9
${RSA3_K_TEST_VOLUME}=      RSA3K_LABEL
${RSA4_K_TEST_NAME}=        hello_rsa4k_test.img
${RSA4_K_TEST_URL}=         https://cloud.3mdeb.com/index.php/s/gD54FSWfrYqr2Gz/download/hello_rsa4k_test.img
${RSA4_K_TEST_SHA256}=      abab541a7c676b40a2a1d58d22d5fe4c6a236b83c1e833d5bfd18a03b7664026
${RSA4_K_TEST_VOLUME}=      RSA4K_LABEL
${ECDSA256_TEST_NAME}=      hello_ecdsa256_test.img
${ECDSA256_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/aBmETzTJGeGNg3t/download/hello_ecdsa256_test.img
${ECDSA256_TEST_SHA256}=    979f8b24cb09f6e10a71f736799340dc16a081a6e4a6d009ca65e0cebeb890bd
${ECDSA256_TEST_VOLUME}=    ECDSA256_L
${ECDSA384_TEST_NAME}=      hello_ecdsa384_test.img
${ECDSA384_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/dcmckksf2qx9AoD/download/hello_ecdsa384_test.img
${ECDSA384_TEST_SHA256}=    181c1e9f8051f80677f489aec9ac11ce311bb2a1f6ee6a659d7ae7ca2fbc1bf4
${ECDSA384_TEST_VOLUME}=    ECDSA384_L
${ECDSA521_TEST_NAME}=      hello_ecdsa521_test.img
${ECDSA521_TEST_URL}=       https://cloud.3mdeb.com/index.php/s/cmybRxzmKx2dATW/download/hello_ecdsa521_test.img
${ECDSA521_TEST_SHA256}=    cbd90c85b6d4c0c59f45da600c8b63e70b858330b2a27924253e6bf014906240
${ECDSA521_TEST_VOLUME}=    ECDSA521_L
${EXPIRED_URL}=             https://cloud.3mdeb.com/index.php/s/ReBEXy9yXTGWGyb/download/expired_cert.img
${EXPIRED_NAME}=            expired_cert.img
${EXPIRED_SHA256}=          831c4f0ec9bf4e40a80e15deb16d76a60524e91bd9e9ebe07847e1ea7021079a
${EXPIRED_VOLUME}=          Unknown


*** Keywords ***
Check Secure Boot In Linux
    [Documentation]    Keyword checks Secure Boot state in Linux.
    ...    Returns True when Secure Boot is enabled
    ...    and False when disabled.
    ${out}=    Execute Linux Command    dmesg | grep secureboot
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
