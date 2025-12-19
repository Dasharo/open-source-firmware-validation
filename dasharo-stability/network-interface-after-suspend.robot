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
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${NETWORK_INTERFACE_AFTER_SUSPEND_SUPPORT}    Network interface after suspend test not supported
...                     AND
...                     Check If Platform Sleep Type Can Be Selected
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
NET002.201 Net controller after warmboot (Ubuntu)
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    ...    Previous IDs: NET002.001
    [Tags]    automated    semiauto
    Skip If
    ...    not ${RTC_BOOT_SUPPORT} and ${TEST_TAGS} is not ${None} and 'semiauto' not in ${TEST_TAGS}
    ...    The test is semiauto on this device. Semiauto tag was not selected.
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET002.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NET002.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Net Controller After Warmboot
    Exit From Root User

NET003.201 Net controller after reboot (Ubuntu)
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    ...    Previous IDs: NET003.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET003.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NET003.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    Net Controller After Reboot
    Exit From Root User

NET004.201 NET controller after suspend (Ubuntu)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    ...    Previous IDs: NET004.001
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET004.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NET004.201 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET004.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend
    Exit From Root User

NET005.201 NET controller after suspend (Ubuntu) (S0ix)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    ...    Previous IDs: NET04.002
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET005.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    NET005.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET005.201 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend    S0ix
    Exit From Root User

NET006.201 NET controller after suspend (Ubuntu) (S3)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    ...    Previous IDs: NET004.003
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    NET006.201 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET006.201 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend    S3
    Exit From Root User

NET002.202 Net controller after warmboot (Fedora)
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    ...    Previous IDs: NET005.003
    [Tags]    automated    semiauto
    Skip If
    ...    not ${RTC_BOOT_SUPPORT} and ${TEST_TAGS} is not ${None} and 'semiauto' not in ${TEST_TAGS}
    ...    The test is semiauto on this device. Semiauto tag was not selected.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NET002.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Net Controller After Warmboot
    Exit From Root User

NET003.202 Net controller after reboot (Fedora)
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NET003.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    Net Controller After Reboot
    Exit From Root User

NET004.202 NET controller after suspend (Fedora)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NET004.202 not supported
    Skip If    ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET004.202 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend
    Exit From Root User

NET005.202 NET controller after suspend (Fedora) (S0ix)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NET005.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET005.202 not supported
    Set Platform Sleep Type    S0ix
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend    S0ix
    Exit From Root User

NET006.202 NET controller after suspend (Fedora) (S3)
    [Documentation]    This test aims to verify that the network controller works and the platform
    ...    is able to connect to the network after suspend.
    Skip If    '${ENV_ID_FEDORA}' not in ${TESTED_LINUX_DISTROS}    NET005.202 not supported
    Skip If    not ${PLATFORM_SLEEP_TYPE_SELECTABLE}    NET006.202 not supported
    Set Platform Sleep Type    S3
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_FEDORA}
    Login To Linux
    Switch To Root User
    NET Controller After Suspend    S3
    Exit From Root User


*** Keywords ***
NET Controller After Suspend
    [Arguments]    ${platform_sleep_type}=${EMPTY}
    Check Platform Sleep Type Is Correct On Linux    ${platform_sleep_type}
    ${is_suspend_performed_correctly}=    Perform Suspend Test Using FWTS
    IF    not ${is_suspend_performed_correctly}
        Fail    Suspend log not correct or does not exist.
    END
    ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp|eno'
    Should Contain    ${network_status}    UP

Net Controller After Warmboot
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    FOR    ${ind}    IN RANGE    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        IF    ${RTC_BOOT_SUPPORT}
            Perform Warmboot Using Rtcwake
        ELSE
            Execute Shutdown Command
            IF    '${POWER_CTRL}' == 'none'
                Execute Manual Step    Turn on the device
            ELSE
                Power On
            END
        END
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp|eno'
        Should Contain    ${network_status}    UP
    END

Net Controller After Reboot
    [Documentation]    This test aims to verify that the network controller works and
    ...    the platform is able to connect to the network after reboot.
    FOR    ${ind}    IN RANGE    ${STABILITY_DETECTION_REBOOT_ITERATIONS}
        Execute Reboot Command
        Boot System Or From Connected Disk    ${BOOTED_OS_ID}
        Login To Linux
        Switch To Root User
        ${network_status}=    Execute Command In Terminal    ip link | grep -E 'enp|eno'
        Should Contain    ${network_status}    UP
    END
