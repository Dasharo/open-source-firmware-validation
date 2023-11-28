*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../rtectrl-rest-api/rtectrl.robot
Resource            ../sonoff-rest-api/sonoff-api.robot
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Download ISO And Mount As USB
...                     ${DL_CACHE_DIR}/dts-base-image-v1.2.8.iso
...                     ${DTS_URL}
...                     f42b59633dbcc16ecbd7c98a880c582c5235c22626d7204202c922f3a7fa231b
...                     AND
...                     Make Sure That Network Boot Is Enabled
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DTS001.001 Booting DTS from USB works correctly
    [Documentation]    This test aims to verify that DTS is properly booting
    ...    from USB.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS001.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS001.001 not supported

    Power On
    Boot Dasharo Tools Suite    USB

DTS002.001 DTS option Creating Dasharo HCL report works correctly
    [Documentation]    This test aims to verify that the option Dasharo HCL
    ...    report in the DTS menu properly creates the report.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS002.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS002.001 not supported
    # Not supported due to SSH authorization error while sending the report
    Skip    ns
    Power On
    Boot Dasharo Tools Suite    iPXE
    Check HCL Report Creation

DTS003.001 DTS option reboot DUT works correctly
    [Documentation]    This test aims to verify that the option Reboot system
    ...    in the DTS menu reboots the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS004.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS004.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Sleep    3s
    Write Into Terminal    11
    Read From Terminal Until    ${TIANOCORE_STRING}

DTS004.001 DTS accessing shell works correctly
    [Documentation]    This test aims to verify that shell can be accessed in
    ...    DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS005.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS005.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    IF    '${DUT_CONNECTION_METHOD}' == 'pikvm'
        # Since Telnet and PiKVM go out of sync with the on-screen shell:
        Write Into Terminal    8
        Login To Linux Via SSH Without Password    root    root@DasharoToolsSuite
    ELSE
        Write Into Terminal    9
        Read From Terminal Until    bash-5.1#
    END

DTS005.001 Flash device from DTS shell by using flashrom works correctly
    [Documentation]    This test aims to verify whether is the possibility to
    ...    flash the DUT firmware by using flashrom in DTS Shell.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS006.001 not supported
    Skip If    not ${DTS_FIRMWARE_FLASHING_SUPPORT}    DTS006.001 not supported

    Power On
    Disable Firmware Flashing Prevention Options
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Set DUT Response Timeout    320s
    Flash Firmware In DTS
    Power On
    Make Sure That Network Boot Is Enabled
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check Firmware Version

DTS006.001 Flash device EC firmware by using DTS built-in script works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to flash the DUT EC firmware by using the built-in
    ...    script in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS008.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS008.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Run EC Transition
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version

DTS007.001 Update device EC firmware by using DTS works correctly
    [Documentation]    This test aims to verify whether there is the
    ...    possibility to update the DUT EC firmware by using system76_ectool
    ...    in DTS.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS009.001 not supported
    Skip If    not ${DTS_EC_FLASHING_SUPPORT}    DTS009.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Flash EC Firmware
    Set DUT Response Timeout    320s
    Power On
    Boot Dasharo Tools Suite    iPXE
    Enter Shell In DTS
    Check EC Firmware Version

DTS008.001 DTS option power-off DUT works correctly
    [Documentation]    This test aims to verify that the option Power off
    ...    system in the DTS menu turns off the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DTS003.001 not supported
    Skip If    not ${DTS_SUPPORT}    DTS003.001 not supported

    Power On
    Boot Dasharo Tools Suite    iPXE
    Sleep    3s
    Write Into Terminal    10
    Set DUT Response Timeout    30s
    ${output}=    Run Keyword And Return Status
    ...    Read From Terminal Until    ${TIANOCORE_STRING}
    Should Not Be True    ${output}
