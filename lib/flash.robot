*** Keywords ***
Disable Firmware Flashing Prevention Options
    [Documentation]    Keyword makes sure firmware flashing is not prevented by
    ...    any Dasharo Security Options, if they are present.
    Power On
    ${setup_menu}=    Enter Setup Menu Tianocore And Return Construction
    ${dasharo_menu}=    Enter Dasharo System Features    ${setup_menu}
    ${index}=    Get Index Of Matching Option In Menu
    ...    ${dasharo_menu}    Dasharo Security Options
    IF    ${index} != -1
        ${security_menu}=    Enter Dasharo Submenu
        ...    ${dasharo_menu}    Dasharo Security Options
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Lock the BIOS boot medium
        IF    ${index} != -1
            Set Option State    ${security_menu}    Lock the BIOS boot medium    ${FALSE}
            Reenter Menu
        END
        ${index}=    Get Index Of Matching Option In Menu
        ...    ${security_menu}    Enable SMM BIOS write
        IF    ${index} != -1
            Set Option State    ${security_menu}    Enable SMM BIOS write    ${FALSE}
            Reenter Menu
        END
        Save Changes And Reset    2    4
    END

Flash Firmware
    [Documentation]    Flash platform with firmware file specified in the
    ...    argument. Keyword fails if file size doesn't match target
    ...    chip size.
    [Arguments]    ${fw_file}
    ${file_size}=    Run    ls -l ${fw_file} | awk '{print $5}'
    IF    '${file_size}'!='${FLASH_SIZE}'
        FAIL    Image size doesn't match the flash chip's size!
    END
    IF    '${DUT_CONNECTION_METHOD}' == 'Telnet'
        Put File    ${fw_file}    /tmp/coreboot.rom
    END
    Sleep    2s
    ${platform}=    Get Current RTE Param    platform
    IF    '${platform[:3]}' == 'apu'
        Flash Apu
    ELSE IF    '${platform[:13]}' == 'optiplex-7010'
        Flash Firmware Optiplex
    ELSE IF    '${platform[:8]}' == 'KGPE-D16'
        Flash KGPE-D16
    ELSE IF    '${platform[:10]}' == 'novacustom'
        Flash Device Via Internal Programmer    ${fw_file}
    ELSE IF    '${platform[:16]}' == 'protectli-vp4630'
        Flash Protectli VP4620 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp4650'
        Flash Protectli VP4650 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp4670'
        Flash Protectli VP4670 External
    ELSE IF    '${platform[:16]}' == 'protectli-vp2420'
        Flash Protectli VP2420 Internal
    ELSE IF    '${platform[:16]}' == 'protectli-vp2410'
        Flash Protectli VP2410 External
    ELSE IF    '${platform[:19]}' == 'msi-pro-z690-a-ddr5'
        Flash MSI-PRO-Z690-A-DDR5
    ELSE IF    '${platform[:24]}' == 'msi-pro-z690-a-wifi-ddr4'
        Flash MSI-PRO-Z690-A-WiFi-DDR4
    ELSE IF    '${platform[:46]}' == 'msi-pro-z790-p-ddr5'
        Flash MSI-PRO-Z790-P-DDR5
    ELSE
        Fail    Flash firmware not implemented for platform ${platform}
    END
    # First boot after flashing may take longer than usual
    Set DUT Response Timeout    180s

Replace Logo In Firmware
    [Documentation]    Swap to custom logo in firmware on DUT using cbfstool according
    ...    to: https://docs.dasharo.com/guides/logo-customization
    [Arguments]    ${logo_file}
    Read FMAP And BOOTSPLASH Regions Internally    /tmp/firmware.rom
    # Remove the existing logo from the firmware image
    ${out}=    Execute Linux Command    cbfstool /tmp/firmware.rom remove -r BOOTSPLASH -n logo.bmp
    # Add your desired bootlogo to the firmware image
    ${out}=    Execute Linux Command
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
