*** Settings ***
Library             Collections
Library             DateTime
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds
Library             SSHLibrary    timeout=20 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${SUSPEND_AND_RESUME_SUPPORT}    Suspend and resume tests not supported
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
...                     AND
...                     Set UEFI Option    MeMode    Enabled
Suite Teardown      Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
SMS001.201 Suspend to Idle (S0ix) check (Ubuntu)
    [Documentation]    Check whether Suspend to Idle (S0ix) works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMS001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMS001.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu
    Execute Manual Step    [2/4] Trigger S0ix suspend (e.g. echo freeze | sudo tee /sys/power/state)
    Execute Manual Step    [3/4] Resume the DUT and check dmesg for S0ix-related messages
    Execute Manual Step    [4/4] Confirm the DUT suspends to S0ix and resumes successfully

SMS002.201 Suspend to RAM (S3) check (Ubuntu)
    [Documentation]    Check whether Suspend to RAM (S3) works correctly in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SMS002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SMS002.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu
    Execute Manual Step    [2/4] Trigger S3 suspend (e.g. echo mem | sudo tee /sys/power/state or systemctl suspend)
    Execute Manual Step    [3/4] Resume the DUT and check dmesg for S3-related messages
    Execute Manual Step    [4/4] Confirm the DUT suspends to S3 and resumes successfully

SUSP001.201 Platform suspend and resume (Ubuntu) (wakeup flag)
    [Documentation]    Check whether the DUT can suspend and resume correctly using the wakeup flag in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP001.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu
    Execute Manual Step    [2/4] Trigger suspend using the wakeup flag (e.g. rtcwake -m mem -s 10)
    Execute Manual Step    [3/4] Wait for the DUT to resume from suspend
    Execute Manual Step    [4/4] Confirm the DUT resumes correctly and the system is functional

SUSP002.201 Platform suspend and resume (Ubuntu) (press key)
    [Documentation]    Check whether the DUT can suspend and resume correctly by pressing a key in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP002.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu and trigger suspend (e.g. systemctl suspend)
    Execute Manual Step    [2/4] Wait for the DUT to enter suspend
    Execute Manual Step    [3/4] Press a key on the keyboard to wake the DUT
    Execute Manual Step    [4/4] Confirm the DUT resumes correctly and the system is functional

SUSP003.201 Platform suspend and resume (Ubuntu) (power button)
    [Documentation]    Check whether the DUT can suspend and resume correctly using the power button in Ubuntu.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP003.201 not supported
    Execute Manual Step    [1/4] Boot into Ubuntu and trigger suspend (e.g. systemctl suspend)
    Execute Manual Step    [2/4] Wait for the DUT to enter suspend
    Execute Manual Step    [3/4] Press the power button briefly to wake the DUT
    Execute Manual Step    [4/4] Confirm the DUT resumes correctly and the system is functional

SUSP004.201 Platform suspend and resume (Ubuntu) (Wake-on-LAN)
    [Documentation]    This test aims to verify that the DUT platform suspend and resume
    ...    functionality works correctly. As a way to wake up the device, the Wake-on-LAN
    ...    mechanism is tested in this case.
    [Tags]    semiauto
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}
    Execute Manual Step    Power On the device, boot Ubuntu and log in
    Execute Manual Step    Run `ip link` and note the output
    Execute Manual Step    Note the lowest displayed MAC address (by numeric value)
    Execute Manual Step    Suspend the device and wait 15 seconds
    Execute Manual Step    On another device in the same local network run `wakeonlan <DUT MAC address>`
    Execute Manual Step    The DUT should wake up after a while
    Execute Manual Step    Run `cat /var/log/pm-suspend.log | grep 'suspend suspend: '` and note the output
    Execute Manual Step    Run `cat /var/log/pm-suspend.log | grep 'resume suspend: '` and note the output
    Execute Manual Step    Both of the outputs must not contain the word `error`

SUSP005.201 Cyclic platform suspend and resume (Ubuntu)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP005.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP005.201 not supported
    Power On
    # In case the default sleep type is S0ix, ME must be enabled
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT} == ${TRUE}
        Set UEFI Option    MeMode    Enabled
    END
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume
    Exit From Root User

SUSP006.201 Cyclic platform suspend and resume (Ubuntu) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP006.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    # ME must be enabled for S0ix to work
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT} == ${TRUE}
        Set UEFI Option    MeMode    Enabled
    END
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix
    Exit From Root User

SUSP007.201 Cyclic platform suspend and resume (Ubuntu) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    SUSP007.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    SUSP007.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3
    Exit From Root User

SUSP005.202 Cyclic platform suspend and resume (Fedora)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP005.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP005.202 not supported
    Power On
    # In case the default sleep type is S0ix, ME must be enabled
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT} == ${TRUE}
        Set UEFI Option    MeMode    Enabled
    END
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume
    Exit From Root User

SUSP006.202 Cyclic platform suspend and resume (Fedora) (S0ix)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP006.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP006.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    # ME must be enabled for S0ix to work
    IF    ${DASHARO_INTEL_ME_MENU_SUPPORT} == ${TRUE}
        Set UEFI Option    MeMode    Enabled
    END
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S0ix
    Exit From Root User

SUSP007.202 Cyclic platform suspend and resume (Fedora) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    SUSP007.202 not supported
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    SUSP007.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3
    Exit From Root User

SUSP001.203 Platform suspend and resume (Qubes OS) (wakeup flag)
    [Documentation]    Verify that platform suspend and resume works correctly on Qubes OS
    ...    using a wakeup flag set via rtcwake.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SUSP001.203 not supported
    Execute Manual Step    [1/7] Make sure Qubes OS is booted and open a dom0 terminal.
    Execute Manual Step    [2/7] Set the wakeup flag by running: rtcwake --mode no --seconds 60
    Execute Manual Step    [3/7] Enter suspend by running: pm-suspend
    Execute Manual Step    [4/7] Wait 60 seconds for the system to resume automatically.
    Execute Manual Step    [5/7] Log into the system again.
    Execute Manual Step    [6/7] Check suspend result: cat /var/log/pm-suspend.log | grep 'suspend suspend: '
    Execute Manual Step    [7/7] Check resume result: cat /var/log/pm-suspend.log | grep 'resume suspend: '

SUSP002.203 Platform suspend and resume (Qubes OS) (press key)
    [Documentation]    Verify stability of cyclic suspend and resume on Qubes OS.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SUSP002.203 not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Start at least one AppVM and perform basic activity inside it.
    Execute Manual Step    [3/5] Initiate system suspend.
    Execute Manual Step    [4/5] Resume the system, via keyboard key press
    Execute Manual Step    [5/5] Verify the AppVM is still running and responsive after resume.

SUSP003.203 Platform suspend and resume (Qubes OS) (power button)
    [Documentation]    Verify suspend and resume behavior with running AppVMs on Qubes OS.
    [Tags]    semiauto
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SUSP003.203 not supported
    Execute Manual Step    [1/5] Make sure Qubes OS is booted.
    Execute Manual Step    [2/5] Start at least one AppVM and perform basic activity inside it.
    Execute Manual Step    [3/5] Initiate system suspend.
    Execute Manual Step    [4/5] Resume the system, via power button press
    Execute Manual Step    [5/5] Verify the AppVM is still running and responsive after resume.

SUSP007.203 Cyclic platform suspend and resume (Qubes OS) (S3)
    [Documentation]    This test aims to verify that the DUT platform suspend
    ...    and resume procedure performed cyclically works correctly
    Skip If    '${ENV_ID_QUBES}' not in ${TESTED_LINUX_DISTROS}    SUSP007.203 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_QUBES}
    Login To Linux
    Switch To Root User
    Cyclic Platform Suspend And Resume    S3
    Exit From Root User


*** Keywords ***
Cyclic Platform Suspend And Resume
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    VAR    ${suspend_detected_fails}=    ${0}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    FOR    ${index}    IN RANGE    0    ${SUSPEND_ITERATIONS_NUMBER}
        ${is_suspend_performed_correctly}=    Perform Suspend Test Using FWTS
        IF    not ${is_suspend_performed_correctly}
            ${suspend_detected_fails}=    Evaluate    ${suspend_detected_fails} + 1
        END
        Log To Console    ${index} / ${SUSPEND_ITERATIONS_NUMBER}
    END
    Log To Console
    ...    \n${SUSPEND_ITERATIONS_NUMBER} iterations were performed to check the suspend procedure. \n${suspend_detected_fails} iterations have failed.
    IF    ${suspend_detected_fails} > ${SUSPEND_ALLOWED_FAILS}
        FAIL
        ...    \nTest case ${TEST_NAME} has been marked as failed. \nThe number of detected errors is greater than the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    ELSE
        Pass Execution
        ...    \nTest case ${TEST_NAME} has been marked passed. \nThe number of detected errors is at least the same as the number of allowed fails: ${SUSPEND_ALLOWED_FAILS}.
    END

Lowest MAC Address:
    # TODO: implement keyword "lowest MAC address:".
    Fail    Not Implemented
