# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Settings ***
Resource    include/msi-z690-common.robot


*** Variables ***
${FW_VERSION}=                      v1.1.2
${DMIDECODE_SERIAL_NUMBER}=         N/A
${DMIDECODE_FIRMWARE_VERSION}=      Dasharo (coreboot+UEFI) v1.1.3
${DMIDECODE_PRODUCT_NAME}=          MS-7D25
${DMIDECODE_RELEASE_DATE}=          11/27/2023

${CPU_MAX_FREQUENCY}=               5200
${CPU_MIN_FREQUENCY}=               300
