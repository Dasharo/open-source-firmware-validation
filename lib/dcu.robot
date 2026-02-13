*** Settings ***
Documentation       Library for using the Dasharo Configuration
...                 Utility tool to manage a firmware binary file.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../keywords.robot


*** Variables ***
${DCU_TEMP_FILENAME}=       osfv_dcu_temp.rom


*** Keywords ***
DCU Smbios Set UUID In File
    [Documentation]    Use DCU to set the UUID in a firmware file
    [Arguments]    ${fw_file}    ${uuid}
    ${path}    ${filename}=    Split Path    ${fw_file}
    Run    cp ${fw_file} dcu/${filename}
    Run    chmod a+rw dcu/${filename}

    ${result}=    Run    cd dcu; ./dcuc smbios -u ${uuid} ./${filename}; cd ..

    Log    ${result}
    Run    mv --force dcu/${filename} ${fw_file}
    Should Contain    ${result}    Success

DCU Smbios Set Serial In File
    [Documentation]    Use DCU to set the Serial number in a firmware file
    [Arguments]    ${fw_file}    ${serial}
    ${path}    ${filename}=    Split Path    ${fw_file}
    Run    cp ${fw_file} dcu/${filename}
    Run    chmod a+rw dcu/${filename}

    ${result}=    Run    cd dcu; ./dcuc smbios -s ${serial} ./${filename}; cd ..

    Log    ${result}
    Run    mv --force dcu/${filename} ${fw_file}
    Should Contain    ${result}    Success

DCU Logo Set In File
    [Documentation]    Use DCU to set the bootsplash logo in a firmware file
    [Arguments]    ${fw_file}    ${logo_file}
    ${path}    ${filename}=    Split Path    ${fw_file}
    ${logo_path}    ${logo_filename}=    Split Path    ${logo_file}
    Run    cp ${fw_file} dcu/${filename}
    Run    cp ${logo_file} dcu/${logo_filename}
    Run    chmod a+rw dcu/${filename}

    ${result}=    Run    cd dcu; ./dcuc logo -l ${logo_filename} ${filename}; cd ..

    Log    ${result}
    Run    cp dcu/${filename} ${fw_file}
    Should Contain    ${result}    Success

DCU Variable Read SMMSTORE
    [Documentation]    Read the UEFI SMMSTORE to work on the UEFI options in it
    [Arguments]    ${out_file}

    ${out}=    Execute Command In Terminal    flashrom -p internal -r ${DCU_TEMP_FILENAME} --fmap -i FMAP -i SMMSTORE
    Execute Command In Terminal    chmod 666 ${DCU_TEMP_FILENAME}
    Get File From DUT    ${DCU_TEMP_FILENAME}    ${out_file}

DCU Variable Flash SMMSTORE
    [Documentation]    Write the UEFI SMMSTORE to commit the changes
    [Arguments]    ${fw_file}
    Send File To DUT    ${fw_file}    ${DCU_TEMP_FILENAME}
    ${out}=    Execute Command In Terminal
    ...    flashrom -p internal -w ${DCU_TEMP_FILENAME} --fmap -i SMMSTORE --noverify-all

DCU Variable Get UEFI Option From File
    [Documentation]    Read an UEFI option value from FW file.
    [Arguments]    ${fw_file}    ${option_name}
    ${path}    ${filename}=    Split Path    ${fw_file}
    Run    cp ${fw_file} dcu/${filename}

    ${result}=    Run    cd dcu; ./dcuc v ${filename} --get "${option_name}"; cd ..

    Log    ${result}
    RETURN    ${result}

DCU Variable Set UEFI Option In File
    [Documentation]    Write an UEFI option value to FW file.
    [Arguments]    ${fw_file}    ${option_name}    ${value}
    ${path}    ${filename}=    Split Path    ${fw_file}
    Run    cp -f ${fw_file} dcu/${filename}
    Run    chmod a+rw dcu/${filename}
    ${value}=    Convert Option Value To DCU Format    ${value}

    ${result}=    Run    cd dcu; ./dcuc v ${filename} --set "${option_name}" --value "${value}"; cd ..

    Log    ${result}
    Run    cp -f dcu/${filename} ${fw_file}
    Should Contain    ${result}    Success

DCU Variable Set UEFI Option In DUT
    [Documentation]    Read, modify and flash the firmware with a new value of
    ...    a UEFI option
    [Arguments]    ${option_name}    ${value}
    DCU Variable Read SMMSTORE    ${DCU_TEMP_FILENAME}
    DCU Variable Set UEFI Option In File    ${DCU_TEMP_FILENAME}    ${option_name}    ${value}
    DCU Variable Flash SMMSTORE    ${DCU_TEMP_FILENAME}
    Execute Reboot Command

DCU Variable Get UEFI Option From DUT
    [Documentation]    Read the firmware and return a UEFI option value
    [Arguments]    ${option_name}
    DCU Variable Read SMMSTORE    ${DCU_TEMP_FILENAME}
    ${value}=    DCU Variable Get UEFI Option From File    ${DCU_TEMP_FILENAME}    ${option_name}
    ${value}=    Convert Option Value From DCU Format    ${value}
    RETURN    ${value}

Convert Option Value To DCU Format
    [Documentation]    Convert boolean values to their representation in DCU
    [Arguments]    ${value}
    IF    "${value}"=="${TRUE}"
        RETURN    Enabled
    ELSE
        IF    "${value}"=="${FALSE}"    RETURN    Disabled
    END
    RETURN    ${value}

Convert Option Value From DCU Format
    [Documentation]    Convert boolean values to their representation in DCU
    [Arguments]    ${value}
    IF    "${value}"=="Enabled"
        RETURN    ${TRUE}
    ELSE
        IF    "${value}"=="Disabled"    RETURN    ${FALSE}
    END

    RETURN    ${value}

Negate DCU Boolean
    [Documentation]    Negates a boolean in DCU format
    [Arguments]    ${value}
    IF    "${value}"=="Enabled"
        RETURN    Disabled
    ELSE
        IF    "${value}"=="Disabled"    RETURN    Enabled
    END
    Log    ${value} is not a valid DCU boolean value!    WARN
    RETURN    ${value}
