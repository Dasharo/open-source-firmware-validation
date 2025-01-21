*** Settings ***
Documentation       Library for UEFI configuration using Dasharo Configuration
...                 Utility tool. Commonly used when serial port is not
...                 available.

Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             SSHLibrary
Resource            ../terminal.robot
Resource            ../../keywords.robot
Resource            ../cbmem.robot
Resource            ../dcu.robot


*** Keywords ***
Set UEFI Option
    [Documentation]
    ...    Sets an UEFI option.
    ...    Implementations in ``/lib/options/``
    ...    At this moment the implementations are not completely device-agnostic
    ...    and might have additional requirements/side effects. Check the
    ...    implementations' documentation for details.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    - ``${option_name}``: ``string`` - The name of the UEFI option. Can
    ...    be one of the names defined in lib/bios/menus.py "getoptionpath"
    ...    dictionary
    ...    - ``${value}``: ``string or boolean`` - The value to set.
    ...    - For boolean options: either ``${TRUE}`` or ``${FALSE}``
    ...    - For numeric options: a numeric string, like ``1234``
    ...    - For lists: the exact value of the list item, like ``Set UEFI Option    ActiveECores    All active``
    ...
    ...    === Return Value ===
    ...    - ``boolean`` - The result. ``${TRUE}`` if options was changed, ``${FALSE}``
    ...    if it was not. ``${FALSE}`` can mean that the option was already in the
    ...    requested state.
    ...
    ...    === Side Effects ===
    ...    - The device gets rebooted
    ...    - The UEFI option ``${option_name}`` is set to ``${value}``
    [Arguments]    ${option_name}    ${value}

    Fail    Not implemented

Get UEFI Option
    [Documentation]
    ...    Gets the value of an UEFI option.
    ...    Implementations in ``/lib/options/``
    ...    At this moment the implementations are not completely device-agnostic
    ...    and might have additional requirements/side effects. Check the
    ...    implementations' documentation for details.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    - ``${option_name}``: ``string`` - The name of the UEFI option. Can
    ...    be one of the names defined in ``lib/bios/menus.py`` ``getoptionpath``
    ...    dictionary
    ...
    ...    === Return Value ===
    ...    - ``string or boolean`` - The value of the option.
    ...    - Boolean ``${TRUE}``/``${FALSE}`` for boolean options
    ...    - String for numeric and list options
    ...
    ...    === Side Effects ===
    ...    - The device might get rebooted, depending on implementation
    [Arguments]    ${option_name}
    Fail    Not implemented

Reset UEFI Options To Defaults
    [Documentation]
    ...    Resets all the UEFI options to their default values
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Side Effects ===
    ...    - All the UEFI options are reset to the defaults. Make sure the
    ...    default value of ``SerialRedirection`` is set to Enabled if using
    ...    Telnet/Serial
    ...    - The device gets rebooted
    Fail    Not implemented

Get UEFI Boot Manager Entries
    [Documentation]
    ...    Reads the Boot Manager entries
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    - ``string`` - The boot menu entries, separated with newlines
    ...
    ...    === Side Effects ===
    ...    - The device might get rebooted, depending on implementation
    Fail    Not implemented

Measure Coldboot Time
    [Documentation]
    ...    Performs a measurement of average coldboot
    ...    boot time
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    - ``${iterations}``: ``integer`` - the amount of coldboots
    ...    to be tested
    ...
    ...    === Return Value ===
    ...    - ``float`` - MIN coldboot time
    ...    - ``float`` - MAX coldboot time
    ...    - ``float`` - Average coldboot time
    ...    - ``float`` - Standard deviation of the coldboot time
    ...
    ...    === Side Effects ===
    ...    - The device will be rebooted ${iterations} times
    [Arguments]    ${iterations}
    Skip    Coldboot not supported without serial connection

Measure Warmboot Time
    [Documentation]
    ...    Performs a measurement of average warmboot
    ...    boot time
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    - ``${iterations}``: ``integer`` - the amount of warmboots
    ...    to be tested
    ...
    ...    === Return Value ===
    ...    - ``float`` - MIN warmboot time
    ...    - ``float`` - MAX warmboot time
    ...    - ``float`` - Average warmboot time
    ...    - ``float`` - Standard deviation of the warmboot time
    ...
    ...    === Side Effects ===
    ...    - The device will be rebooted ${iterations} times
    [Arguments]    ${iterations}
    Fail    Not implemented

Measure Reboot Time
    [Documentation]
    ...    Performs a measurement of average reboot
    ...    boot time
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    - ``${iterations}``: ``integer`` - the amount of reboots
    ...    to be tested
    ...
    ...    === Return Value ===
    ...    - ``float`` - MIN reboot time
    ...    - ``float`` - MAX reboot time
    ...    - ``float`` - Average reboot time
    ...    - ``float`` - Standard deviation of the reboot time
    ...
    ...    === Side Effects ===
    ...    - The device will be rebooted ${iterations} times
    [Arguments]    ${iterations}
    Fail    Not implemented

Make Sure That Flash Locks Are Disabled
    [Documentation]    Makes sure that all flash locks are disabled in the UEFI
    ...    settings.
    ...
    ...    === Requirements ===
    ...    None
    ...
    ...    === Arguments ===
    ...    None
    ...
    ...    === Return Value ===
    ...    None
    ...
    ...    === Side Effects ===
    ...    - The device will get rebooted
    ...    - Causes a FAIL if disabling locks is not possible
    Fail    Not implemented
