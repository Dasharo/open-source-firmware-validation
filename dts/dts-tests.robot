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
Resource            ../variables.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite    AND
...                     Skip If    not ${DTS_SUPPORT}
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${DTS_CHECKPOINT}=      Enter an option:


*** Test Cases ***
PC Engines DPP initial deployment (legacy -> UEFI) - no credentials
    [Documentation]    Verify DPP (coreboot + UEFI) initial deployment logic on
    ...    PC Engines. We start from legacy firmware and insert no DPP keys. No
    ...    firmware shall be offered, but we expect link to shop.

    Power On And Enter DTS Shell

    Execute Command In Terminal
    ...    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2" SYSTEM_VENDOR="PC Engines"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + UEFI) available, if you are interested, please visit https://shop.3mdeb.com/product-category/dasharo-entry-subscription/
    Should Contain
    ...    ${out}
    ...    DPP version (coreboot + SeaBIOS) available, if you are interested, please visit https://shop.3mdeb.com/product-category/dasharo-entry-subscription/
    Log    ${out}
    Write Into Terminal    b

PC Engines DPP initial deployment (legacy -> UEFI)
    [Documentation]    Verify DPP (coreboot + UEFI) initial deployment logic on
    ...    PC Engines. We start from legacy firmware and insert correct DPP keys for
    ...    UEFI variant.

    Power On And Enter DTS Shell

    Execute Command In Terminal
    ...    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2" SYSTEM_VENDOR="PC Engines"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1" DPP_TYPE="UEFI"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    d) DPP version (coreboot + UEFI)
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

PC Engines DPP initial deployment (legacy -> SeaBIOS)
    [Documentation]    Verify DPP (coreboot + SeaBIOS) initial deployment logic
    ...    on PC Engines. We start from legacy firmware and insert correct DPP keys
    ...    for UEFI variant.

    Power On And Enter DTS Shell

    Execute Command In Terminal
    ...    export BOARD_VENDOR="PC Engines" SYSTEM_MODEL="APU2" BOARD_MODEL="APU2" SYSTEM_VENDOR="PC Engines"
    Execute Command In Terminal    export BIOS_VERSION="v4.19.0.1" DPP_TYPE="seabios"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    Enter an option:
    Should Contain    ${out}    s) DPP version (coreboot + SeaBIOS)
    Log    ${out}
    Write Into Terminal    s

    ${out}=    Read From Terminal Until    Does it match your actual specification? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Do you want to install Dasharo firmware on your hardware? (Y|n)
    Write Into Terminal    Y
    Log    ${out}

    ${out}=    Read From Terminal Until    Rebooting
    Log    ${out}

NCM transition (UEFI -> heads) - eligible UEFI version + heads credentials
    [Documentation]    Verify DPP (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert correct DPP keys for heads variant.

    Power On And Enter DTS Shell

    Execute Command In Terminal
    ...    export BOARD_VENDOR="Notebook" SYSTEM_MODEL="NV4xPZ" BOARD_MODEL="NV4xPZ" SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2" DPP_TYPE="heads"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
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
    [Documentation]    Verify DPP (coreboot + heads) transition logic on NovaCustom NV4X ADL.
    ...    We start from Dasharo (coreboot + UEFI) firmware with version that should
    ...    allow for the transition. We insert no DPP keys, so we expect no update will be provided,
    ...    but a message encouraging subscription purchase should be visible.

    Power On And Enter DTS Shell

    Execute Command In Terminal
    ...    export BOARD_VENDOR="Notebook" SYSTEM_MODEL="NV4xPZ" BOARD_MODEL="NV4xPZ" SYSTEM_VENDOR="Notebook"
    Execute Command In Terminal    export BIOS_VERSION="Dasharo (coreboot+UEFI) v1.7.2"
    Write Into Terminal    dts-boot

    ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    2
    Log    ${out}

    ${out}=    Read From Terminal Until    No update available for your machine
    Should Contain    ${out}    Dasharo heads firmware version is available. If you are interested,
    Should Contain    ${out}    please provide your subscription credentials in the main DTS menu
    Should Contain    ${out}    and select 'Update Dasharo firmware' again to check if you are eligible.
    Log    ${out}

DTS DPP package
    [Documentation]    TBD

    Fail    TBD: We need to manually enter keys here
    # Power On And Enter DTS Shell

    # Execute Command In Terminal    export DPP_TYPE="dts-pkg"
    # Write Into Terminal    dts-boot

    # ${out}=    Read From Terminal Until    ${DTS_CHECKPOINT}
    # Write Into Terminal    2
    # Log    ${out}

    # ${out}=    Read From Terminal Until    No update available for your machine
    # Should Contain    ${out}    Dasharo heads firmware version is available. If you are interested,
    # Should Contain    ${out}    please provide your subscription credentials in the main DTS menu
    # Should Contain    ${out}    and select 'Update Dasharo firmware' again to check if you are eligible.
    # Log    ${out}


*** Keywords ***
Power On And Enter DTS Shell
    Power On
    Boot Dasharo Tools Suite    USB
    # Boot Dasharo Tools Suite    iPXE

    # ssh server has to be turned on, in order to be able to scp the scripts
    # DTS v1.x.y
    # Write Into Terminal    8
    # Read From Terminal Until    Enter an option:
    # Write Into Terminal    9

    Write Into Terminal    K
    Read From Terminal Until    Press any key to continue
    Press Enter
    Read From Terminal Until    ${DTS_CHECKPOINT}
    Write Into Terminal    S

    Set Prompt For Terminal    bash-5.2#
    Read From Terminal Until Prompt
    Set DUT Response Timeout    90s
