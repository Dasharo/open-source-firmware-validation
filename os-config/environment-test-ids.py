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
ENV_ID_DEBIAN = "205"
ENV_ID_OPENWRT = "206"
ENV_ID_PROXMOX = "207"
ENV_ID_ROCKY_LINUX = "208"
ENV_ID_XCP_NG = "209"

# 3xx - Windows
ENV_ID_WINDOWS = "301"

# 4xx - BSD Based
ENV_ID_FREEBSD = "401"
ENV_ID_PFSENSE = "402"
ENV_ID_OPNSENSE = "403"

# 5xx - ESXI
ENV_ID_ESXI = "501"

ENV_ID_OS_BOOTMENU_NAMES = {
    ENV_ID_UBUNTU: "ubuntu",
    ENV_ID_FEDORA: "fedora",
    ENV_ID_WINDOWS: "Windows Boot",
    ENV_ID_TRENCHBOOT: "trenchboot",
}
