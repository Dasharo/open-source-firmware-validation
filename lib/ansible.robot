*** Settings ***
Library     OperatingSystem


*** Keywords ***
Run Ansible Playbook On Supported Operating Systems
    [Documentation]    This keyword boots supported operating systems on DUT and
    ...    run ansible-playbook on them using SSH to prepare DUT for given Test
    ...    Suite.
    # TODO: run different playbooks for different OSes
    # TODO2: test on other platforms, for now only can be executed in QEMU
    # TODO3: how we should manage ansible-roles/hosts files in cases with real
    # hardware
    IF    '${ANSIBLE_CONFIG}' != 'yes'
        Log    ANSIBLE_CONFIG not set to `Yes`, skipping configuration...    INFO
    ELSE
        IF    '${CONFIG}' == 'qemu'
            ${ip_address}=    Set Variable    127.0.0.1
        ELSE
            ${ip_address}=    Get Hostname Ip
        END
        IF    '${CONFIG}' == 'qemu'
            IF    '${TESTS_IN_UBUNTU_SUPPORT}' == '${TRUE}'
                Power On
                Boot System Or From Connected Disk    ubuntu
                Login To Linux
                ${rc}    ${output}=    Run And Return RC And Output
                ...    sh -c 'ansible-playbook
                ...    --extra-vars "ansible_become_password=${UBUNTU_PASSWORD}"
                ...    -i ${CURDIR}${/}..${/}ansible-roles/hosts
                ...    ${CURDIR}${/}..${/}ansible-roles/os/ubuntu/test.yml'
                Should Be Equal As Integers    ${rc}    0
                Should Not Contain    ${output}    FAIL
            END
        ELSE
            Log    This keyword works only on QEMU...    INFO
        END
    END
