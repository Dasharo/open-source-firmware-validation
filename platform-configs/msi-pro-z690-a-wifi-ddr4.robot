*** Variables ***
# Basic communication variables
${dut_connection_method}                    pikvm
${payload}                                  tianocore
${rte_s2n_port}                             13541
${flash_size}                               ${32*1024*1024}
${tianocore_string}                         to boot directly
${boot_menu_key}                            ${F11}
${setup_menu_key}                           ${DELETE}
${USERNAME}                                 root
${PASSWORD}                                 meta-rte
${http_port}                                8000
${flash_verify_method}                      tianocore-setup-menu
${DTS_booting_default_method}               USB
${DTS_string}                               Dasharo Tools Suite

# Login to OS parameters
${username_ubuntu}                          user
${password_ubuntu}                          ubuntu
${prompt_ubuntu}                            user@user-MS-7D25:~$
${root_prompt_ubuntu}                       root@user-MS-7D25:/home/user#

# Regression flags
# Supported testing areas (firmware/OS)
${tests_in_firmware_support}                ${True}
${tests_in_ubuntu_support}                  ${True}

# Default flashing method
${default_flashing_method}                  external programmer

# Test module: Dasharo Compatibility
# Test suite: SMBIOS
${smbios_serial_number_verification}        ${True}
${smbios_firmware_version_verification}     ${True}
${smbios_product_name_verification}         ${True}
${smbios_release_date_verification}         ${True}
${smbios_manufacturer_verification}         ${True}
${smbios_vendor_verification}               ${True}
${smbios_family_verification}               ${True}
${smbios_firmware_type_verification}        ${True}
# Test suite: Dasharo Tools Suite
${DTS_support}                              ${True}
${DTS_firmware_flashing_support}            ${False}
${DTS_fwupd_firmware_update_support}        ${False}
${DTS_ec_flashing_support}                  ${False}
# Test suite: UEFI Shell
${uefi_shell_support}                       ${True}
# Test suite: CPU status
${cpu_tests_support}                        ${False}


# Test module: Dasharo Security

# Test module: Dasharo Performance

# Dasharo Performance counters


*** Keywords ***
Power On
    [Documentation]    Keyword allows to turn on the DUT - clears buffers and
    ...    sets the Device Under Test into Power On state using RTE OC buffers.
    ...    Implementation must be compatible with the theory of operation of a
    ...    specific platform.
    Sleep    2s
    RteCtrl Power Off    ${rte_session_handler}
    Sleep    10s
    Telnet.Read
    RteCtrl Power On    ${rte_session_handler}

Read firmware with internal programmer
    [Documentation]    Keyword allows to read the firmware based on the internal
    ...    programmer - flashrom - installed in the Operating System.
    No operation

Read firmware with external programmer
    [Documentation]    Keyword allows to read the firmware based on external
    ...    programmer. Implementation must be compatible with the theory of
    ...    operation of a specific platform.
    Power Cycle Off
    FOR    ${internation}    IN RANGE    0    5
        RteCtrl Power Off    ${rte_session_handler}
        Sleep    2s
    END
    RteCtrl Set OC GPIO    ${rte_session_handler}    2    high-z
    Sleep    2s
    RteCtrl Set OC GPIO    ${rte_session_handler}    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    ${rte_session_handler}    1    low
    Sleep    10s
    SSHLibrary.Execute Command    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -r /tmp/coreboot.rom 2>&1
    RteCtrl Set OC GPIO    ${rte_session_handler}    1    high-z
    RteCtrl Set OC GPIO    ${rte_session_handler}    3    high-z
    Sleep    2s
    Power Cycle On

Flash firmware with internal programmer
    [Documentation]    Keyword allows to flash the firmware to the DUT based
    ...    on the internal programmer - flashrom - installed in the Operating
    ...    System.
    No operation

Flash firmware with external programmer
    [Documentation]    Keyword allows to flash firmware to the DUT based on the
    ...    external programmer. Implementation must be compatible with the
    ...    theory of operation of a specific platform.
    [Arguments]    ${fw_file}
    Put file    ${fw_file}    /tmp/coreboot.rom
    Sleep    2s
    Power Cycle Off
    FOR    ${internation}    IN RANGE    0    5
        RteCtrl Power Off    ${rte_session_handler}
        Sleep    2s
    END
    RteCtrl Set OC GPIO    ${rte_session_handler}    2    high-z
    Sleep    2s
    RteCtrl Set OC GPIO    ${rte_session_handler}    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    ${rte_session_handler}    1    low
    Sleep    10s
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 --layout msi_z690a.layout -i bios -w /tmp/coreboot.rom 2>&1
    ...    return_rc=True
    RteCtrl Set OC GPIO    ${rte_session_handler}    1    high-z
    Sleep    2s
    RteCtrl Set OC GPIO    ${rte_session_handler}    3    high-z
    Sleep    2s
    Power Cycle On
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
