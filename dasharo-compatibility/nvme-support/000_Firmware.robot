*** Settings ***
Resource            common.resource

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         NVM Suite Setup
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NVM001.001 NVMe support in firmware
    [Documentation]    Check whether the firmware is able to correctly detect
    ...    NVMe disk in M.2 slot.
    Depends On    ${NVME_DISK_SUPPORT}
    Depends On    ${TESTS_IN_FIRMWARE_SUPPORT}
    Power On
    ${out}=    Enter Boot Menu Tianocore And Return Construction
    ${ssd_list}=    Get Current CONFIG List Element    Storage_SSD
    ${ssd_list_length}=    Get Length    ${ssd_list}
    IF    ${ssd_list_length} == 0    Fail    No SSD disks connected
    FOR    ${disk}    IN    @{ssd_list}
        IF    '${disk.interface}' == 'NVME'
            ${found}=    Evaluate    '${disk.boot_name}' in ${out}
            IF    ${found}    BREAK
        END
    END
    Should Be True    ${found}    None of the connected disks is visible in boot menu
