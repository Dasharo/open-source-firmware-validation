*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go threough them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND    Skip If    not ${BOOT_BLOCKING_SUPPORT}    Boot blocking not supported
...                     AND    Skip If    '${POWER_CTRL}' != 'sonoff'
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        semiauto


*** Test Cases ***
BBB003.101 Battery not connected warning (EDK2 UEFI)
    [Documentation]    This test aims to verify whether a warning message appears when the battery is
    ...    disconnected from the DUT.
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}
    Execute Manual Step    Disconnect the battery from the DUT
    Execute Manual Step    Plug the charger in without re-connecting the battery
    Execute Manual Step    Power on the DUT
    Execute Manual Step    After powering on the DUT, a warning should say "The laptop's battery is not detected!"
    Execute Manual Step    After pressing enter or passing the timeout, the DUT should continue booting.

BBB001.201 Boot blocking (charger disconnected) (Ubuntu)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BBB001.201 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff Off
    Discharge The Battery Until Target Level In Linux    3
    Execute Command In Terminal    reboot
    Execute Manual Step    The device should decline to boot due to low battery

BBB002.201 Boot blocking (charger connected) (Ubuntu)
    [Documentation]    Discharge the battery to below 5% and check if booting is
    ...    blocked.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    BBB002.201 not supported
    Power On
    Login To Linux
    Switch To Root User
    Sonoff Off
    Discharge The Battery Until Target Level In Linux    3
    Sonoff On
    Execute Command In Terminal    reboot
    Execute Manual Step    The device should boot normally
