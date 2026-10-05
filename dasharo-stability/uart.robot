*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             TelnetLibrary    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot

Suite Setup         Run Keyword
...                     Prepare Test Suite
Suite Teardown      Run Keyword
...                     Log Out And Close Connection

Default Tags        automated


*** Test Cases ***
UART001.201 UART devices transmit without blocking (Ubuntu)
    [Documentation]    Check whether the platform's extra UART devices (as
    ...    listed in ${UART_DEVICES}) can transmit data without the write
    ...    blocking indefinitely.
    Depends On    ${UART_DEVICES} != @{EMPTY}
    Skip If    not ${TESTS_IN_UBUNTU_SUPPORT}    UART001.201 not supported
    Skip If    '${ENV_ID_UBUNTU}' not in ${TESTED_LINUX_DISTROS}    UART001.201 not supported
    Power On
    Boot System Or From Connected Disk    ${ENV_ID_UBUNTU}
    Login To Linux
    Switch To Root User
    FOR    ${tty}    IN    @{UART_DEVICES}
        Check UART Does Not Block    ${tty}
    END
    Exit From Root User


*** Keywords ***
Check UART Does Not Block
    [Documentation]    Check that writing to ``${tty}`` completes instead of
    ...    blocking indefinitely. IRQ and baud rate are read back from
    ...    ``dmesg`` instead of being hardcoded, since they are hardware
    ...    facts reported by the kernel rather than configuration.
    ...
    ...    Any ``serial-getty`` attached to ``${tty}`` is stopped for the
    ...    duration of the check and restarted before the result is
    ...    asserted, so the check is not affected by, and does not corrupt,
    ...    a login session on that line.
    [Arguments]    ${tty}
    ${tty_name}=    Fetch From Right    ${tty}    /
    ${current_tty}=    Execute Command In Terminal    tty
    IF    '${current_tty}' == '${tty}'
        Fail    Refusing to test ${tty}: it is the tty currently used for the test connection
    END
    Execute Command In Terminal    systemctl stop serial-getty@${tty_name}.service
    ${irq}=    Execute Command In Terminal
    ...    dmesg | grep -oP '${tty_name}\\b.*irq = \\K[0-9]+' | head -n1
    ${baud}=    Execute Command In Terminal
    ...    dmesg | grep -oP '${tty_name}\\b.*base_baud = \\K[0-9]+' | head -n1
    Should Not Be Empty    ${irq}    msg=Could not determine IRQ for ${tty} from dmesg
    Should Not Be Empty    ${baud}    msg=Could not determine baud for ${tty} from dmesg
    Execute Command In Terminal    setserial ${tty} irq ${irq}
    Execute Command In Terminal    stty -F ${tty} ${baud}
    ${rc}=    Execute Command In Terminal And Return RC
    ...    timeout 10 sh -c 'yes uarttest | head -c 100 | tee ${tty} >/dev/null'
    ...    15s
    Execute Command In Terminal    systemctl start serial-getty@${tty_name}.service
    Should Be Equal As Integers    ${rc}    0    msg=Write to ${tty} blocked (timed out)
