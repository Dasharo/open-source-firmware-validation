import re

from robot.api.deco import keyword


@keyword("Check if menu line is an option")
def check_if_menu_line_is_an_option(line):
    """
    Checks if given line is the part of some menu, by checking if the option
    is selectable: checks for the presence of '[' or '>'
    """
    re_starts_with_arrow_opt = r"^>.*$"
    re_multiple_choice_opt = r"^.*<.*$"
    re_boolean_opt = r"^.*\[.*\]"

    if re.match(re_starts_with_arrow_opt, line):
        return True
    elif re.match(re_multiple_choice_opt, line):
        return True
    elif re.match(re_boolean_opt, line):
        return True
    else:
        return False


@keyword("Extract strings from frame")
def extract_strings_from_frame(text):
    """
    Extract a list of selectable strings from frame appearing
    when selecting option from a list such as: Option <state>.
    """
    inside_frame = False
    extracted_strings = []
    re_frame_start = r"^.*/-{3,}\\.*$"
    re_frame_end = r"^.*\\-{3,}/.*$"
    re_selection = r"\|\s*([^|]+?)\s*\|"

    for line in text.splitlines():
        if re.match(re_frame_start, line):
            inside_frame = True
            continue
        elif re.match(re_frame_end, line):
            inside_frame = False
            continue

        if inside_frame:
            match = re.search(re_selection, line)
            if match:
                extracted_strings.append(match.group(1).strip())

    return extracted_strings


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
