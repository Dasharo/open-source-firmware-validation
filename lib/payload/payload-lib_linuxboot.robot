*** Settings ***
Documentation       Payload library: LinuxBoot implementation of the
...                 firmware-specific boot flow. Implements the same payload
...                 interface as lib/payload/payload-lib_tianocore.robot so the
...                 generic boot keywords can drive a LinuxBoot platform without
...                 UEFI-specific menu navigation.
...
...                 Iteration 1 assumption: the platform is configured to
...                 automatically boot the desired OS, so the tests do not have
...                 to interact with the (interactive) LinuxBoot menu. Entering
...                 the menu to select a boot device will be implemented in a
...                 later iteration.

Library             Collections
Library             String
Resource            ../terminal.robot


*** Keywords ***
Payload Select Boot Device
    [Documentation]    LinuxBoot implementation of the payload boot-device
    ...    selection. In iteration 1 the platform auto-boots the default OS, so
    ...    there is no menu interaction to perform - the caller is expected to
    ...    wait for the OS to come up and log in.
    ...
    ...    === Arguments ===
    ...    - ``${env_id}`` - environment ID of the OS to boot
    ...    - ``${system_name}`` - boot menu entry name for that OS
    ...    - ``${boot_menu}`` - optional pre-read boot menu construction (unused)
    [Arguments]    ${env_id}    ${system_name}    ${boot_menu}=NOT_SET
    Log    LinuxBoot payload: relying on automatic boot to ${system_name} (${env_id}); no menu interaction performed.

Payload Enter Setup Menu
    [Documentation]    LinuxBoot has no UEFI-style setup menu.
    Skip    Entering a setup menu is not applicable on the LinuxBoot payload.

Payload Enter Setup Menu And Return Construction
    [Documentation]    LinuxBoot has no UEFI-style setup menu.
    Skip    Entering a setup menu is not applicable on the LinuxBoot payload.

Payload Enter Boot Menu And Return Construction
    [Documentation]    Entering the interactive LinuxBoot boot menu is not yet
    ...    implemented (iteration 1 relies on automatic boot).
    Skip    Entering the LinuxBoot boot menu is not implemented yet.

Payload Reset To Defaults
    [Documentation]    LinuxBoot has no UEFI-style setup menu to reset.
    Skip    Resetting settings to defaults is not applicable on the LinuxBoot payload.
