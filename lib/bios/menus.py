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


@keyword("Get list options")
def get_list_options(menu):
    """
    keyword
    """
    match = re.search(r"/-+\\(.*?)\\-+/", menu, re.DOTALL)
    if match:
        lines = match.group(1).strip().split("\n")
        options = [line.strip() for line in lines if line.strip()]

        result = []

        for option in options:
            result.append(option[1:-1].strip())
        return result
    return []
