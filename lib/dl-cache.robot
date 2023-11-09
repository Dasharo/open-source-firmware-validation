*** Settings ***
Documentation       Collection of keywords for downloading local files

Resource            ../keywords.robot


*** Variables ***
${DL_CACHE_DIR}=    ${CURDIR}/../dl-cache


*** Keywords ***
Download To Host Cache
    [Arguments]    ${local_file_name}    ${url}    ${sha256sum}
    ${local_path}=    Join Path    ${DL_CACHE_DIR}    ${local_file_name}
    ${file_exists}=    Run Keyword And Return Status
    ...    Should Exist    ${local_path}
    IF    ${file_exists}
        ${calculated_sha256sum}=    Calculate Sha256 Sum    ${local_path}
        IF    '${sha256sum}' == '${calculated_sha256sum}'
            Log    File ${local_file_name} already exists in dl-cache
            RETURN
        END
    END
    Log    Downloading ${url} ...
    ${wget_rc}=    Run And Return RC    wget -O ${local_path} ${url}
    IF    ${wget_rc} != 0
        Fail    Download failed with exit code: ${wget_rc}
    END

Calculate SHA256 Sum
    [Arguments]    ${file_path}
    ${out}=    Run    sha256sum ${file_path}
    ${out_splitted}=    Split String    ${out}
    ${sha256sum}=    Get From List    ${out_splitted}    0
    RETURN    ${sha256sum}
