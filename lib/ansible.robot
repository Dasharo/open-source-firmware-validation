*** Settings ***
Library     OperatingSystem


*** Keywords ***
Run Ansible Playbook On Supported Operating Systems
    [Documentation]    This keyword boots supported operating systems on DUT and
    ...    run ansible-playbook on them using SSH to prepare DUT for given Test
    ...    Suite. Argument ${ran_suite_name} should point to the suite setup
    ...    in which this KW will be executed.
    # TODO: run different playbooks for different OSes
    # TODO2: test on other platforms, for now only can be executed in QEMU
    # TODO3: how we should manage ansible-roles/hosts files in cases with real
    # hardware
    [Arguments]    ${ran_suite_name}
    IF    '${ANSIBLE_CONFIG}' != 'yes'
        Log    ANSIBLE_CONFIG not set to `Yes`, skipping configuration...    INFO
    ELSE
        IF    '${ANSIBLE_SUPPORT}' == '${TRUE}'
            IF    '${TESTS_IN_UBUNTU_SUPPORT}' == '${TRUE}'
                Power On
                Boot System Or From Connected Disk    ubuntu
                Login To Linux
                ${ansible_hosts}=    Set Variable    ${CURDIR}${/}..${/}ansible-roles${/}hosts
                ${ansible_role}=    Set Variable
                ...    ${CURDIR}${/}..${/}ansible-roles${/}roles${/}${ran_suite_name}${/}tasks${/}common.yml
                ${rc}    ${output}=    Run And Return RC And Output
                ...    sh -c 'ansible-playbook --extra-vars "ansible_become_password=${UBUNTU_PASSWORD}" -i ${ansible_hosts} ${ansible_role}'
                Should Be Equal As Integers    ${rc}    0
                Should Not Contain    ${output}    FAIL
                Switch To Root User
                Write Into Terminal    reboot
                Restore Initial DUT Connection Method
                Read From Terminal Until    System Reboot
            END
        ELSE
            Log    This keyword works only on QEMU...    INFO
        END
    END
