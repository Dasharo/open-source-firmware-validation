*** Settings ***
Resource    include/default.robot


*** Variables ***
${INITIAL_DUT_CONNECTION_METHOD}=       Telnet
${DUT_CONNECTION_METHOD}=               ${INITIAL_DUT_CONNECTION_METHOD}
${PAYLOAD}=                             tianocore
${RTE_S2_N_PORT}=                       13542
${FLASH_SIZE}=                          ${8*1024*1024}
${FLASH_LENGTH}=                        ${EMPTY}
${BOOT_MENU_STRING}=                    Please select boot device:
${SETUP_MENU_STRING}=                   Select Entry
${EDK2_IPXE_CHECKPOINT}=                iPXE Shell
${MANUFACTURER}=                        MinnowBoard
${CPU}=                                 Intel Atom E3845 SoC
${POWER_CTRL}=                          RteCtrl
${FLASH_VERIFY_METHOD}=                 tianocore-shell
${FLASH_VERIFY_OPTION}=                 UEFI Shell
${WIFI_CARD}=                           ${EMPTY}
${MAX_CPU_TEMP}=                        ${EMPTY}

${DEVICE_USB_KEYBOARD}=                 Logitech, Inc. Keyboard K120

# Supported test environments
${TESTS_IN_FIRMWARE_SUPPORT}=           ${TRUE}
${TESTS_IN_UBUNTU_SUPPORT}=             ${FALSE}
${TESTS_IN_DEBIAN_SUPPORT}=             ${FALSE}
${TESTS_IN_WINDOWS_SUPPORT}=            ${FALSE}

# Regression test flags
${CUSTOM_BOOT_MENU_KEY_SUPPORT}=        ${TRUE}


*** Keywords ***
Power On
    [Documentation]    Keyword clears telnet buffer and sets Device Under Test
    ...    into Power On state using RTE OC buffers. Implementation
    ...    must be compatible with the theory of operation of a
    ...    specific platform.
    IF    '${DUT_CONNECTION_METHOD}' == 'SSH'    RETURN
    Sleep    3s
    RteCtrl Power Off
    Sleep    1s
    Telnet.Read
    RteCtrl Power On

Flash Mbt
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to OFF state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sleep    1s
    Power Cycle Off
    IF    '${FLASH_OPT}'=='full'
        ${flash_result}    ${rc}=    SSHLibrary.Execute Command
        ...    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=8000 -w /tmp/coreboot.rom 2>&1
        ...    return_rc=True
    ELSE
        ${flash_result}    ${rc}=    SSHLibrary.Execute Command
        ...    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=8000 -w /tmp/coreboot.rom --ifd -i bios 2>&1
        ...    return_rc=True
    END
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Read Firmware Mbt
    [Documentation]    Read Device Under Test firmware and set RTE relay to OFF
    ...    state. Implementation must be compatible with the theory
    ...    of operation of a specific platform.
    Sleep    1s
    Power Cycle Off
    IF    '${FLASH_OPT}'=='full'
        SSHLibrary.Execute Command    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=8000 -r /tmp/coreboot.rom
    ELSE
        SSHLibrary.Execute Command
        ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=8000 -r /tmp/coreboot.rom --ifd -i bios
    END
