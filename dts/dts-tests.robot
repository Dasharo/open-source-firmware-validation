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
...                     Prepare Test Suite    AND
...                     Make Sure That Network Boot Is Enabled    AND
...                     Skip If    not ${DTS_SUPPORT}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Test Cases ***
PC Engines DES initial deployment (legacy -> UEFI) - no credentials
    [Documentation]    Verify DES (coreboot + UEFI) initial deployment logic on
    ...    PC Engines. We start from legacy firmware and insert no DES keys. No
    ...    firmware shall be offered, but we expect link to shop.

    Power On And Enter DTS Shell

    Execute Command In Terminal    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1" TEST_DES=n
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain
    ...    ${out}
    ...    DES version available, if you are interested, please visit https://shop.3mdeb.com/product-category/dasharo-entry-subscription/
    Log    ${out}
    Write Into Terminal    b

PC Engines DES initial deployment (legacy -> UEFI)
    [Documentation]    Verify DES (coreboot + UEFI) initial deployment logic on
    ...    PC Engines. We start from legacy firmware and insert correct DES keys for
    ...    UEFI variant.

    Power On And Enter DTS Shell

    Execute Command In Terminal    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1" TEST_DES=y DES_TYPE="UEFI"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    DES version
    Log    ${out}
    Write Into Terminal    d

    ${out}=    Read From Terminal Until    Does it match your actual specification? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Do you want to install Dasharo firmware on your hardware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

PC Engines DES initial deployment (legacy -> SeaBIOS)
    [Documentation]    Verify DES (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DES keys
    ...    for UEFI variant.

    Fail    msg=DES SeaBIOS must be supported in DTS first
    Power On And Enter DTS Shell

    # TODO: Pass this from command line when running test?
    ${meta_dts_path}=    Set Variable    /home/macpijan/projects/dts/yocto/meta-dts
    Variable Should Exist    ${meta_dts_path}

    # Deploy locally changed files to QEMU
    ${output}=    Run Process
    ...    cd ${meta_dts_path} && ./scripts/local-deploy.sh 127.0.0.1
    ...    shell=True
    ...    env:PORT=5222
    Log    ${output}

    Execute Command In Terminal    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1" TEST_DES=y DES_TYPE="SeaBIOS"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DES version
    Log    ${out}
    Write Into Terminal    d

    ${out}=    Read From Terminal Until    Does it match your actual specification? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Do you want to install Dasharo firmware on your hardware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

NCM transition (UEFI -> heads) - eligible UEFI version + heads credentials
    [Documentation]    Verify DES (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert correct DES keys for heads variant.

    Power On And Enter DTS Shell

    Execute Command In Terminal    export BOARD_VENDOR="Notebook" SYSTEM_MODEL="NV4xPZ" BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" TEST_DES=y DES_TYPE="heads"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    5
    Log    ${out}

    ${out}=    Read From Terminal Until    Would you like to switch to Dasharo heads firmware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Are you sure you want to proceed with update? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Does it match your actual specification? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Do you want to update Dasharo firmware on your hardware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Press any key to continue
    Should Contain    ${out}    Successfully switched to Dasharo Heads firmware
    Write Into Terminal    1
    Log    ${out}

    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

NCM transition (UEFI -> heads) - eligible UEFI version + no credentials
    [Documentation]    Verify DES (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert no DES keys, so we expect no update will be provided,
    ...    but a message encouraging subscription purchase should be visible.

    Power On And Enter DTS Shell

    Execute Command In Terminal    export BOARD_VENDOR="Notebook" SYSTEM_MODEL="NV4xPZ" BOARD_MODEL="NV4xPZ"
    Execute Command In Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" TEST_DES=n
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    Enter an option:
    Write Into Terminal    5
    Log    ${out}

    ${out}=    Read From Terminal Until    No update available for your machine
    Should Contain    ${out}    Dasharo heads firmware version is available. If you are interested,
    Should Contain    ${out}    please provide your subscription credentials in the main DTS menu
    Should Contain    ${out}    and select 'Update Dasharo firmware' again to check if you are eligible.
    Log    ${out}


*** Keywords ***
Power On And Enter DTS Shell
    Power On
    Boot Dasharo Tools Suite    iPXE
    # ssh server has to be turned on, in order to be able to scp the scripts
    Write Into Terminal    8
    Read From Terminal Until    Enter an option:
    Write Into Terminal    9
    Set Prompt For Terminal    bash-5.1#
    Read From Terminal Until Prompt
    Set DUT Response Timeout    90s

    # TODO: Pass this from command line when running test?
    ${meta_dts_path}=    Set Variable    /home/macpijan/projects/dts/yocto/meta-dts
    Variable Should Exist    ${meta_dts_path}    msg=See the comment in test file

    # Deploy locally changed files to QEMU
    ${output}=    Run Process
    ...    cd ${meta_dts_path} && ./scripts/local-deploy.sh 127.0.0.1
    ...    shell=True
    ...    env:PORT=5222
    Log    ${output}
