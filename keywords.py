import re

from robot.api.deco import keyword


@keyword("Get Value From Brackets")
def get_value_from_brackets(text):
    pattern = r"[\[<](.*?)[\]>]"

    matches = re.findall(pattern, text)

    if matches:
        value = matches[0]  # Return the first match found
    else:
        value = None

    return value


@keyword("Check User Password Management menu default state")
def check_user_password_management_default_state(entries):
    status_present = False
    change_option_present = False
    for entry in entries:
        if "Admin Password Status" in entry:
            status_present = True
            if not "Not Installed" in entry:
                raise AssertionError("Admin Password Status should be not installed")
        if "Change Admin Password" in entry:
            change_option_present = True

    return status_present and change_option_present
