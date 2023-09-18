*** Settings ***
Resource    ../keywords.robot


*** Keywords ***
Flash Via Internal Programmer With Args
    [Documentation]    Execute flashrom write operation on the given binary,
    ...    using extra arguments.
    [Arguments]    ${fw_file_path}    ${args}    ${timeout}=3m
    ${out_flash}=    Execute Command In Terminal
    ...    flashrom -p internal -w ${fw_file_path} ${args}
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
        Should Contain    ${out_flash}    VERIFIED
    END
    RETURN    ${out_flash}

Flash BIOS Region Via Internal Programmer
    [Arguments]    ${fw_file_path}
    ${out_flashrom_probe}=    Execute Command In Terminal    flashrom -p internal
    ${read_only}=    Run Keyword And Return Status
    ...    Should Contain    ${out_flashrom_probe}    read-only
    # TODO: automatically check and seck locs - reuse keywords from this suite, but it does not exist it seems
    IF    ${read_only}
        Fail    Make sure that SPI locks are disabled prior flashing internally
    END
    Flash Via Internal Programmer With Args    ${fw_file_path}    -N --ifd -i bios

Check If RW SECTION B Is Present In A Firmware File
    [Documentation]    Parses ROM with cbfstool to check if A or A + B sections are there
    [Arguments]    ${fw_file_path}
    ${result}=    Execute Command In Terminal    cbfstool ${fw_file_path} layout -w | grep --color=never RW_SECTION_B
    ${section_b_present}=    Run Keyword And Return Status
    ...    Should Contain    ${result}    RW_SECTION_B
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
