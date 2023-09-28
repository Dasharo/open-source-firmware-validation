*** Settings ***
Library    ../keywords.py

*** Keywords ***
Flash SD Card Via SD Wire
    [Documentation]    This keyword flashes the SD card connected to the SD Wire
    ...    with the provided serial number.
    [Arguments]    ${file_bmap}    ${file_gz}    ${serial_number}
    SSHLibrary.Put File    ${file_bmap}    /data/    scp=ON
    SSHLibrary.Put File    ${file_gz}    /data/    scp=ON
    SSHLibrary.Execute Command    ./sonoff.sh off
    SSHLibrary.Execute Command    sd-mux-ctrl -e=${serial_number} --ts
    ${status}=    Get Status Of SD Wire    ${serial_number}
    Should Be Equal    ${status}    TS
    SSHLibrary.Execute Command    umount /dev/sda*
    ${bmap_name}=    Evaluate    "${file_bmap}".split("/")[-1]
    ${gz_name}=    Evaluate    "${file_gz}".split("/")[-1]
    ${output}=    SSHLibrary.Execute Command    bmaptool copy --bmap /data/${bmap_name} /data/${gz_name} /dev/sda
    SSHLibrary.Execute Command    sd-mux-ctrl -e=${serial_number} --dut
    ${status}=    Get Status Of SD Wire    ${serial_number}
    Should Be Equal    ${status}    DUT
    SSHLibrary.Execute Command    ./sonoff.sh on

Get List Of SD Wire Ids
    [Documentation]    This keyword connects to a RTE, and returns the list of
    ...    all id's of SD Wires that are currently connected.
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl --list
    ${lines}=    Split String    ${output}    \n
    ${sd_wire_list}=    Create List
    FOR    ${line}    IN    @{lines}
        ${fields}=    Split String    ${line}    ,
        ${length}=    Get Length    ${fields}
        IF    ${length}>1
            ${final_split}=    Split String    ${fields}[2]
            Append To List    ${sd_wire_list}    ${final_split}[1]
        END
    END
    RETURN    ${sd_wire_list}

Get Status Of SD Wire
    [Documentation]    Returns the status of the provided SD Wire Id. The status
    ...    is always DUT, TS, or if its anything else the test will fail.
    [Arguments]    ${serial_number}
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl -e=${serial_number} -u
    ${does_it_contain_dut}=    Evaluate    "DUT" in "${output}"
    ${does_it_contain_ts}=    Evaluate    "TS" in "${output}"
    IF    ${does_it_contain_dut}==True
        RETURN    DUT
    END
    IF    ${does_it_contain_ts}==True
        RETURN    TS
    END
    Fatal Error    SD Wire status not recognized: ${output}
