# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

import pyotp


def get_totp_from_uri(uri):
    totp = pyotp.parse_uri(uri)
    return totp.now()
