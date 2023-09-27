import re

from robot.api.deco import keyword


@keyword("Check if menu line is an option")
def check_if_menu_line_is_an_option(line):
    """
    Checks if given line is the part of some menu, by checking if the option
    is selectable: checks for the presence of '[' or '<'
    """
    if "[" in line or "<" in line:
        return True
    return False


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
