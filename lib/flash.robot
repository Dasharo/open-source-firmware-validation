*** Settings ***
Resource    ../keywords.robot


*** Keywords ***
Flash Via Internal Programmer With Args
    [Documentation]    Execute flashrom write operation on the given binary,
    ...    using extra arguments.
    [Arguments]    ${fw_file_path}    ${args}    ${timeout}=3m
    ${out_flash}=    Execute Command In Terminal
    ...    flashrom -p internal -c ${INTERNAL_PROGRAMMER_CHIPNAME} -w ${fw_file_path} ${args}
    ...    timeout=${timeout}
    IF    "Warning: Chip content is identical to the requested image." in """${out_flash}"""
        RETURN
    END
    ${success}=    Run Keyword And Return Status
    ...    Should Contain    ${out_flash}    VERIFIED
    IF    not ${success}
        Log    Retry flashing once again in case of failure
        ${out_flash}=    Execute Command In Terminal    flashrom -p internal -w ${fw_file_path} ${args}
        IF    "Warning: Chip content is identical to the requested image." in """${out_flash}"""
            RETURN
        END
        #    Should Contain    ${out_flash}    VERIFIED
    END
    RETURN    ${out_flash}

Flash Via Internal Programmer
    [Arguments]    ${fw_file_path}    ${region}=${EMPTY}
    ${out_flashrom_probe}=    Execute Command In Terminal    flashrom -p internal
    ${read_only}=    Run Keyword And Return Status
    ...    Should Contain    ${out_flashrom_probe}    read-only
    # TODO: automatically check and seck locs - reuse keywords from this suite, but it does not exist it seems
    IF    ${read_only}
        Fail    Make sure that SPI locks are disabled prior flashing internally
    END

    # If no region is given, flash the whole binary
    IF    "${region}" != "${EMPTY}"
        ${args}=    Set Variable    -N --ifd -i ${region}
    ELSE
        ${args}=    Set Variable    ${EMPTY}
    END
    Flash Via Internal Programmer With Args    ${fw_file_path}    ${args}

Check If RW SECTION B Is Present In A Firmware File
    [Documentation]    Parses ROM with cbfstool to check if A or A + B sections are there
    [Arguments]    ${fw_file_path}
    ${layout}=    Execute Command In Terminal    cbfstool ${fw_file_path} layout -w
    ${section_b_present}=    Run Keyword And Return Status
    ...    Should Contain    ${layout}    RW_SECTION_B
    Should Contain    ${layout}    RW_SECTION_A    msg=RW_SECTION_A is not present. Is the firmware image correct?
    RETURN    ${section_b_present}

Flash RW Sections Via Internal Programmer
    [Documentation]    Flash RW_SECTION_A and RW_SECTION_B (if possible) region
    ...    of flash using internal programmer. Requires that vboot-enabled
    ...    firmware is already flashed.
    [Arguments]    ${fw_file_path}
    ${section_b_present}=    Check If RW SECTION B Is Present In A Firmware File    ${fw_file_path}
    IF    ${section_b_present}
        Flash Via Internal Programmer With Args    ${fw_file_path}    -N --fmap -i RW_SECTION_A -i RW_SECTION_B
    ELSE
        Flash Via Internal Programmer With Args    ${fw_file_path}    -N --fmap -i RW_SECTION_A
    END

# TODO: below keywords are simply copied from keywords.robot. They might require some
# more cleanup/reduction.

Flash Firmware
    [Documentation]    Flash platform with firmware file specified in the
    ...    argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '''${file_size}''' != '''${FLASH_SIZE}'''
        FAIL    Image size doesn't match the flash chip's size!
    END

    IF    "${OPTIONS_LIB}"=="dcu"
        Make Sure That Flash Locks Are Disabled
        Send File To DUT    ${fw_file}    ${fw_file}
        Flash Via Internal Programmer    ${fw_file}    region='bios'
        RETURN
    END

    IF    '${FLASHING_METHOD}' == 'external'
        Rte Flash Write    ${fw_file}
    ELSE IF    '${FLASHING_METHOD}' == 'internal'
        Make Sure That Flash Locks Are Disabled
        Flash Via Internal Programmer    ${fw_file}    region=bios
    ELSE
        Fail    Flash firmware not implemented for platform config ${CONFIG}
    END

    # First boot after flashing may take longer than usual
    Set DUT Response Timeout    180s

Replace Logo In Firmware
    [Documentation]    Swap to custom logo in firmware on DUT using cbfstool according
    ...    to: https://docs.dasharo.com/guides/logo-customization
    [Arguments]    ${logo_file}
    Execute Command In Terminal    flashrom -p internal -r /tmp/firmware.rom
    # Remove the existing logo from the firmware image
    ${out}=    Execute Command In Terminal    cbfstool /tmp/firmware.rom remove -r BOOTSPLASH -n logo.bmp
    # Add your desired bootlogo to the firmware image
    ${out}=    Execute Command In Terminal
    ...    cbfstool /tmp/firmware.rom add -f ${logo_file} -r BOOTSPLASH -n logo.bmp -t raw -c lzma
    Should Not Contain    ${out}    Image is missing 'BOOTSPLASH' region
    Write BOOTSPLASH Region Internally    /tmp/firmware.rom

Read FMAP And BOOTSPLASH Regions Internally
    [Documentation]    Read BOOTSPLASH firmware on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux Command    flashrom -p internal --fmap -i FMAP -i BOOTSPLASH -r ${fw_file}    180
    Should Contain    ${out}    Reading flash... done

Write BOOTSPLASH Region Internally
    [Documentation]    Flash BOOTSPLASH firmware region on DUT using flashrom.
    [Arguments]    ${fw_file}
    ${out}=    Execute Linux Command    flashrom -p internal --fmap -i BOOTSPLASH -N -w ${fw_file}    180
    Should Contain Any    ${out}    VERIFIED    Chip content is identical to the requested image

Check Write Protection Availability
    [Documentation]    Check whether it is possible to set Write Protection
    ...    on the DUT.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-list
    Should Not Contain    ${out}    write protect support is not implemented for this flash chip
    Should Contain    ${out}    Available write protection ranges:
    Should Contain    ${out}    all

Erase Write Protection
    [Documentation]    Erase write protection from the flash chip.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-disable    180
    Should Contain    ${out}    Successfully set the requested mode
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-range=0,0    180
    Should Contain    ${out}    Successfully set the requested protection range

Set Write Protection
    [Documentation]    Set protection range as defined by the parameters:
    ...    `${start_adress}` -    protection start address,
    ...    `${length}` - flash protected range length.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-range=${start_adress},${length}    180
    Should Contain    ${out}    Successfully set the requested protection range
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-enable    180
    Should Contain    ${out}    Successfully set the requested mode

Check Write Protection Status
    [Documentation]    Check whether Write Protection mechanism is active.
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-status    180
    Should Contain    ${out}    Protection mode: hardware

Compare Write Protection Ranges
    [Documentation]    Allows to compare Protection Range: declared and
    ...    currently set.
    [Arguments]    ${start_adress}    ${length}
    ${out}=    Execute Linux Command    ./flashrom -p internal --wp-status    180
    ${protection_range}=    Get Lines Containing String    ${out}    Protection range:
    ${protection_range}=    Split String    ${protection_range}
    ${set_start_adress}=    Get From List    ${protection_range}    2
    ${set_start_adress}=    Fetch From Right    ${set_start_adress}    =
    ${set_length}=    Get From List    ${protection_range}    3
    ${set_length}=    Fetch From Right    ${set_length}    =
    IF    ${set_start_adress}!=${start_adress}
        FAIL    Declared and currently set protection start addresses are not the same
    END
    IF    ${set_length}!=${length}
        FAIL    Declared and currently set protection lengths are not the same
    END

Read Firmware
    [Documentation]    Read platform firmware to file specified in the argument.
    [Arguments]    ${file}

    IF    '${FLASHING_METHOD}' == 'external'
        Rte Flash Read    ${file}
    ELSE IF    '${FLASHING_METHOD}' == 'internal'
        # TODO
        Fail    Read firmware not implemented for platform config ${CONFIG}
    ELSE
        Fail    Read firmware not implemented for platform config ${CONFIG}
    END
