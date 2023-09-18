import pyotp


def get_totp_from_uri(uri):
    totp = pyotp.parse_uri(uri)
    return totp.now()
