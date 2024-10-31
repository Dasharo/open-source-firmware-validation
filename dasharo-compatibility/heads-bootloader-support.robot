# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library             SSHLibrary    timeout=90 seconds
Library             RequestsLibrary
Library             ../keys-and-keywords/totp.py
# TODO: maybe have a single file to include if we need to include the same
# stuff in all test cases
Resource            ../variables.robot
Resource            ../keywords.robot
Resource            ../keys.robot
Resource            ../keys-and-keywords/heads-keywords.robot

# TODO:
# - document which setup/teardown keywords to use and what are they doing
# - go through them and make sure they are doing what the name suggest (not
# exactly the case right now)
Suite Setup         Run Keywords
...                     Prepare Test Suite
...                     AND
...                     Skip If    not ${HEADS_PAYLOAD_SUPPORT}    heads payload not supported
Suite Teardown      Run Keyword
...                     Log Out And Close Connection


*** Variables ***
${TOTP_URI}=    unset

# Notes on menu option keys:
# - check for them explicitly, so we won't go into wrong menu if they change
# - read until end of ASCII window before choosing option, but check for the
#    option explicitly for better error messages
# - 'Write Bare Into Terminal' letter and ${ENTER} as separate commands, a small
#    delay is required
# - cases don't matter, both select the same option
# - if multiple options use the same (case-insensitive) letter, they are
#    selected top to bottom and don't loop back to the top


*** Test Cases ***
HDS001.001 Heads installation
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Heads bootloader
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    HDS001.001 not supported
    Power On
    # Factory reset. Additional window if /boot already has Heads stuff in it.
    ${output}=    Read From Terminal Until    ┘
    ${output}=    Get Lines Containing String    ${output}    F${SPACE}${SPACE}OEM Factory Reset / Re-Ownership
    IF    "${output}"!="${EMPTY}"
        Write Bare Into Terminal    F
        Write Bare Into Terminal    ${ENTER}
        Read From Terminal Until    ┘
    END
    # Select 'Continue' and choose default answer for 6 questions.
    Write Into Terminal    ${ARROW_RIGHT}${ENTER}${ENTER}${ENTER}${ENTER}${ENTER}${ENTER}
    Read From Terminal Until    Resetting GPG Key...
    # Time-consuming operations on keys, increase timeout.
    Set DUT Response Timeout    900s
    Read From Terminal Until    Provisioned secrets
    Set DUT Response Timeout    300s
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    Press Enter to reboot.
    Should Contain    ${output}    OEM Factory Reset / Re-Ownership has completed successfully
    # Reboot.
    Write Bare Into Terminal    ${ENTER}
    # Seal TOTP.
    Read From Terminal Until    g${SPACE}${SPACE}Generate new HOTP/TOTP secret
    Read From Terminal Until    ┘
    Write Bare Into Terminal    g
    Write Bare Into Terminal    ${ENTER}
    Read From Terminal Until    Do you want to proceed?
    Read From Terminal Until    ┘
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    Once you have scanned the QR code, hit Enter to continue
    Log    ${output}    console=yes
    ${totp_uri_local}=    Get Lines Containing String    ${output}    otpauth://totp
    Set Suite Variable    $TOTP_URI    ${totp_uri_local}
    Write Bare Into Terminal    ${ENTER}
    ${output}=    Read From Terminal Until    ┘
    ${totp_dut}=    Get Regexp Matches    ${output}    TOTP: (......)    1
    ${totp_real}=    Get Totp From Uri    ${TOTP_URI}
    Should Be Equal As Strings    ${totp_dut[0]}    ${totp_real}
    # TODO: store disk encryption key in TPM, requires OS installed on LVM:
    # Options, boot options, show OS boot menu. Select boot option. Make default.
    # Seal disk unlock key in TPM. Resign changes inside of boot. Boot default.
    # Enjoy.

HDS002.001 Boot into Heads
    [Documentation]    Check whether the DUT during booting procedure reaches
    ...    Heads bootloader
    Skip If    not ${TESTS_IN_FIRMWARE_SUPPORT}    HDS001.001 not supported
    Power On
    ${output}=    Detect Heads Main Menu
    ${totp_dut}=    Get Regexp Matches    ${output}    TOTP: (......)    1
    ${totp_real}=    Get Totp From Uri    ${TOTP_URI}
    Should Be Equal As Strings    ${totp_dut[0]}    ${totp_real}
