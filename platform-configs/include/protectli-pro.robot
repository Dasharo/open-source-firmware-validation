# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

*** Variables ***
# Regression test flags
${DASHARO_SECURITY_MENU_SUPPORT}=       ${TRUE}

${NVME_DISK_SUPPORT}=                   ${TRUE}

# Test module: dasharo-security
${VERIFIED_BOOT_SUPPORT}=               ${TRUE}
${VERIFIED_BOOT_POPUP_SUPPORT}=         ${TRUE}
${MEASURED_BOOT_SUPPORT}=               ${TRUE}
${BIOS_LOCK_SUPPORT}=                   ${TRUE}
${SMM_WRITE_PROTECTION_SUPPORT}=        ${TRUE}
# WDT not yet enabled
${DASHARO_CHIPSET_MENU_SUPPORT}=        ${FALSE}
${UEFI_PASSWORD_SUPPORT}=               ${TRUE}
${ME_STATICALLY_DISABLED}=              ${TRUE}
