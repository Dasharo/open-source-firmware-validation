*** Settings ***
Resource            common.resource

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
...                     AND    Depends On    ${TESTS_IN_XCP_NG_SUPPORT}
...                     AND    Depends On    ${SATA_SUPPORT}
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SAT001.205 SATA support in OS (XCP-NG)
    [Documentation]    Verify SATA support via smartctl in XCP-NG.
    ...    Previous IDs: SAT001.010
    Power On
    Login To OS    ${ENV_ID_XCP_NG}

    ${lsblk_out}=    Execute Command In Terminal    lsblk -d -o NAME -n
    @{disks}=    Split String    ${lsblk_out}    \n
    VAR    ${sata_found}=    False

    FOR    ${disk}    IN    @{disks}
        ${out}=    Execute Command In Terminal    sudo smartctl -i /dev/${disk}
        Log    ${out}
        ${sata_present}=    Run Keyword And Return Status    Should Contain    ${out}    SATA
        IF    ${sata_present}
            VAR    ${sata_found}=    True
        END
    END

    IF    ${sata_found}    Pass Execution    SATA disk found, passing test
    Fail    No SATA disk was found, failing test
