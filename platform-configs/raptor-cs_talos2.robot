*** Variables ***
${dut_connection_method}                            open-bmc
${payload}                                          petitboot
${flash_size}                                       ${64*1024*1024}
${manufacturer}                                     Raptor Engineering, LLC
${cpu}                                              IBM POWER9 v2 CPU (4-Core) CP9M31
${dram_size}                                        ${8192}
${def_cores}                                        4
${def_threads}                                      4
${def_cpu}                                          32
${def_online_cpu}                                   0-31
${def_sockets}                                      2
${open_bmc_username}                                root
${open_bmc_password}                                openpower
${open_bmc_root_prompt}                             root@talos:~#
${obmc_PowerRunning_state}                          Running
${obmc_PowerStandby_state}                          Standby
${obmc_PowerIdle_state}                             Quiesced
${obmc_PowerOff_state}                              Off
${REST_USERNAME}                                    root
${REST_PASSWORD}                                    openpower
${FLASH_VERIFY_METHOD}                              none
${initial_fan_rpm}                                  6995
${accepted_%_near_initial_rpm}                      20
${POWER_CTRL}                                       obmcutil
${tpm_pcr_zero_pattern}                             00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

${talos_sonoff_ip}                                  192.168.10.47
${heads_prompt}                                     ~ #

# Platform flashing flags
${flashing_basic_method}                            obmc
${flashing_dev_method}                              obmc

# Temporary parameter - we are not able to use the Hardware matrix
@{attached_usb}                                     ${usb_live}
${usb_live}                                         USB: sda2

# Supported test environments
${tests_in_firmware_support}                        ${True}
${tests_in_ubuntu_support}                          ${False}
${tests_in_debian_support}                          ${True}
${tests_in_windows_support}                         ${False}
${tests_in_ubuntu_server_support}                   ${False}
${tests_in_proxmox_ve_support}                      ${False}
${tests_in_pfsense_serial_support}                  ${False}
${tests_in_pfsense_vga_support}                     ${False}
${tests_in_opnsense_serial_support}                 ${False}
${tests_in_opnsense_vga_support}                    ${False}
${tests_in_freebsd_support}                         ${False}

# Regression test flags
# Test module: dasharo-compatibility
${base_port_bootblock_support}                      ${True}
${base_port_romstage_support}                       ${True}
${base_port_postcar_support}                        ${False}
${base_port_ramstage_support}                       ${True}
${base_port_allocator_v4_support}                   ${False}
${petitboot_payload_support}                        ${False}
${heads_payload_support}                            ${True}
${custom_boot_menu_key_support}                     ${False}
${custom_setup_menu_key_support}                    ${False}
${custom_network_boot_entries_support}              ${False}
${coreboot_fan_control_support}                     ${False}
${internal_lcd_display_support}                     ${False}
${external_hdmi_display_support}                    ${False}
${external_display_port_support}                    ${False}
${ec_and_super_io_support}                          ${False}
${custom_logo_support}                              ${False}
${usb_disks_detection_support}                      ${False}
${usb_keyboard_detection_support}                   ${False}
${usb_camera_detection_support}                     ${False}
${usb_type_c_display_support}                       ${False}
${uefi_shell_support}                               ${False}
${uefi_compatible_interface_support}                ${False}
${ipxe_boot_support}                                ${False}
${netboot_utilities_support}                        ${False}
${nvme_disk_support}                                ${False}
${sd_card_reader_support}                           ${False}
${wireless_card_support}                            ${False}
${wireless_card_wifi_support}                       ${False}
${wireless_card_bluetooth_support}                  ${False}
${miniPCIe_slot_support}                            ${False}
${nvidia_graphics_card_support}                     ${False}
${usb_c_charging_support}                           ${False}
${thunderbolt_charging_support}                     ${False}
${usb_c_display_support}                            ${False}
${audio_subsystem_support}                          ${False}
${suspend_and_resume_support}                       ${False}
${serial_number_verification}                       ${False}
${serial_from_MAC}                                  ${False}
${firmware_number_verification}                     ${False}
${firmware_from_binary}                             ${False}
${product_name_verification}                        ${False}
${release_date_verification}                        ${False}
${release_date_from_sol}                            ${False}
${manufacturer_verification}                        ${False}
${vendor_verification}                              ${False}
${family_verification}                              ${False}
${type_verification}                                ${False}
${hardware_wp_support}                              ${False}
${docking_station_usb_support}                      ${False}
${docking_station_keyboard_support}                 ${False}
${docking_station_usb_c_charging_support}           ${False}
${docking_station_detect_support}                   ${False}
${docking_station_audio_support}                    ${False}
${emmc_support}                                     ${False}
${DTS_support}                                      ${False}
${firmware_building_support}                        ${False}
${cpu_tests_support}                                ${False}
${docking_station_net_interface}                    ${False}
${docking_station_hdmi}                             ${False}
${docking_station_display_port}                     ${False}
${upload_on_usb_support}                            ${False}
${docking_station_upload_support}                   ${False}
${fan_speed_measure_support}                        ${False}
${device_tree_support}                              ${True}
${docking_station_sd_card_reader_support}           ${False}
${upload_on_usb_support}                            ${False}
${docking_station_upload_support}                   ${False}
${thunderbolt_docking_station_support}              ${False}
${thunderbolt_docking_station_usb_support}          ${False}
${thunderbolt_docking_station_keyboard_support}     ${False}
${thunderbolt_docking_station_upload_support}       ${False}
${thunderbolt_docking_station_net_interface}        ${False}
${thunderbolt_docking_station_hdmi}                 ${False}
${thunderbolt_docking_station_display_port}         ${False}
${thunderbolt_docking_station_audio_support}        ${False}
${docking_station_sd_card_reader_support}           ${False}
${thunderbolt_docking_station_detect_support}       ${False}
${reset_to_defaults_support}                        ${False}

# Test module: dasharo-security
${tpm_support}                                      ${True}
${vboot_keys_generating_support}                    ${False}
${verified_boot_support}                            ${False}
${verified_boot_popup_support}                      ${False}
${measured_boot_support}                            ${False}
${secure_boot_support}                              ${False}
${me_neuter_support}                                ${False}
${usb_stack_support}                                ${False}
${usb_mass_storage_support}                         ${False}
${tcg_opal_disk_password_support}                   ${False}
${bios_lock_support}                                ${False}
${smm_write_protection_support}                     ${False}
${wifi_bluetooth_card_switch_support}               ${False}
${camera_switch_support}                            ${False}
${early_boot_dma_support}                           ${False}
${uefi_password_support}                            ${False}

# Test module: dasharo-performance
${serial_boot_measure}                              ${False}
${device_boot_measure_support}                      ${False}
${cpu_frequency_measure}                            ${True}
${cpu_temperature_measure}                          ${False}
${platform_stability_checking}                      ${False}
${test_fan_speed}                                   ${False}
${custom_fan_curve_silent_mode_support}             ${False}
${custom_fan_curve_performance_mode_support}        ${False}
${ubuntu_booting}                                   ${False}
${debian_booting}                                   ${False}
${ubuntu_server_booting}                            ${False}
${proxmox_ve_booting}                               ${False}
${pfsense_serial_booting}                           ${False}
${pfsense_vga_booting}                              ${False}
${opnsense_serial_booting}                          ${False}
${opnsense_vga_booting}                             ${False}
${freebsd_booting}                                  ${False}
${windows_booting}                                  ${False}

# Test module: dasharo-stability
${m2_wifi_support}                                  ${False}
${nvme_detection_support}                           ${False}
${usb_type-a_devices_detection_support}             ${False}
${tpm_detect_support}                               ${True}

# Supported OS installation variants
${install_debian_usb_support}                       ${False}
${install_ubuntu_usb_support}                       ${False}

# Test cases iterations number
# Booting OS from USB stick test cases
${boot_from_usb_iterations_number}                  0
# Sticks detection test cases
${usb_detection_iterations_number}                  0

# Other platform flags and counters
# Cooling procedure iterations
${cooling_procedure_iterations}                     0
# Stability tests duration in minutes
${stability_test_duration}                          15
# Interval between the following readings in stability tests
${stability_test_measure_interval}                  5
# Frequency measure test duration
${frequency_test_duration}                          60
# Interval between the following readings in frequency measure tests
${frequency_test_measure_interval}                  1
# Temperature measure test duration
${temperature_test_duration}                        60
# Interval between the following readings in temperature measure tests
${temperature_test_measure_interval}                1
# Fan control measure tests duration in minutes
${fan_control_test_duration}                        30
# Interval between the following readings in fan control tests
${fan_control_measure_interval}                     3
# Custom fan curve tests duration in minutes
${custom_fan_curve_test_duration}                   30
# Interval between the following readings in custom fan curve tests
${custom_fan_curve_measure_interval}                1
# Maximum fails during during performing test suite usb-boot.robot
${allowed_fails_usb_boot}                           0
# Maximum fails during during performing test suite usb-detect.robot
${allowed_fails_usb_detect}                         0
# Number of Ubuntu booting iterations
${ubuntu_booting_iterations}                        5
# Number of Debian booting iterations
${debian_booting_iterations}                        5
# Number of Ubuntu Server booting iterations
${ubuntu_server_booting_iterations}                 5
# Number of Proxmox VE booting iterations
${proxmox_ve_booting_iterations}                    5
# Number of pfSense (serial output) booting iterations
${pfsense_serial_booting_iterations}                5
# Number of pfSense (VGA output) booting iterations
${pfsense_vga_booting_iterations}                   5
# Number of OPNsense (serial output) booting iterations
${opnsense_serial_booting_iterations}               5
# Number of OPNsense (VGA output) booting iterations
${opnsense_vga_booting_iterations}                  5
# Number of FreeBSD booting iterations
${freebsd_booting_iterations}                       5
# Number of Windows booting iterations
${windows_booting_iterations}                       5
# Maximum fails during performing booting OS tests
${allowed_booting_fails}                            0
# Number of docking station detection iterations after reboot
${docking_station_reboot_iterations}                2
# Number of docking station detection iterations after warmboot
${docking_station_warmboot_iterations}              2
# Number of docking station detection iterations after coldboot
${docking_station_coldboot_iterations}              2
# Maximum fails during performing docking station detect tests
${allowed_docking_station_detect_fails}             0
# Number of M.2 Wi-fi card checking iterations after suspension
${m2_wifi_iterations}                               5
# Number of NVMe disk detection iterations after suspension
${nvme_detection_iterations}                        5
# Number of USB Type-A devices detection iterations after suspension
${usb_type-a_devices_detection_iterations}          5


*** Keywords ***
Get firmware version from coreboot file
    [Documentation]    Return firmware version from binary file sent via SSH to
    ...    RTE system. Takes binary file path as an argument.
    [Arguments]    ${binary_path}
    ${ecc}=    Get Binary File    ${binary_path}
    ${no_ecc}=    Evaluate    re.sub(rb'(?s)(........).', rb'\\1', $ecc)
    Create Binary File    /tmp/test.rom    ${no_ecc}
    ${output}=    Run    strings /tmp/test.rom
    Remove File    /tmp/test.rom
    ${firmware_version_file}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    RETURN    ${firmware_version_file[-1]}

Get firmware version from bootlogs
    [Documentation]    Return firmware version from the platform booting logs.
    ${output}=    Read From Terminal Until    bootblock starting
    ${firmware_version_bootblock}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    ${output}=    Read From Terminal Until    romstage starting
    ${firmware_version_romstage}=    Get Regexp Matches
    ...    ${output}
    ...    (raptor-cs_talos-2_v|Heads-v)\\d{1,}\.\\d{1,}\.\\d{1,}\
    # Platform may hang if interrupted at wrong time by next test, so let it boot past Skiboot
    Read From Terminal Until    Jumping to boot code
    Read From Terminal Until    INIT: Starting kernel at
    Sleep    5s
    RETURN    ${firmware_version_bootblock[-1]}    ${firmware_version_romstage[-1]}

Set Platform Power State
    [Documentation]    Keyword allows to set platform power state. As platform
    ...    power state is understood whether the platform is connected to the
    ...    power supply. If the platform power state is off, obmc connection
    ...    will not be estabilished.
    [Arguments]    ${requested_power_state}=on
    Sonoff API Setup    ${talos_sonoff_ip}
    ${result}=    Get Sonoff State
    IF    '${result}'=='low'
        Sonoff Power On
        Sleep    120s
    END

Open OBMC Service Connection
    [Documentation]    Keyword allows to open second connection to the OBMC for
    ...    performing service procedures: power controlling and platform flashing.
    ${power_ctrl_connection}=    SSHLibrary.Open Connection    ${device_ip}    prompt=${open_bmc_root_prompt}
    SSHLibrary.Switch Connection    ${power_ctrl_connection}
    SSHLibrary.Login    ${open_bmc_username}    ${open_bmc_password}
    Set DUT Response Timeout    300s

Close OBMC Service Connection
    [Documentation]    Keyword allows to close service connection used for
    ...    platform flashing and controlling platform power state.
    SSHLibrary.Close Connection
    SSHLibrary.Switch Connection    ${1}

Set Chassis Power State
    [Documentation]    Keyword allows to set chassis power state. If the
    ...    chassis power state is off, platform might stuck during the booting
    ...    process. The following solution is temporary - at this point, the
    ...    API command for changing Chassis settings is not working.
    [Arguments]    ${requested_chassis_state}
    Open OBMC Service Connection
    IF    '${requested_chassis_state}'=='off'
        Write Into Terminal    obmcutil chassisoff
        Sleep    60s
        ${chassis_state}=    Get Chassis Power State
        Should Be True    '${chassis_state}' == 'Off'
    ELSE IF    '${requested_chassis_state}'=='on'
        Write Into Terminal    obmcutil chassison
    ELSE
        FAIL    \nUnknown requested power state:${requested_chassis_state}
    END
    Close OBMC Service Connection

Power On
    [Documentation]    Keyword sets Device Under Test into Power On state using
    ...    openbmc-test-automation library and opens console client.
    ...    Implementation must be compatible with the theory of
    ...    operation of a specific platform.
    Variable Should Exist    ${OPENBMC_HOST}
    Set Global Variable    ${AUTH_URI}    https://${OPENBMC_HOST}${AUTH_SUFFIX}
    ${host_state}=    Get Host State
    IF    '${host_state}' != 'Off'    Initiate Host PowerOff
    ${host_state}=    Get Host State
    Should Be True    '${host_state}' == 'Off'
    # Flush any output from previous boot
    Read From Terminal
    Initiate Host Boot    0

Turn On Host With Obmcutil
    [Documentation]    Keyword allows to turn the host system on by using built
    ...    into OpenBMC service to control platform state.
    Write Into Terminal    obmcutil chassison
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    obmcutil poweron
    Read From Terminal Until    ${open_bmc_root_prompt}

Turn Off Host With Obmcutil
    [Documentation]    Keyword allows to turn the host system off by using built
    ...    into OpenBMC service to control platform state.
    Write Into Terminal    obmcutil chassisoff
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    obmcutil poweroff
    Read From Terminal Until    ${open_bmc_root_prompt}

Reset mboxd
    [Documentation]    Keyword allows to reset mboxd service. This operation
    ...    is necessary to erase temporarily mounted images.
    Write Into Terminal    systemctl stop mboxd
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    systemctl start mboxd
    Read From Terminal Until    ${open_bmc_root_prompt}

Read Talos2 Firmware From OpenBMC
    [Documentation]    Keyword allows to read device's current firmware. The
    ...    read firmware is placed on the OpenBMC in /tmp folder
    Write Into Terminal    pflash -P HBB -r /tmp/hbb.bin
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -P HBI -r /tmp/hbi.bin
    Read From Terminal Until    ${open_bmc_root_prompt}

Flash Talos2 Firmware From OpenBMC
    [Documentation]    Keyword flashes the board with uploaded firmware on
    ...    OpenBMC.
    [Arguments]    ${bootblock_file}    ${coreboot_file}
    Open OBMC Service Connection
    SCP.Open Connection    ${device_ip}    username=${open_bmc_username}    password=${open_bmc_password}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset mboxd
    Write Into Terminal    pflash -f -e -P HBB -p /tmp/bootblock.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    100%
    Read From Terminal Until    Programming & Verifying..
    Read From Terminal Until    100%
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -f -e -P HBI -p /tmp/coreboot.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    100%
    Read From Terminal Until    Programming & Verifying..
    Read From Terminal Until    100%
    Read From Terminal Until    ${open_bmc_root_prompt}
    Close OBMC Service Connection

Flash Petitboot From OpenBMC
    [Documentation]    Keyword flashes the board with Petitboot system.
    [Arguments]    ${bootblock_file}    ${coreboot_file}    ${pnor_file}
    Open OBMC Service Connection
    SCP.Open Connection    ${device_ip}    username=${open_bmc_username}    password=${open_bmc_password}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Put File    ${pnor_file}    /tmp/talos.pnor
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset mboxd
    Write Into Terminal    pflash -f -P HBB -p /tmp/bootblock.rom -F /tmp/talos.pnor
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -f -P HBI -p /tmp/coreboot.rom -F /tmp/talos.pnor
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -f -E -p /tmp/talos.pnor
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${open_bmc_root_prompt}
    Close OBMC Service Connection

Flash Heads From OpenBMC
    [Documentation]    Keyword flashes BOOTKERNEL partition to install Heads.
    [Arguments]    ${bootblock_file}    ${coreboot_file}    ${zImage_file}
    ${heads_already_flashed}=    Get Variable Value    ${heads_already_flashed}    ${False}
    IF    ${heads_already_flashed}    RETURN
    Open OBMC Service Connection
    SCP.Open Connection    ${device_ip}    username=${open_bmc_username}    password=${open_bmc_password}
    SCP.Put File    ${bootblock_file}    /tmp/bootblock.rom
    SCP.Put File    ${coreboot_file}    /tmp/coreboot.rom
    SCP.Put File    ${zImage_file}    /tmp/zImage.bundled
    SCP.Close Connection
    Turn Off Host With Obmcutil
    Reset mboxd
    Write Into Terminal    pflash -f -e -P HBB -p /tmp/bootblock.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -f -e -P HBI -p /tmp/coreboot.rom
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${open_bmc_root_prompt}
    Write Into Terminal    pflash -f -e -P BOOTKERNEL -p /tmp/zImage.bundled
    Read From Terminal Until    Erasing...
    Read From Terminal Until    Programming & Verifying...
    Read From Terminal Until    ${open_bmc_root_prompt}
    Close OBMC Service Connection
    Set Global Variable    ${heads_already_flashed}    ${True}

Check TPM PCRs Correctness
    [Documentation]    Keyword allows to checking the TPM PCRs correctness.
    ...    Implementation of the keyword depends on platform specification, for
    ...    Talos 2 it is as follows:
    ...    -> PCRs 0 - 7 values should not be equal zeros,
    ...    -> PCRs 0 and 1 should have the same values. We call them
    ...    "capped values",
    ...    -> PCRs 2 and 3 values should not be the same as "capped values",
    ...    -> PCRs 4 and 5 values should not be the same as "capped values",
    ...    -> PCRs 6 and 7 values depend on current state of Heads, skip checks.
    [Arguments]    ${tpm_pcrs}
    ${number_of_pcrs}=    Get length    ${tpm_pcrs}
    FOR    ${iteration}    IN RANGE    0    8
        TRY
            Should Be True    '${tpm_pcrs[${iteration}][8:]}'!='${tpm_pcr_zero_pattern}'
        EXCEPT
            FAIL    \n PCR-${iteration} has incorrect value: ${tpm_pcrs[${iteration}]}
        END
    END
    IF    '${tpm_pcrs[0][8:]}'!='${tpm_pcrs[1][8:]}'
        FAIL    \nValues for PCRs 0 and 1 are not the same!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[2][8:]}'
        FAIL    \nValue for PCR 2 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[3][8:]}'
        FAIL    \nValue for PCR 3 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[4][8:]}'
        FAIL    \nValue for PCR 4 is the same as capped values!
    END
    IF    '${tpm_pcrs[0][8:]}'=='${tpm_pcrs[5][8:]}'
        FAIL    \nValue for PCR 5 is the same as capped values!
    END

Check TPM PCRs Correctness Between Subsequent Boots
    [Documentation]    Keyword allows to checking the TPM PCRs correctness
    ...    between the subsequent boot procedures. Values from each PCR should
    ...    be the same across all boot types.
    [Arguments]    ${pcrs_subsequent_boots}
    ${list}=    Remove Duplicates    ${pcrs_subsequent_boots}
    ${length}=    Get Length    ${list}
    IF    ${length}!=1
        FAIL    \nPCR values have been changed between subsequent boots!
    END
