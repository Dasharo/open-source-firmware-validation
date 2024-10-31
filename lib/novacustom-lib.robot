# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Keywords ***
Check EC Firmware Version
    [Documentation]    Keyword allows checking EC firmware version via the
    ...    dasharo_ectool info utility.
    [Arguments]    ${expected_version}=${EC_VERSION}    ${tool}=dasharo_ectool
    ${output}=    Execute Command In Terminal    ${tool} info
    Should Contain    ${output}    ${expected_version}

Flash EC Firmware
    [Documentation]    Keyword allows flashing EC firmware via the
    ...    dasharo_ectool info utility.
    [Arguments]    ${ec_fw_download_link}=https://3mdeb.com/open-source-firmware/Dasharo/${EC_BINARY_LOCATION}
    ...    ${tool}=dasharo_ectool
    Execute Command In Terminal
    ...    command=wget -O /tmp/ec.rom ${ec_fw_download_link}
    ...    timeout=320s
    Write Into Terminal    ${tool} flash /tmp/ec.rom
    Press Enter
    Read From Terminal Until    Successfully programmed SPI ROM
    Sleep    10s
