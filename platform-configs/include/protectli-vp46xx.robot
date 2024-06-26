*** Settings ***
Resource    protectli-pro.robot
Resource    protectli-common.robot


*** Variables ***
${FLASH_SIZE}=                      ${16*1024*1024}

${DEVICE_AUDIO1}=                   ALC897
${DEVICE_AUDIO2}=                   Kabylake HDMI
${DEVICE_AUDIO1_WIN}=               High Definition Audio Device
${INITIAL_CPU_FREQUENCY}=           2600
${MAX_CPU_TEMP}=                    82
${WATCHDOG_SUPPORT}=                ${TRUE}

# eMMC driver support
${E_MMC_NAME}=                      AJTD4R

${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.2.0
${DMIDECODE_RELEASE_DATE}=          03/13/2024

@{ETH_PERF_PAIR_2_G}=               enp5s0    enp6s0


*** Keywords ***
Power On
    RteCtrl Power Off    ${6}
    Sleep    5s
    Power Cycle On

Flash Protectli VP4630 External
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to ON state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Power Cycle On
    Sleep    5s
    RteCtrl Power Off
    Sleep    3s
    RteCtrl Set OC GPIO    2    low
    Sleep    2s
    RteCtrl Set OC GPIO    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    1    low
    Sleep    2s
    Power Cycle Off
    Sleep    2s
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom -c "MX25L12833F/MX25L12835F/MX25L12845E/MX25L12865E/MX25L12873F" 2>&1
    ...    return_rc=True
    Sleep    2s
    RteCtrl Set OC GPIO    3    high-z
    RteCtrl Set OC GPIO    1    high-z
    Power Cycle On
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED

Flash Protectli VP4650/VP4670 External
    [Documentation]    Flash Device Under Test firmware, check flashing result
    ...    and set RTE relay to ON state. Implementation must be
    ...    compatible with the theory of operation of a specific
    ...    platform.
    Sonoff Power On
    Sleep    5s
    RteCtrl Power Off
    Sleep    8s
    RteCtrl Set OC GPIO    2    low
    Sleep    2s
    RteCtrl Set OC GPIO    3    low
    Sleep    2s
    RteCtrl Set OC GPIO    1    low
    Sleep    2s
    Sonoff Power Off
    Sleep    3s    # Sleep    2s is too short for vp4670
    ${flash_result}    ${rc}=    SSHLibrary.Execute Command
    ...    flashrom -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom -c "MX25L12835F/MX25L12845E/MX25L12865E" 2>&1
    ...    return_rc=True
    Sleep    2s
    RteCtrl Set OC GPIO    1    high-z
    RteCtrl Set OC GPIO    3    high-z
    # CMOS reset
    RteCtrl Set OC GPIO    1    low
    Sleep    10s
    RteCtrl Set OC GPIO    1    high-z
    Sleep    2s
    Sonoff Power On
    IF    ${rc} != 0    Log To Console    \nFlashrom returned status ${rc}\n
    IF    ${rc} == 3    RETURN
    IF    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
        RETURN
    END
    Should Contain    ${flash_result}    VERIFIED
