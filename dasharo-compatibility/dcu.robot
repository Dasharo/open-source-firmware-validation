*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=30 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             FakerLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../pikvm-rest-api/pikvm_comm.robot
Resource            ../lib/options/dcu.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Prepare DCU Test Environment
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
DCU001.001 Change the UUID
    [Documentation]    This test case verifies that the UUID encoded in the DMI
    ...    table of an image can be changed using DCU.
    Skip If    not ${DCU_UUID_SUPPORT}    DCU001.001 not supported

    ${uuid}=    Uuid 4
    ${result}=    Run Process    bash    -c    cd ./dcu; ./dcuc smbios -u ${uuid} ./coreboot.rom
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${uuid_read}=    Get Firmware UUID
    Should Be Equal As Strings    '${uuid}'    '${uuid_read}'

DCU002.001 Change the serial number
    [Documentation]    This test case verifies that the serial number encoded
    ...    in the DMI table of an image can be changed using DCU.
    Skip If    not ${DCU_SERIAL_SUPPORT}    DCU002.001 not supported

    ${serial_no}=    Random Int    min=10000000    max=99999999
    ${result}=    Execute Command In Terminal    cd ./dcu; ./dcuc smbios -s ${serial_no} ./coreboot.rom; cd ..;
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Execute Reboot Command
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    ${serial_no_read}=    Get Firmware Serial Number
    Should Be Equal As Strings    '${serial_no}'    '${serial_no_read}'

DCU003.001 Change the bootsplash logo
    [Documentation]    This test case verifies that the bootsplash logo encoded
    ...    into an image can be changed using DCU.
    ...    PLEASE NOTE that a display device needs to be physically connected
    ...    to the DUT for this test to work.
    Skip If    not ${CUSTOM_LOGO_SUPPORT}    DCU003.001 not supported

    ${img_sum}=    Set Variable    f91fe017bef1f98ce292bde1c2c7c61edf7b51e9c96d25c33bfac90f50de4513
    ${result}=    Run Process    bash    -c    cd ./dcu; ./dcuc logo -l ./logo.bmp ./coreboot.rom
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Contain    ${result.stdout}    Success
    Flash Firmware    ./dcu/coreboot.rom

    Execute Reboot Command
    Boot System Or From Connected Disk    ubuntu
    Set Global Variable    ${DUT_CONNECTION_METHOD}    SSH
    Login To Linux
    Switch To Root User

    ${out}=    Execute Command In Terminal
    ...    sha256sum /sys/firmware/acpi/bgrt/image
    ${unplugged}=    Run Keyword And Return Status
    ...    Should Contain    ${out}    No such file
    IF    ${unplugged} == ${TRUE}
        Fail    Please make sure that a display device is connected to the DUT
    END
    Should Contain    ${out}    ${img_sum}

DCU004.001 Verify SMMSTORE changes (FW)
    [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and visible in EDK2.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    DCU004.001 not supported
    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Write SMMSTORE State 1

    Power On
    Check SMMSTORE State 1 (FW)

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Write SMMSTORE State 2
    
    Power On
    Check SMMSTORE State 2 (FW)

DCU004.001 Verify SMMSTORE changes (Self-test)
   [Documentation]    This test case verifies that changes made to the
    ...    SMMSTORE via DCU are properly applied and retrievable via DCU.
    Skip If    ${TESTS_IN_FIRMWARE_SUPPORT}
    Power On

    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Write SMMSTORE State 1

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check SMMSTORE State 1 (DCU)
    Write SMMSTORE State 2

    Power On
    Boot System Or From Connected Disk    ubuntu
    Login To Linux
    Switch To Root User
    Check SMMSTORE State 2 (DCU)


*** Keywords ***
Prepare DCU Test Environment
    Run    rm -rf dcu
    Run    git clone https://github.com/Dasharo/dcu

    Download To Host Cache
    ...    logo.bmp
    ...    https://cloud.3mdeb.com/index.php/s/rsjCdz4wSNesLio/download
    ...    6e5a6722955e4f78d947654630f27ff833703fbc04776ffed963c96617f6bb2a

    Run    cp ${FW_FILE} dcu/coreboot.rom
    Run    chmod -R a+rw dcu
    ${local_path}=    Join Path    ${DL_CACHE_DIR}    logo.bmp
    Run    cp ${local_path} dcu/logo.bmp


Write SMMSTORE State 1
    dcu.Set UEFI Option    NetworkBoot    Disabled

Check SMMSTORE State 1 (FW)
    @{option_path}=    Option Name To UEFI Path    NetworkBoot
    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${path_len}=    Get Length    ${option_path}
    FOR    ${i}    IN RANGE    ${path_len} - 1
        ${menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${menu}
        ...    ${option_path[${i}]}
    END
    ${state}=    Get Option State    ${menu}    ${option_path[${path_len}-1]}
    Should Be Equal    ${state}    ${False}

Check SMMSTORE State 1 (DCU)
    ${result}=    dcu.Get UEFI Option    NetworkBoot
    Should Be Equal    ${result}    Disabled

Write SMMSTORE State 2
   dcu.Set UEFI Option    NetworkBoot    Enabled

Check SMMSTORE State 2 (FW)
    @{option_path}=    Option Name To UEFI Path    NetworkBoot
    Power On
    ${menu}=    Enter Setup Menu Tianocore And Return Construction
    ${path_len}=    Get Length    ${option_path}
    FOR    ${i}    IN RANGE    ${path_len} - 1
        ${menu}=    Enter Submenu From Snapshot And Return Construction
        ...    ${menu}
        ...    ${option_path[${i}]}
    END
    ${state}=    Get Option State    ${menu}    ${option_path[${path_len}-1]}
    Should Be Equal    ${state}    ${True}

Check SMMSTORE State 2 (DCU)
    ${result}=    dcu.Get UEFI Option    NetworkBoot
    Should Be Equal    ${result}    Enabled