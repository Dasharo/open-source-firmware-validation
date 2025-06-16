# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# 1xx - Firmware
ENV_ID_EDK2 = "101"
ENV_ID_SEABIOS = "102"
ENV_ID_IPXE = "103"
ENV_ID_HEADS = "104"

# 2xx - Linux
ENV_ID_UBUNTU = "201"
ENV_ID_FEDORA = "202"
ENV_ID_QUBES = "203"
ENV_ID_TRENCHBOOT = "204"

# 3xx - Windows
ENV_ID_WINDOWS = "301"

# 4xx - Other
ENV_ID_ESXI = "401"  # ESXi

# 5xx - BSD
ENV_ID_FREEBSD = "501"
ENV_ID_PFSENSE = "502"
ENV_ID_OPNSENSE = "503"

ENV_ID_OS_BOOTMENU_NAMES = {
    ENV_ID_UBUNTU: "Ubuntu",
    ENV_ID_FEDORA: "Fedora",
    ENV_ID_WINDOWS: "Windows Boot",
    ENV_ID_TRENCHBOOT: "trenchboot",
    ENV_ID_ESXI: "ESXi",
}
