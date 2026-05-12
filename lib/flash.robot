*** Settings ***
Resource    ../keywords.robot
Resource    custom_bootentries.robot


*** Keywords ***
Flash Via Internal Programmer With Args
    [Documentation]    Execute flashrom write operation on the given binary,
    ...    using extra arguments.
    [Arguments]    ${fw_file_path}    ${args}    ${timeout}=5m
    IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        # Then the platform configuration depends on the bootorder to stay the same.
        # We must copy the current smmstore to the target binary in order to prevent
        # it being overwritten.
        VAR    ${smm_file}=    /tmp/smmstore.rom
        VAR    ${replaced_bootorder_file}=    replaced_bootorder_coreboot.rom
        ${custom_bootname}=    Get Custom Bootentry Name    ${DEFAULT_BOOT_OS_ID}
        @{custom_bootid}=    Get Bootnums For Label    ${custom_bootname}
        Should Not Be Empty
        ...    ${custom_bootid}
        ...    Basic Platform Setup was not run, Custom DEFAULT_BOOT bootentry does not exist.
        Execute Command In Terminal    flashrom -p internal -r ${smm_file} --fmap -i FMAP -i SMMSTORE
    END
    ${cpuinfo}=    Execute Command In Terminal    cat /proc/cpuinfo
    IF    "AuthenticAMD" not in """${cpuinfo}"""
        # Always flash FD first in case the layout changes
        ${out_flash}=    Execute Command In Terminal
        ...    flashrom -p internal -c "${INTERNAL_PROGRAMMER_CHIPNAME}" -w ${fw_file_path} --ifd -i fd
        ...    timeout=${timeout}
    END
    ${out_flash}=    Execute Command In Terminal
    ...    flashrom -p internal -c "${INTERNAL_PROGRAMMER_CHIPNAME}" -w ${fw_file_path} ${args}
    ...    timeout=${timeout}
    IF    "Warning: Chip content is identical to the requested image." in """${out_flash}"""
        RETURN
    END
    Should Contain    ${out_flash}    VERIFIED
    IF    '${OPTIONS_LIB}' == 'options-lib_dcu'
        # Then restore smmstore (UEFI variables)
        ${out_flash}=    Execute Command In Terminal
        ...    flashrom -p internal -c "${INTERNAL_PROGRAMMER_CHIPNAME}" -w ${smm_file} --fmap -i FMAP -i SMMSTORE
        ...    timeout=${timeout}
    END

Flash Via Internal Programmer
    [Arguments]    ${fw_file_path}    @{regions}
    ${out_flashrom_probe}=    Execute Command In Terminal    flashrom -p internal
    ${read_only}=    Run Keyword And Return Status
    ...    Should Contain    ${out_flashrom_probe}    read-only
    ${filename}=    Evaluate    os.path.basename(r"${fw_file_path}")
    Send File To DUT    ${fw_file_path}    /tmp/${filename}
    # TODO: automatically check and seck locs - reuse keywords from this suite, but it does not exist it seems
    IF    ${read_only}
        Fail    Make sure that SPI locks are disabled prior flashing internally
    END

    # If no region is given, flash the whole binary
    IF    @{regions}
        VAR    ${args}=    -N --ifd
        FOR    ${region}    IN    @{regions}
            VAR    ${args}=    ${args} -i ${region}
        END
    ELSE
        VAR    ${args}=    ${EMPTY}
    END
    Wait Until Keyword Succeeds    2x
    ...    1s
    ...    Flash Via Internal Programmer With Args    /tmp/${filename}    ${args}

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
    IF    '${FLASHING_METHOD}'=='none'    RETURN

    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '''${file_size}''' != '''${FLASH_SIZE}'''
        FAIL    Image size doesn't match the flash chip's size!
    END

    IF    '${FLASHING_METHOD}' == 'external'
        Rte Flash Write    ${fw_file}
    ELSE IF    '${FLASHING_METHOD}' == 'internal'
        Make Sure That Flash Locks Are Disabled
        Power On
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${cpuinfo}=    Execute Command In Terminal    cat /proc/cpuinfo
        IF    "AuthenticAMD" in """${cpuinfo}"""
            Flash Via Internal Programmer    ${fw_file}
        ELSE
            VAR    @{regions}=    bios
            IF    ${INTEL_CBNT_BOOTGUARD_FUSING_SUPPORT}
                VAR    @{regions}=    @{regions}    me
            END
            Flash Via Internal Programmer    ${fw_file}    @{regions}
        END
    END

    IF    '''${POWER_CTRL}''' == '''none'''
        Power On
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        Execute Reboot Command
        Sleep    30s    Additional sleep for RAM training etc. after flashing
    END

    # First boot after flashing may take longer than usual
    Set DUT Response Timeout    300s

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
        IF    '${APU_FLASH_WP_GPIO}' != '${TBD}'
            Rte Gpio Set    ${APU_FLASH_WP_GPIO}    low
        END
        Rte Flash Read    ${file}
        IF    '${APU_FLASH_WP_GPIO}' != '${TBD}'
            Rte Gpio Set    ${APU_FLASH_WP_GPIO}    high-z
        END
    ELSE IF    '${FLASHING_METHOD}' == 'internal'
        # TODO
        Power On
        Boot System Or From Connected Disk    ${DEFAULT_BOOT_OS_ID}
        Login To Linux
        Switch To Root User
        Execute Command In Terminal    flashrom -p internal --ifd -i fd -i bios -i me -r coreboot.rom
        Get File From DUT    coreboot.rom    ${file}
    ELSE
        Fail    Read firmware not implemented for platform config ${CONFIG}
    END

Get Flashrom FMAP Regions
    ${output}=    Execute Command In Terminal    flashrom -p internal -r coreboot.rom    timeout=300s
    ${output}=    Execute Command In Terminal    cbfstool coreboot.rom layout -w
    ${lines}=    Split To Lines    ${output}
    VAR    &{dict}=    &{EMPTY}
    FOR    ${l}    IN    @{lines}
        ${m}=    Get Regexp Matches
        ...    ${l}
        ...    ^'([A-Z_]+)' \\(([a-zA-Z_\-]+, )?size ([0-9]+), offset ([0-9]+)\\)$
        ...    1
        ...    2
        ...    3
        ...    4

        IF    ${m} != []
            VAR    ${name}=    ${m}[0][0]
            VAR    ${type}=    ${m}[0][1]
            VAR    ${size}=    ${m}[0][2]
            VAR    ${offset}=    ${m}[0][3]
            ${start}=    Evaluate    ${offset}
            ${end}=    Evaluate    ${start} + ${size}

            VAR    &{region}=    start=${start}    end=${end}    type=${type}
            Set To Dictionary    ${dict}    ${name}=${region}
        END
    END
    RETURN    ${dict}

Get Flashrom Regions
    ${output}=    Execute Command In Terminal    flashrom -p internal
    ${lines}=    Split To Lines    ${output}
    VAR    &{dict}=    &{EMPTY}
    FOR    ${l}    IN    @{lines}
        ${m}=    Get Regexp Matches
        ...    ${l}
        ...    FREG[0-9]+: (.+) region \\((0x[0-9a-f]+)-(0x[0-9a-f]+)\\) is (.+)
        ...    1
        ...    2
        ...    3
        ...    4
        IF    ${m} != []
            VAR    ${name}=    ${m}[0][0]
            VAR    ${start}=    ${m}[0][1]
            VAR    ${end}=    ${m}[0][2]
            VAR    ${state}=    ${m}[0][3]
            ${start}=    Evaluate    int(${start})
            ${end}=    Evaluate    int(${end})
            VAR    &{region}=    start=${start}    end=${end}    state=${state}
            Set To Dictionary    ${dict}    ${name}=${region}
        END
    END
    RETURN    ${dict}

Get Flashrom Readonly Offsets
    ${output}=    Execute Command In Terminal    flashrom -p internal
    ${lines}=    Split To Lines    ${output}
    VAR    @{list}=    @{EMPTY}
    FOR    ${l}    IN    @{lines}
        ${m}=    Get Regexp Matches    ${l}    Warning: (0x[0-9a-f]+)-(0x[0-9a-f]+) is read-only    1    2
        IF    ${m} != []
            ${start}=    Evaluate    int(${m[0][0]})
            ${end}=    Evaluate    int(${m[0][1]}) + 1    # inclusive
            VAR    &{region}=    start=${start}    end=${end}
            Append To List    ${list}    ${region}
        END
    END
    RETURN    ${list}

Calculate Expected Flashrom Readonly Region
    [Tags]    robot:private
    [Arguments]    ${region_name}    ${start_offset}    ${end_offset}
    ${flashrom_regions}=    Get Flashrom Regions
    ${bios_start}=    Get From Dictionary    ${flashrom_regions['${region_name}']}    start
    ${bios_end}=    Get From Dictionary    ${flashrom_regions['${region_name}']}    end
    ${expected_readonly_start}=    Evaluate    ${bios_start} + ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.start}
    ${expected_readonly_end}=    Evaluate    ${bios_start} + ${COREBOOT_REDUNDANT_BOOT_BOOTBLOCK_OFFSET.end}
    VAR    &{expected_readonly}=    start=${expected_readonly_start}    end=${expected_readonly_end}
    RETURN    ${expected_readonly}

Verify Region Range Protected
    [Arguments]    ${region_name}    ${expected_start}    ${expected_end}
    ${readonly_regions}=    Get Flashrom Readonly Offsets
    IF    len(${readonly_regions}) == 0
        Fail    No readonly regions found in flashrom output
    END

    ${expected_readonly_bootblock}=    Calculate Expected Flashrom Readonly Region
    ...    region_name=${region_name}
    ...    start_offset=${expected_start}
    ...    end_offset=${expected_end}

    VAR    ${expected_readonly_found}=    ${FALSE}
    FOR    ${region}    IN    @{readonly_regions}
        Log To Console    Found readonly region: ${region}
        Log To Console    Expected readonly region: ${expected_readonly_bootblock}
        ${start_matches}=    Evaluate    ${region['start']} == ${expected_readonly_bootblock['start']}
        ${end_matches}=    Evaluate    ${region['end']} == ${expected_readonly_bootblock['end']}
        IF    ${start_matches} and ${end_matches}
            VAR    ${expected_readonly_found}=    ${TRUE}
            BREAK
        END
    END
    IF    not ${expected_readonly_found}
        Fail    Expected readonly region ${expected_readonly_bootblock} not found in flashrom output
    END

Flashrom Verify FMAP Regions Protected
    [Arguments]    @{region_names}
    ${fmap_regions}=    Get Flashrom FMAP Regions
    ${protected_offsets}=    Get Flashrom Readonly Offsets
    VAR    @{failed_regions}=    @{EMPTY}

    FOR    ${region_name}    IN    @{region_names}
        ${region}=    Get From Dictionary    ${fmap_regions}    ${region_name}    default=${None}
        IF    $region is ${None}
            Fail    Region ${region_name} does not exist in the FMAP
        END
        VAR    ${protected}=    ${FALSE}
        FOR    ${offsets}    IN    @{protected_offsets}
            IF    ${offsets.start} <= ${region.start} and ${offsets.end} >= ${region.end}
                VAR    ${protected}=    ${TRUE}
                BREAK
            END
        END
        IF    not ${protected}
            Set To Dictionary    ${region}    name=${region_name}
            Append To List    ${failed_regions}    ${region}
        END
    END

    IF    len($failed_regions) > 0
        FOR    ${region}    IN    @{failed_regions}
            Log To Console    Region ${region.name}(${region.start}-${region.end}) is not protected!
        END
        Log To Console    Protected ranges: ${protected_offsets}
        Fail    Not every region is protected.
    END
