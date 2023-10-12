*** Variables ***
${DUT_CONNECTION_METHOD}=               Telnet
${PAYLOAD}=                             seabios
${RTE_S2_N_PORT}=                       13541
${FLASH_SIZE}=                          ${12*1024*1024}
${SEABIOS_STRING}=                      ESC
${SEABIOS_KEY}=                         \x1b
${TIANOCORE_STRING}=                    ESC
${TIANOCORE_KEY}=                       \x1b
${MANUFACTURER}=                        PC Engines
${CPU}=                                 AMD G-T40E
${DRAM_SIZE}=                           ${16384}
${DEF_CORES}=                           2
${DEF_THREADS}=                         1
${DEF_CPU}=                             2
${DEF_ONLINE_CPU}=                      0-1
${DEF_SOCKETS}=                         1
${POWER_CTRL}=                          sonoff
${FLASH_VERIFY_METHOD}=                 tianocore-shell
${FLASH_VERIFY_OPTION}=                 UEFI Shell    # Selected One Time Boot option
${AUTO_BOOT_TIME_OUT_DEFAULT_VALUE}=    ${EMPTY}
${DASHARO_EXIT_PROMPT}=                 ${EMPTY}

# Platform flashing flags
${FLASHING_BASIC_METHOD}=               external

# Regression test flags
# suite: board-status
${L3_CACHE_SUPPORT}=                    ${FALSE}
${L4_CACHE_SUPPORT}=                    ${FALSE}
${HARD_DISK_WITH_LINUX}=                ${FALSE}
${HARD_DISK_WITH_PF_SENSE}=             ${FALSE}
${WOL_SUPPORT}=                         ${FALSE}
# suite: coreboot
${PREPARE_SECURITY_REG}=                ${FALSE}
${SOL_SUPPORT}=                         ${FALSE}
${CHANGE_RELEASE_DATE}=                 ${FALSE}
${SERIAL_NUMBER_SUPPORT}=               ${FALSE}
${SERIAL_FROM_MAC}=                     ${FALSE}
${ECC_SUPPORT}=                         ${FALSE}
# suite: os
${I_PXE_STRING_SUPPORT}=                ${FALSE}
# suite: payload
${I_PXE_CONFIG_SUPPORT}=                ${FALSE}
${SERIAL_CONFIG_SUPPORT}=               ${FALSE}
${BOOT_MENU_WAIT_6_S}=                  ${FALSE}
${SECURITY_REGISTERS}=                  ${FALSE}
${SORTBOOTORDER_SUPPORT}=               ${FALSE}
${CBP_SUPPORT}=                         ${FALSE}
${IOMMU_SUPPORT}=                       ${FALSE}
${BIOS_WP_SUPPORT}=                     ${FALSE}
${EHCI0_SUPPORT}=                       ${FALSE}
${SERIAL_REDIRECTION}=                  ${FALSE}
${MEMTEST_SUPPORT}=                     ${FALSE}
${DELETE_ALL_MBR}=                      ${FALSE}
${WATCHDOG_SUPPORT}=                    ${FALSE}
${SD_MODE_SUPPORT}=                     ${FALSE}
# suite: hardware
${GPIO_DRIVER_SUPPORT}=                 ${FALSE}
${SWITCH_S1_SUPPORT}=                   ${FALSE}


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

Flash Firmware Optiplex
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

Read Firmware Optiplex
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
