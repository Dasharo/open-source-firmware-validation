*** Settings ***
Resource    ../os/ubuntu_2204_credentials.robot


*** Variables ***
${dut_connection_method}                                SSH
${payload}                                              tianocore
${rte_s2n_port}                                         ${EMPTY}
${flash_size}                                           ${16*1024*1024}
${tianocore_key}                                        ${F2}
${tianocore_string}                                     ENTER
${tianocore_boot_menu_key}                              ${F7}
${setup_menu_key}                                       ${EMPTY}
${manufacturer}                                         ${EMPTY}
${cpu}                                                  Intel(R) Core(TM) i7-1165G7 CPU
${initial_cpu_frequency}                                2800
${dram_size}                                            ${8192}
${def_cores}                                            4
${def_threads}                                          2
${def_cpu}                                              8
${def_online_cpu}                                       0-7
${def_sockets}                                          2
${ipxe_boot_entry}                                      iPXE Network boot
${ipxe_string}                                          Network Boot Firmware
${initial_fan_rpm}                                      6995
${accepted_%_near_initial_rpm}                          20
${max_cpu_temp}                                         77

# Platform flashing flags
${flashing_basic_method}                                fwupd
${flashing_verify_method}                               ${EMPTY}

# These were added    for clevo tests
${device_ubuntu_username}                               ${UBUNTU_USERNAME}
${device_windows_username}                              user
${device_ubuntu_password}                               ${UBUNTU_PASSWORD}
${device_windows_password}                              windows
${device_ubuntu_hostname}                               ${UBUNTU_HOSTNAME}
${clevo_battery_capacity}                               3200*1000
# ${clevo_brightness_delta}    2376 - unfortunately it's not constant
${device_nvme_disk}                                     Non-Volatile memory controller
${clevo_disk}                                           Samsung SSD 980 PRO
${device_usb_keyboard}                                  Logitech, Inc. Keyboard K120
${usb_stick}                                            USB SanDisk 3.2Gen1
${win_usb_stick}                                        ${SPACE * 1}USB${SPACE * 2}SanDisk 3.2Gen1
${clevo_usb_c_hub}                                      4-port
${device_audio1}                                        ALC256
${device_audio2}                                        Alderlake-P HDMI
${3mdeb_wifi_network}                                   3mdeb_abr
${sd_card_vendor}                                       TS-RDF5A
${sd_card_model}                                        Transcend
${wifi_card}                                            Intel(R) Wi-Fi 6 AX201 160MHz
${wifi_card_ubuntu}                                     Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
${bluetooth_card_ubuntu}                                Intel Corp. AX201 Bluetooth
${device_audio1_win}                                    Realtek High Definition Audio
${usb_model}                                            USB Flash Memory
${external_headset}                                     USB PnP Audio Device
${usb_device}                                           Kingston

${dmidecode_serial_number}                              N/A
${dmidecode_firmware_version}                           Dasharo (coreboot+UEFI) v1.6.0
${dmidecode_product_name}                               NV4xPZ
${dmidecode_release_date}                               03/17/2022
${dmidecode_manufacturer}                               Notebook
${dmidecode_vendor}                                     3mdeb
${dmidecode_family}                                     Not Applicable
${dmidecode_type}                                       Notebook

# battery capacity (in mAh) should be given a little higher than actually is
# and converted to uAh
# regexp for prompt
# prompt contains path - it can be either ~ when in home directory, or it can
# be a full path

${device_ubuntu_user_prompt}                            ${UBUNTU_USER_PROMPT}
${device_ubuntu_root_prompt}                            ${UBUNTU_ROOT_PROMPT}

# Platform flashing flags
${flashing_basic_method}                                fwupd

# Supported test environments
${tests_in_firmware_support}                            ${False}
${tests_in_ubuntu_support}                              ${True}
${tests_in_debian_support}                              ${False}
${tests_in_windows_support}                             ${False}
${tests_in_ubuntu_server_support}                       ${False}
${tests_in_proxmox_ve_support}                          ${False}
${tests_in_pfsense_serial_support}                      ${False}
${tests_in_pfsense_vga_support}                         ${False}
${tests_in_opnsense_serial_support}                     ${False}
${tests_in_opnsense_vga_support}                        ${False}
${tests_in_freebsd_support}                             ${False}

# Regression test flags
# Test module: dasharo-compatibility
${base_port_bootblock_support}                          ${False}
${base_port_romstage_support}                           ${False}
${base_port_postcar_support}                            ${False}
${base_port_ramstage_support}                           ${False}
${base_port_allocator_v4_support}                       ${False}
${petitboot_payload_support}                            ${False}
${heads_payload_support}                                ${False}
${custom_boot_menu_key_support}                         ${False}
${custom_setup_menu_key_support}                        ${False}
${custom_network_boot_entries_support}                  ${False}
${coreboot_fan_control_support}                         ${False}
${device_tree_support}                                  ${False}
${internal_lcd_display_support}                         ${True}
${external_hdmi_display_support}                        ${True}
${external_display_port_support}                        ${False}
${ec_and_super_io_support}                              ${True}
${custom_logo_support}                                  ${False}
${usb_disks_detection_support}                          ${True}
${usb_keyboard_detection_support}                       ${True}
${usb_camera_detection_support}                         ${True}
${usb_type_c_display_support}                           ${True}
${uefi_shell_support}                                   ${True}
${uefi_compatible_interface_support}                    ${True}
${ipxe_boot_support}                                    ${True}
${netboot_utilities_support}                            ${False}
${nvme_disk_support}                                    ${True}
${sd_card_reader_support}                               ${True}
${wireless_card_support}                                ${True}
${wireless_card_wifi_support}                           ${True}
${wireless_card_bluetooth_support}                      ${True}
${nvidia_graphics_card_support}                         ${False}
${usb_c_charging_support}                               ${True}
${thunderbolt_charging_support}                         ${True}
${usb_c_display_support}                                ${False}
${audio_subsystem_support}                              ${True}
${suspend_and_resume_support}                           ${True}
${serial_number_verification}                           ${False}
${serial_from_MAC}                                      ${False}
${firmware_number_verification}                         ${True}
${firmware_from_binary}                                 ${False}
${product_name_verification}                            ${True}
${release_date_verification}                            ${True}
${release_date_from_sol}                                ${False}
${manufacturer_verification}                            ${True}
${vendor_verification}                                  ${True}
${family_verification}                                  ${True}
${type_verification}                                    ${True}
${hardware_wp_support}                                  ${False}
${cpu_tests_support}                                    ${False}
${L2_cache_support}                                     ${False}
${L3_cache_support}                                     ${False}
${L4_cache_support}                                     ${False}
${docking_station_usb_support}                          ${True}
${docking_station_keyboard_support}                     ${True}
${docking_station_usb_c_charging_support}               ${False}
${docking_station_detect_support}                       ${True}
${docking_station_audio_support}                        ${True}
${emmc_support}                                         ${False}
${DTS_support}                                          ${False}
${firmware_building_support}                            ${True}
${docking_station_net_interface}                        ${True}
${docking_station_hdmi}                                 ${True}
${docking_station_display_port}                         ${True}
${upload_on_usb_support}                                ${True}
${docking_station_upload_support}                       ${True}
${fan_speed_measure_support}                            ${True}
${thunderbolt_docking_station_support}                  ${True}
${thunderbolt_docking_station_usb_support}              ${True}
${thunderbolt_docking_station_keyboard_support}         ${True}
${thunderbolt_docking_station_upload_support}           ${True}
${thunderbolt_docking_station_net_interface}            ${True}
${thunderbolt_docking_station_hdmi}                     ${True}
${thunderbolt_docking_station_display_port}             ${True}
${thunderbolt_docking_station_audio_support}            ${True}
${docking_station_sd_card_reader_support}               ${True}
${wifi_bluetooth_card_switch_support}                   ${True}
${boot_blocking_support}                                ${True}
${hibernation_and_resume_support}                       ${False}
${reset_to_defaults_support}                            ${False}

# Test module: dasharo-security
${tpm_support}                                          ${True}
${vboot_keys_generating_support}                        ${True}
${verified_boot_support}                                ${True}
${verified_boot_popup_support}                          ${False}
${measured_boot_support}                                ${True}
${secure_boot_support}                                  ${False}
${usb_stack_support}                                    ${False}
${usb_mass_storage_support}                             ${False}
${tcg_opal_disk_password_support}                       ${False}
${bios_lock_support}                                    ${False}
${smm_write_protection_support}                         ${False}
${wifi_bluetooth_card_switch_support}                   ${True}
${camera_switch_support}                                ${True}
${early_boot_dma_support}                               ${False}
${uefi_password_support}                                ${False}

# Test module: dasharo-performance
${serial_boot_measure}                                  ${False}
${device_boot_measure_support}                          ${False}
${cpu_temperature_measure}                              ${True}
${cpu_frequency_measure}                                ${True}
${platform_stability_checking}                          ${True}
${test_fan_speed}                                       ${False}
${custom_fan_curve_silent_mode_support}                 ${True}
${custom_fan_curve_performance_mode_support}            ${False}
${ubuntu_booting}                                       ${False}
${debian_booting}                                       ${False}
${ubuntu_server_booting}                                ${False}
${proxmox_ve_booting}                                   ${False}
${pfsense_serial_booting}                               ${False}
${pfsense_vga_booting}                                  ${False}
${opnsense_serial_booting}                              ${False}
${opnsense_vga_booting}                                 ${False}
${freebsd_booting}                                      ${False}
${windows_booting}                                      ${False}

# Test module: dasharo-stability
${m2_wifi_support}                                      ${True}
${nvme_detection_support}                               ${True}
${usb_type-a_devices_detection_support}                 ${True}
${tpm_detect_support}                                   ${False}
${network_interface_after_suspend_support}              ${True}

# Supported OS installation variants
${install_debian_usb_support}                           ${False}
${install_ubuntu_usb_support}                           ${False}

# Other platform flags and counters
# Cooling procedure iterations
${cooling_procedure_iterations}                         0
# Stability tests duration in minutes
${stability_test_duration}                              15
# Interval between the following readings in stability tests
${stability_test_measure_interval}                      5
# Frequency measure test duration
${frequency_test_duration}                              60
# Interval between the following readings in frequency measure tests
${frequency_test_measure_interval}                      1
# Temperature measure test duration
${temperature_test_duration}                            60
# Interval between the following readings in temperature measure tests
${temperature_test_measure_interval}                    1
# Fan control measure tests duration in minutes
${fan_control_test_duration}                            30
# Interval between the following readings in fan control tests
${fan_control_measure_interval}                         3
# Custom fan curve tests duration in minutes
${custom_fan_curve_test_duration}                       30
# Interval between the following readings in custom fan curve tests
${custom_fan_curve_measure_interval}                    1
# Maximum fails during during performing test suite usb-boot.robot
${allowed_fails_usb_boot}                               0
# Maximum fails during during performing test suite usb-detect.robot
${allowed_fails_usb_detect}                             0
# Number of suspend and resume cycles performed during suspend test
${suspend_iterations_number}                            15
# Maximum number of fails during performing suspend and resume cycles
${suspend_allowed_fails}                                0
# Number of Ubuntu booting iterations
${ubuntu_booting_iterations}                            5
# Number of Debian booting iterations
${debian_booting_iterations}                            5
# Number of Ubuntu Server booting iterations
${ubuntu_server_booting_iterations}                     5
# Number of Proxmox VE booting iterations
${proxmox_ve_booting_iterations}                        5
# Number of pfSense (serial output) booting iterations
${pfsense_serial_booting_iterations}                    5
# Number of pfSense (VGA output) booting iterations
${pfsense_vga_booting_iterations}                       5
# Number of OPNsense (serial output) booting iterations
${opnsense_serial_booting_iterations}                   5
# Number of OPNsense (VGA output) booting iterations
${opnsense_vga_booting_iterations}                      5
# Number of FreeBSD booting iterations
${freebsd_booting_iterations}                           5
# Number of Windows booting iterations
${windows_booting_iterations}                           5
# Maximum fails during performing booting OS tests
${allowed_booting_fails}                                0
# Number of docking station detection iterations after reboot
${docking_station_reboot_iterations}                    2
# Number of docking station detection iterations after warmboot
${docking_station_warmboot_iterations}                  2
# Number of docking station detection iterations after coldboot
${docking_station_coldboot_iterations}                  2
# Maximum fails during performing docking station detect tests
${allowed_docking_station_detect_fails}                 0
# Number of M.2 Wi-fi card checking iterations after suspension
${m2_wifi_iterations}                                   5
# Number of NVMe disk detection iterations after suspension
${nvme_detection_iterations}                            5
# Number of USB Type-A devices detection iterations after suspension
${usb_type-a_devices_detection_iterations}              5
# Number of USB Type-A devices detection iterations after reboot
${usb_type-a_devices_detection_reboot_iterations}       2


*** Keywords ***
Power On
    [Documentation]    Keyword clears SSH buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${dut_connection_method}' == 'SSH'    RETURN
    Sleep    1s
    RteCtrl Power Off
    Sleep    7s
    # read the old output
    SSH.Read
    RteCtrl Power On

Flash Device via Internal Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using internal programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    [Arguments]    ${fw_file}
    Login to Linux
    Switch to root user
    Put File    ${fw_file}    /tmp/coreboot.rom
    Get flashrom from cloud
    Write Into Terminal    flashrom -p internal -w /tmp/coreboot.rom --ifd -i bios
    ${flash_result}=    Read From Terminal Until Prompt
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Flash Device via Internal Programmer with fwupd
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using internal programmer with fwupd and check flashing
    ...    procedure result. Implementation must be compatible with
    ...    the theory of operation of a specific platform.
    Power On
    Login to Linux
    Switch to root user
    Install fwupd and flashrom
    Get embargo configuration
    Execute Linux Command    fwupdmgr refresh --force
    ${output}=    Execute Linux command    fwupdmgr update
    Should Not Contain    ${output}    No updatable devices
    Exit from root user

Flash Device via External Programmer
    [Documentation]    Keyword allows to flash Device Under Test firmware by
    ...    using external programmer and check flashing procedure
    ...    result. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    [Arguments]    ${fw_file}
    Set Local Variable    ${cmd}    ./flashrom -p ch341a_spi -c GD25B128B/GD25Q128B -w ${fw_file}
    # TODO:
    # - flashing via RTE does not work yet
    # ${out}=
    # Should Contain    ${out}    Erase/write done
    # Should Contain    ${out}    VERIFIED

Read firmware clevo
    [Documentation]    Read from the flash and save to file dump.rom
    Write Into Terminal    flashrom -p internal -r coreboot.rom
    Read From Terminal Until Prompt

Build coreboot
    [Documentation]    Keyword builds coreboot and save the image to
    ...    `build/coreboot.rom` directory.
    Execute Linux command    docker pull coreboot/coreboot-sdk:latest    10    300
    Execute Linux command    git clone https://github.com/3mdeb/coreboot.git    10    60
    Execute Linux command    cd coreboot    10    10
    Execute Linux command
    ...    docker run --rm -it -v $PWD:/home/coreboot/coreboot -w /home/coreboot/coreboot coreboot/coreboot-sdk:latest /bin/bash
    ...    10
    ...    120
    Execute Linux command    cp configs/config.clevo_nv41mz .config    10    10
    Execute Linux command    make olddefconfig    10    10
    Execute Linux command    make nconfig    10    10
    Execute Linux command    make    10    300

Check coreboot Components Measurement
    [Documentation]    Check whether the hashes of the coreboot components
    ...    measurements have been stored in the TPM PCR registers.
    ${out}=    Execute Linux command    ./cbmem -c | grep -i PCR | cat
    Should Contain    ${out}    fallback/payload` to PCR 2 measured
    Should Contain    ${out}    fallback/dsdt.aml` to PCR 2 measured
    Should Contain    ${out}    vbt.bin` to PCR 2 measured
    Should Contain    ${out}    fallback/romstage` to PCR 2 measured
    Should Contain    ${out}    fspm.bin` to PCR 2 measured
    Should Contain    ${out}    fallback/postcar` to PCR 2 measured
    Should Contain    ${out}    cpu_microcode_blob.bin` to PCR 2 measured
    Should Contain    ${out}    fsps.bin` to PCR 2 measured
    Should Contain    ${out}    logo.bmp` to PCR 2 measured
    Should Contain    ${out}    fallback/ramstage` to PCR 2 measured
    Should Not Contain    ${out}    Extending hash into PCR failed
