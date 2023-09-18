*** Variables ***
${dut_connection_method}        Telnet
${payload}                      seabios
${rte_s2n_port}                 13541
${flash_size}                   ${12*1024*1024}
${seabios_string}               ESC
${seabios_key}                  \x1b
${tianocore_string}             ESC
${tianocore_key}                \x1b
${manufacturer}                 PC Engines
${cpu}                          AMD G-T40E
${dram_size}                    ${4096}
${def_cores}                    2
${def_threads}                  1
${def_cpu}                      2
${def_online_cpu}               0-1
${def_sockets}                  1
${power_ctrl}                   sonoff
${flash_verify_method}          tianocore-shell
${flash_verify_option}          UEFI Shell    # Selected One Time Boot option

# Platform flashing flags
${flashing_basic_method}        external

# Regression test flags
# suite: board-status
${L3_cache_support}             ${False}
${L4_cache_support}             ${False}
${hard_disk_with_Linux}         ${False}
${hard_disk_with_pfSense}       ${False}
${wol_support}                  ${False}
# suite: coreboot
${prepare_security_reg}         ${False}
${SOL_support}                  ${False}
${change_release_date}          ${False}
${serial_number_support}        ${False}
${serial_from_MAC}              ${False}
${ECC_support}                  ${False}
# suite: os
${iPXE_string_support}          ${False}
# suite: payload
${iPXE_config_support}          ${False}
${serial_config_support}        ${False}
${boot_menu_wait_6s}            ${False}
${security_registers}           ${False}
${sortbootorder_support}        ${False}
${cbp_support}                  ${False}
${iommu_support}                ${False}
${BIOS_WP_support}              ${False}
${EHCI0_support}                ${False}
${serial_redirection}           ${False}
${memtest_support}              ${False}
${delete_all_MBR}               ${False}
${watchdog_support}             ${False}
${sd_mode_support}              ${False}
# suite: hardware
${gpio_driver_support}          ${False}
${switch_S1_support}            ${False}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    Sonoff Power Off
    Sleep    1s
    # read the old output
    Telnet.Read
    Sonoff Power On
    RteCtrl Power On

Flash firmware optiplex
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to OFF state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sonoff Power Off
    Sleep    2s
    RteCtrl Set OC GPIO    2    low
    RteCtrl Set OC GPIO    3    low
    RteCtrl Set OC GPIO    1    low
    # Currently the device is connected with only one of two spi-flash chips.
    # 8MB of memory on spi-flash chip 2 is unused, so only 4MB is used. Here
    # we use `dd` to recover the 4MB part suited for SPI_1
    SSHLibrary.Execute Command
    ...    dd if=/tmp/coreboot.rom of=/tmp/coreboot_spi1.rom skip=8388608 count=4194304 bs=1
    SSHLibrary.Execute Command    cat /sys/class/gpio/gpio40{4,5,6}/value
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=1600 -w /tmp/coreboot_spi1.rom 2>&1
    ...    return_rc=True
    RteCtrl Set OC GPIO    2    high-z
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    SSHLibrary.Execute Command    cat /sys/class/gpio/gpio40{4,5,6}/value

    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
    Power Cycle Off

Read firmware optiplex
    [Documentation]    Read Device Under Test firmware and set RTE relay to OFF
    ...    state. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    Sonoff Power Off
    Sleep    2s
    RteCtrl Set OC GPIO    2    low
    RteCtrl Set OC GPIO    3    low
    RteCtrl Set OC GPIO    1    low
    # Currently the device is connected with only one of two spi-flash chips.
    # 8MB of memory on spi-flash chip 2 is unused, so only 4MB is used. Only
    # content of the SPI_1 chip will be read
    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -r /tmp/coreboot.rom
    RteCtrl Set OC GPIO    2    high-z
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    Power Cycle Off
