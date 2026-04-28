# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# 0xx - Unspecified
ENV_ID_UNSPECIFIED = "001"

# 1xx - Firmware
ENV_ID_EDK2 = "101"
ENV_ID_SEABIOS = "102"
ENV_ID_IPXE = "103"
ENV_ID_HEADS = "104"
ENV_ID_PETITBOOT = "105"
ENV_ID_UEFI_SHELL = "106"

# 2xx - Linux
ENV_ID_UBUNTU = "201"
ENV_ID_FEDORA = "202"
ENV_ID_QUBES = "203"
ENV_ID_TRENCHBOOT = "204"
ENV_ID_XCP_NG = "205"
ENV_ID_ZARHUS = "206"
ENV_ID_OPENWRT = "207"
ENV_ID_DEBIAN = "208"
ENV_ID_HEADS_DEBIAN = "209"
ENV_ID_PROXMOX = "210"
ENV_ID_DTS = "211"

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
    ENV_ID_WINDOWS: "Windows Boot Manager",
    ENV_ID_TRENCHBOOT: "trenchboot",
    ENV_ID_ESXI: "ESXi",
    ENV_ID_XCP_NG: "XCP-ng",
    # Or 'ZarhusOS A' and 'ZarhusOS B' if using A/B update feature
    ENV_ID_ZARHUS: "ZarhusOS",
    ENV_ID_OPENWRT: "OpenWrt",
    ENV_ID_QUBES: "Qubes OS",
    ENV_ID_DEBIAN: "Debian",
    ENV_ID_UEFI_SHELL: "UEFI Shell",
}

ENV_ID_FRIENDLY_NAMES = {
    ENV_ID_EDK2: "EDK2 UEFI",
    ENV_ID_SEABIOS: "SeaBIOS",
    ENV_ID_IPXE: "iPXE",
    ENV_ID_HEADS: "Heads",
    ENV_ID_PETITBOOT: "Petitboot",
    ENV_ID_UEFI_SHELL: "UEFI Shell",
    ENV_ID_DTS: "DTS",
    ENV_ID_UBUNTU: "Ubuntu",
    ENV_ID_FEDORA: "Fedora",
    ENV_ID_WINDOWS: "Windows",
    ENV_ID_TRENCHBOOT: "TrenchBoot",
    ENV_ID_ESXI: "ESXi",
    ENV_ID_QUBES: "Qubes OS",
    ENV_ID_ZARHUS: "ZarhusOS",
    ENV_ID_OPENWRT: "OpenWrt",
    ENV_ID_DEBIAN: "Debian",
    ENV_ID_FREEBSD: "FreeBSD",
    ENV_ID_HEADS_DEBIAN: "Heads+Debian",
    ENV_ID_PFSENSE: "pfSense",
    ENV_ID_OPNSENSE: "OPNSense",
    ENV_ID_PROXMOX: "Proxmox",
    ENV_ID_UEFI_SHELL: "UEFI Shell",
}
