# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

DEVICE_OS_USERNAME = "root"
DEVICE_OS_PASSWORD = "pfsense"
DEVICE_OS_HOSTNAME = "pfSense.home.arpa"

DEVICE_OS_ROOT_PROMPT = (
    f"[2.7.2-RELEASE][{DEVICE_OS_USERNAME}@{DEVICE_OS_HOSTNAME}]/{DEVICE_OS_USERNAME}"
)
DEVICE_OS_RESCUE_PROMPT = "#"
