# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import pyotp


def get_totp_from_uri(uri):
    totp = pyotp.parse_uri(uri)
    return totp.now()
