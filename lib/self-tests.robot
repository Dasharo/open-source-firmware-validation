# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Keywords ***
Menu Construction Should Not Contain Control Text
    [Documentation]    Checks if parsed menu construction does not contain
    ...    some unnecessary help text, which is not a valid entry.
    [Arguments]    ${menu}
    Should Not Contain Any
    ...    ${menu}
    ...    Esc\=Exit
    ...    ^v\=Move High
    ...    <Enter>\=Select Entry
    ...    F9\=Reset to Defaults F10\=Save
    ...    LCtrl+LAlt+F12\=Save screenshot
    ...    <Spacebar>Toggle Checkbox
