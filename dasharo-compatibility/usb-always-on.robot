*** Settings ***
Library         Collections
Library         Dialogs
Library         OperatingSystem
Library         Process
Library         String
Resource        ../variables.robot
Resource        ../keywords.robot
Resource        ../keys.robot

Suite Setup     Run Keywords
...                 Prepare Test Suite

# TODO: human-readable representation of setup menu key for all platforms
Default Tags    semiauto


*** Variables ***
@{USB_PORTS_POWER_AND_CHARGING_OPTS}=       While System is On    Always On


*** Test Cases ***
USC001.001 "USB power and charging" option is present
    [Documentation]    This test aims to verify that "USB ports power and charging"
    ...    option is present in setup menu.
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Note, if "USB ports power and charging" menu option is present
    @{user_values}=    Get Selections From User
    ...    Enter value submenu of "USB ports power and charging", mark existing values, but don't change anything
    ...    ${USB_PORTS_POWER_AND_CHARGING_OPTS}[0]
    ...    ${USB_PORTS_POWER_AND_CHARGING_OPTS}[1]
    Lists Should Be Equal    ${USB_PORTS_POWER_AND_CHARGING_OPTS}    ${user_values}
    Execute Manual Step    Power off DUT

USC002.001 Power IS delivered through always-on USB A ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "Always On" keeps electrical power supply on
    ...    selected USB A ports, after DUT is power off
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "Always On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB A ports that
    ...    are marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should be able to supply
    ...    power meter itself and voltage should be close to 5.0V
    Execute Manual Step    ${power_meter_message}

USC003.001 Power IS delivered through always-on USB C ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "Always On" keeps electrical power supply on
    ...    selected USB C ports, after DUT is power off
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "Always On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB C ports that
    ...    are marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should be able to supply
    ...    power meter itself and voltage should be close to 5.0V
    Execute Manual Step    ${power_meter_message}

USC004.001 Power IS NOT delivered through always-on USB A ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "While System is On" is disabling electrical
    ...    power supply on selected USB A ports, after DUT is power off.
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "While System is On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB A ports that
    ...    are marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should not be able to
    ...    supply power meter itself and voltage should be close to 0.0V
    Execute Manual Step    ${power_meter_message}

USC005.001 Power IS NOT delivered through always-on USB C ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "While System is On" is disabling electrical
    ...    power supply on selected USB C ports, after DUT is power off.
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "While System is On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB C ports that
    ...    are marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should not be able to
    ...    supply power meter itself and voltage should be close to 0.0V
    Execute Manual Step    ${power_meter_message}

USC006.001 Power IS NOT delivered through regular USB A ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "Always On" is NOT enabling electrical power
    ...    supply to USB A ports that are NOT marked as "Always On USB", after
    ...    DUT is power off.
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "Always On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB A ports that
    ...    are NOT marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should not be able to
    ...    supply power meter itself and voltage should be close to 0.0V
    Execute Manual Step    ${power_meter_message}

USC007.001 Power IS NOT delivered through regular USB C ports
    [Documentation]    This test verifies, if setting "USB ports power and
    ...    charging" menu option to "Always On" is NOT enabling electrical power
    ...    supply to USB C ports that are NOT marked as "Always On USB", after
    ...    DUT is power off.
    Execute Manual Step    Power on DUT
    Execute Manual Step
    ...    Wait for "${TIANOCORE_STRING}" string on the screen and press SETUP_MENU_KEY to enter setup menu
    Execute Manual Step    Enter Dasharo System Features submenu
    Execute Manual Step    Enter Power Management Options submenu
    Execute Manual Step    Set value of "USB ports power and charging" to "Always On"
    Execute Manual Step    Save setup configuration with F10 key, confirm with Y key
    Execute Manual Step    Power off DUT
    Execute Manual Step    Power on DUT (this is when setup change takes effect)
    Execute Manual Step    Wait until "${TIANOCORE_STRING}" appears on screen and power off DUT
    ${power_meter_message}=    Catenate    Verify state of all USB C ports that
    ...    are NOT marked in "Hardware configuration matrix" as "Always On USB"
    ...    using USB power meter. All verified ports should not be able to
    ...    supply power meter itself and voltage should be close to 0.0V
    Execute Manual Step    ${power_meter_message}
