*** Settings ***
Library         OperatingSystem

*** Variables ***
${CLONEZILLA_IPXE_SERVER}=      http://192.168.10.217:8080
${DISKS_NFS_IP}=                192.168.10.217
${DISKS_NFS_PATH}=              /srv/nfs/disk-images
${TIME_LIMIT}=                  40m


*** Keywords ***
Get Envvar
    [Arguments]    ${name}    ${optional}=${FALSE}
    ${status}=    Run Keyword And Return Status    Get Environment Variable    ${name}
    IF    not (${optional} or ${status})
        Log To Console    Environment variable ${name} must be set.
        Fail    Environment variable ${name} is not set
    ELSE IF    ${status}
        ${var}=    Get Environment Variable    ${name}
        RETURN    ${var}
    END
    RETURN    ${EMPTY}
