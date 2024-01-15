*** Settings ***
Library     OperatingSystem


*** Keywords ***
Run Ansible Playbook On Supported Operating Systems
    [Documentation]    tmp
    IF    '${ANSIBLE_CONFIG}' != 'yes'
        Log    ANSIBLE_CONFIG not set to `Yes`, skipping configuration...    INFO
    ELSE
        IF    '${CONFIG}' == 'qemu'
            ${ip_address}=    Set Variable    127.0.0.1
        ELSE
            ${ip_address}=    Get Hostname Ip
        END
        IF    '${TESTS_IN_UBUNTU_SUPPORT}' == '${TRUE}'
            Power On
            Boot System Or From Connected Disk    ubuntu
            Login To Linux
            ${rc}    ${output}=    Run And Return RC And Output
            ...    sh -c "ansible-playbook -i ${CURDIR}${/}..${/}ansible-roles/hosts ${CURDIR}${/}..${/}ansible-roles/os/ubuntu/test.yml"
            Should Be Equal As Integers    ${rc}    0
            Should Not Contain    ${output}    FAIL
        END
    END
