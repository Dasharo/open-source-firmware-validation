*** Settings ***
Resource    ../os/ubuntu_2204_credentials.robot


*** Variables ***
# For the pikvm connection, we switch between pikvm/SSH when in firmware/OS.
# We need to go back to the initial method (pikvm) when switching back from
# OS to firmware (e.g. when rebooting inside a single test case).
${initial_dut_connection_method}                    pikvm
${dut_connection_method}                            ${initial_dut_connection_method}
${payload}                                          tianocore
${rte_s2n_port}                                     13541
${flash_size}                                       ${32*1024*1024}
${flash_length}                                     ${EMPTY}
${tianocore_string}                                 to boot directly
${boot_menu_key}                                    F11
${setup_menu_key}                                   Delete
${boot_menu_string}                                 Please select boot device:
${setup_menu_string}                                Select Entry
${payload_string}                                   ${EMPTY}
${edk2_ipxe_string}                                 iPXE Network Boot
${edk2_ipxe_checkpoint}                             iPXE Shell
${edk2_ipxe_start_pos}                              1
${ipxe_boot_entry}                                  ${EMPTY}
${ipxe_string}                                      ${EMPTY}
${ipxe_string2}                                     ${EMPTY}
${ipxe_key}                                         ${EMPTY}
${net_boot_key}                                     ${EMPTY}
${sol_string}                                       ${EMPTY}
${sn_pattern}                                       ${EMPTY}
${manufacturer}                                     ${EMPTY}
${cpu}                                              ${EMPTY}
${power_ctrl}                                       sonoff
${flash_verify_method}                              none
${incorrect_signatures_firmware}                    ${EMPTY}
${wifi_card}                                        ${EMPTY}
${wifi_card_ubuntu}                                 ${EMPTY}
${initial_fan_rpm}                                  6995
${accepted_%_near_initial_rpm}                      20
# ${ecc_string}    Single-bit ECC
# ${IOMMU_string}    (XEN) AMD-Vi: IOMMU 0 Enable
# ${dram_size}    ${4096}
# ${def_cores}    4
# ${def_threads}    1
# ${def_cpu}    4
# ${def_online_cpu}    0-3
# ${def_sockets}    1
# ${wol_interface}    enp3s0
# ${SD_DEV_LINUX}    /dev/mmcblk0
# ${nic_number}    ${4}

# Platform flashing flags
${flashing_basic_method}                            external

${device_windows_username}                          user
${device_windows_password}                          windows
${device_windows_user_prompt}                       PS C:\\Users\\user>

${device_ubuntu_username}                           user
${device_ubuntu_password}                           ubuntu
${device_ubuntu_user_prompt}                        user@user-MS-7E06:~$
${device_ubuntu_root_prompt}                        root@user-MS-7E06:/home/user#
${pikvm_ip}                                         192.168.10.226
${3mdeb_wifi_network}                               3mdeb_abr

${dmidecode_serial_number}                          N/A
${dmidecode_firmware_version}                       Dasharo (coreboot+UEFI) v0.9.0
${dmidecode_product_name}                           MS-7E06
${dmidecode_release_date}                           08/29/2023
${dmidecode_manufacturer}                           Micro-Star International Co., Ltd.
${dmidecode_vendor}                                 3mdeb
${dmidecode_family}                                 N/A
${dmidecode_type}                                   Desktop

${device_usb_keyboard}                              ${EMPTY}
${device_nvme_disk}                                 ${EMPTY}
${device_audio1}                                    ${EMPTY}
${device_audio2}                                    ${EMPTY}
${device_audio1_win}                                Realtek High Definition Audio
${wifi_card_ubuntu}                                 ${EMPTY}
${usb_model}                                        Kingston
${sd_card_vendor}                                   Mass
${sd_card_model}                                    Storage
${no_check_sonoff}                                  ${True}

# Supported test environments
${tests_in_firmware_support}                        ${True}
${tests_in_ubuntu_support}                          ${True}
${tests_in_debian_support}                          ${False}
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
${coreboot_base_port_support}                       ${False}
${resource_allocator_v4_support}                    ${False}
${custom_boot_menu_key_support}                     ${True}
${custom_setup_menu_key_support}                    ${True}
${custom_network_boot_entries_support}              ${False}
${coreboot_fan_control_support}                     ${False}
${internal_lcd_display_support}                     ${False}
${external_hdmi_display_support}                    ${True}
${external_display_port_support}                    ${True}
${ec_and_super_io_support}                          ${False}
${custom_logo_support}                              ${True}
${usb_disks_detection_support}                      ${True}
${usb_keyboard_detection_support}                   ${True}
${usb_camera_detection_support}                     ${False}
${usb_type_c_display_support}                       ${False}
${uefi_shell_support}                               ${True}
${uefi_compatible_interface_support}                ${True}
${ipxe_boot_support}                                ${False}
${nvme_disk_support}                                ${True}
${sd_card_reader_support}                           ${True}
${wireless_card_support}                            ${True}
${wireless_card_wifi_support}                       ${True}
${wireless_card_bluetooth_support}                  ${True}
${nvidia_graphics_card_support}                     ${False}
${usb_c_charging_support}                           ${False}
${thunderbolt_charging_support}                     ${False}
${usb_c_display_support}                            ${False}
${audio_subsystem_support}                          ${True}
${suspend_and_resume_support}                       ${True}
${serial_number_verification}                       ${False}
${serial_from_MAC}                                  ${False}
${firmware_number_verification}                     ${True}
${firmware_from_binary}                             ${False}
${product_name_verification}                        ${True}
${release_date_verification}                        ${True}
${release_date_from_sol}                            ${False}
${manufacturer_verification}                        ${True}
${vendor_verification}                              ${True}
${family_verification}                              ${False}
${type_verification}                                ${True}
${hardware_wp_support}                              ${False}
${docking_station_usb_support}                      ${False}
${docking_station_keyboard_support}                 ${False}
${docking_station_usb_c_charging_support}           ${False}
${emmc_support}                                     ${False}
${DTS_support}                                      ${True}
${firmware_building_support}                        ${False}
${docking_station_net_interface}                    ${False}
${docking_station_hdmi}                             ${False}
${docking_station_display_port}                     ${False}
${upload_on_usb_support}                            ${True}
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
${cpu_tests_support}                                ${True}
${reset_to_defaults_support}                        ${True}

# Test module: dasharo-security
${tpm_support}                                      ${True}
${vboot_keys_generating_support}                    ${False}
${verified_boot_support}                            ${True}
${verified_boot_popup_support}                      ${True}
${measured_boot_support}                            ${True}
${secure_boot_support}                              ${True}
${me_neuter_support}                                ${True}
${usb_stack_support}                                ${False}
${usb_mass_storage_support}                         ${True}
${tcg_opal_disk_password_support}                   ${True}
${bios_lock_support}                                ${True}
${smm_write_protection_support}                     ${True}
${wifi_bluetooth_card_switch_support}               ${False}
${camera_switch_support}                            ${False}
${early_boot_dma_support}                           ${True}
${uefi_password_support}                            ${True}

# Test module: dasharo-performance
${serial_boot_measure}                              ${False}
${device_boot_measure_support}                      ${False}
${cpu_temperature_measure}                          ${False}
${cpu_frequency_measure}                            ${False}
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
${tpm_detect_support}                               ${False}

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
# Number of suspend and resume cycles performed during suspend test
${suspend_iterations_number}                        15
# Maximum number of fails during performing suspend and resume cycles
${suspend_allowed_fails}                            0
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
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Restore Initial DUT Connection Method
    IF    '${dut_connection_method}' == 'SSH'    RETURN
    Sleep    2s
    RteCtrl Power Off    ${6}
    Sleep    5s
    # read the old output
    Telnet.Read
    RteCtrl Power On

Flash MSI-PRO-Z790-P-DDR5
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to OFF state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sonoff Power Cycle Off
    Put file    ${fw_file}    /tmp/coreboot.rom
    FOR    ${iterations}    IN RANGE    0    5
        RteCtrl Power Off    ${6}
        Sleep    2s
    END
    Sleep    2s
    RteCtrl Set OC GPIO    2    high-z
    Sleep    2s
    RteCtrl Set OC GPIO    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    1    low
    Sleep    3s
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 --layout msi_z690a.layout -i bios -w /tmp/coreboot.rom 2>&1
    ...    return_rc=True
    IF    ${rc} != 0    Fail    \nFlashrom returned status ${rc}\n
    RteCtrl Set OC GPIO    1    high-z
    RteCtrl Set OC GPIO    3    high-z
    Sleep    2s
    Sonoff Power Cycle On
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Read MSI-PRO-Z790-P-DDR5 firmware
    [Documentation]    Read Device Under Test firmware and set RTE relay to OFF
    ...    state. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    Sonoff Power Cycle Off
    Sleep    2s
    SSHLibrary.Execute Command    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -r /tmp/coreboot.rom
    Power Cycle Off
