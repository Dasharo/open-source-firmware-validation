# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import pyotp


def get_totp_from_uri(uri):
    totp = pyotp.parse_uri(uri)
    return totp.now()


def get_totps_around_now_from_uri(uri):
    """TOTP codes for the previous, current and next time step, to compare
    with a code shown a moment ago without failing on a step boundary."""
    totp = pyotp.parse_uri(uri)
    now = totp.timecode(__import__("datetime").datetime.now())
    return [totp.generate_otp(now + d) for d in (-1, 0, 1)]
