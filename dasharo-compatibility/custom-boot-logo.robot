*** Settings ***
Library             Collections
Library             Dialogs
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${CUSTOM_LOGO_SUPPORT}    Custom boot logo not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
CLG001.001 Custom boot logo
    [Documentation]    Verify that a custom boot logo can be set and is displayed
    ...    during the boot process.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    CLG001.001 not supported
    Execute Manual Step    [1/2] Power on the DUT.
    Execute Manual Step    [2/2] Wait for the boot logo to appear.
    VAR    ${result_msg}=
    ...    [Expected result] The displayed logo should depend on the Dasharo variant:
    ...    if the Dasharo variant is NovaCustom - the NovaCustom logo should be displayed,
    ...    if the Dasharo variant is Protectli - the Protectli logo should be displayed,
    ...    if the Dasharo variant is Tuxedo - the Tuxedo logo should be displayed,
    ...    for all other variants Dasharo custom logo should be displayed.
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}

LCM001.001 Replace logo in existing image and flashing firmware
    [Documentation]    Check whether a custom logo can be injected into an existing firmware image and flashed.
    Execute Manual Step    [1/10] Power on the DUT.
    Execute Manual Step    [2/10] Hold the BOOT_MENU_KEY to enter the boot menu.
    Execute Manual Step    [3/10] Select the iPXE Network boot option using the arrow keys and press Enter.
    Execute Manual Step    [4/10] Select the iPXE Shell option using the arrow keys and press Enter.
    Execute Manual Step    [5/10] Configure communication interface by using the following command: dhcp
    VAR    ${chain_msg}=
    ...    [6/10] Connect to the DTS ipxe menu by using the following command:
    ...    chain http://boot.3mdeb.com/dts.ipxe
    ...    separator=${SPACE}
    Execute Manual Step    ${chain_msg}
    Execute Manual Step    [7/10] Wait for "Enter an option:".
    Execute Manual Step    [8/10] Type in S and press Enter.
    Execute Manual Step    [9/10] Based on the dedicated documentation replace the logo in an existing image.
    Execute Manual Step    [10/10] Reboot the DUT and observe the boot logo.
    Execute Manual Step    [Expected result] During the DUT booting process, custom logo should appear on the screen.

LCM002.001 Build image with custom logo and flashing firmware
    [Documentation]    Check whether a custom logo can be built into firmware and flashed.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step    [4/6] Based on the dedicated documentation build firmware with the custom logo.
    VAR    ${flash_msg}=
    ...    [5/6] Flash the firmware by using the internal programmer and flashrom tool.
    ...    If DUT is already flashed with the Dasharo firmware and only the logo should be replaced, use:
    ...    sudo flashrom -p internal --fmap -i BOOTSPLASH -w [path].
    ...    If also the firmware update procedure should be performed, use:
    ...    flashrom -p internal -w [path-to-binary] --fmap -i RW_SECTION_A.
    ...    In any other cases, use: flashrom -p internal -w [path-to-binary] --ifd -i bios.
    ...    separator=${SPACE}
    Execute Manual Step    ${flash_msg}
    Execute Manual Step    [6/6] Reboot DUT.
    Execute Manual Step    [Expected result] During the DUT booting process, custom logo should appear on the screen.

LCM003.001 Attempt to flash firmware with improper image
    [Documentation]    Check that flashing firmware with a logo that does not meet quality criteria results in the default logo being shown.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot into the system.
    Execute Manual Step    [3/6] Log into the system by using the proper login and password.
    Execute Manual Step
    ...    [4/6] Based on the dedicated documentation build firmware with the logo, that does not meet the Quality criteria.
    VAR    ${flash_msg}=
    ...    [5/6] Flash the firmware by using the internal programmer and flashrom tool.
    ...    If DUT is already flashed with the Dasharo firmware and only the logo should be replaced, use:
    ...    sudo flashrom -p internal --fmap -i BOOTSPLASH -w [path].
    ...    If also the firmware update procedure should be performed, use:
    ...    flashrom -p internal -w [path-to-binary] --fmap -i RW_SECTION_A.
    ...    In any other cases, use: flashrom -p internal -w [path-to-binary] --ifd -i bios.
    ...    separator=${SPACE}
    Execute Manual Step    ${flash_msg}
    Execute Manual Step    [6/6] Reboot DUT.
    Execute Manual Step
    ...    [Expected result] During the DUT booting process, the default logo should appear on the screen.

LCM004.001 Custom logo persists after firmware update
    [Documentation]    Check whether a custom logo persists after a firmware update.
    Execute Manual Step    [1/6] Power on the DUT.
    Execute Manual Step    [2/6] Boot Dasharo Tools Suite.
    Execute Manual Step    [3/6] Type in 9 to gain shell access.
    Execute Manual Step    [4/6] Based on the dedicated documentation replace the logo in an existing image.
    Execute Manual Step    [5/6] Run dasharo-deploy update.
    Execute Manual Step    [6/6] Reboot the DUT and observe the boot logo.
    VAR    ${result_msg}=
    ...    [Expected result] During the DUT booting process, the custom logo replacement should be displayed.
    ...    separator=${SPACE}
    Execute Manual Step    ${result_msg}
