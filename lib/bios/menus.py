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


@keyword("Get Value From Brackets")
def get_value_from_brackets(text):
    """
    This keyword returns the current value stored in brackets
    [] or <>.

    We actually check for the first bracket only (and strip the
    other one if it exists), as some values span over more than
    one line. In such a case, only part of the option value (from
    the first line) would be returned.
    """
    pattern = r"[\[<].*"

    matches = re.findall(pattern, text)

    if matches:
        value = matches[0].strip("<>[]")
        # Sometimes a part of help text may be returned after the closing
        # bracket. Separate the option value by splitting the string only once
        # using last occurrence of separator and returning only left side of
        # the match.
        value = value.rsplit("]", 1)[0]
        value = value.rsplit(">", 1)[0]
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


@keyword("Merge Two Lists")
def merge_lists(list1, list2):
    """
    This keyword merges two lists into one, without creating double entries
    if they have some in common.
    """
    set1 = set(list1)
    set2 = set(list2)
    final_list = set1

    for i2 in set2:
        if i2 not in set1:
            final_list.add(i2)

    return final_list


getoptionpath = {
    "LockBios": [
        "Dasharo System Features",
        "Dasharo Security Features",
        "Lock the BIOS boot medium",
    ],
    "NetworkBoot": [
        "Dasharo System Features",
        "Networking Options",
        "Enable network boot",
    ],
    "UsbDriverStack": [
        "Dasharo System Features",
        "USB Configuration",
        "Enable USB stack",
    ],
    "UsbMassStorage": [
        "Dasharo System Features",
        "USB Configuration",
        "Enable USB Mass Storage driver",
    ],
    "SmmBwp": [
        "Dasharo System Features",
        "Dasharo Security Features",
        "Enable SMM BIOS write protection",
    ],
    "MeMode": [
        "Dasharo System Features",
        "Intel Management Engine Options",
        "Intel ME mode",
    ],
    "FanCurveOption": [
        "Dasharo System Features",
        "Power Management Options",
        "Fan profile",
    ],
    "EnableCamera": [
        "Dasharo System Features",
        "Dasharo Security Features",
        "Enable Camera",
    ],
    "EnableWifiBt": [
        "Dasharo System Features",
        "Dasharo Security Features",
        "Enable Wi-Fi + BT radios",
    ],
    "SerialRedirection": [
        "Dasharo System Features",
        "Serial Port Configuration",
        "Enable Serial Port Console Redirection",
    ],
    "PCIeResizeableBarsEnabled": [
        "Dasharo System Features",
        "PCI/PCIe Configuration",
        "Enable PCIe Resizeable",
    ],
    "HyperThreading": [
        "Dasharo System Features",
        "CPU Configuration",
        "Hyper-Threading",
    ],
    "ActiveECores": [
        "Dasharo System Features",
        "CPU Configuration",
        "Number of active E-cores",
    ],
    "ActivePCores": [
        "Dasharo System Features",
        "CPU Configuration",
        "Number of active P-cores",
    ],
}


@keyword("Option Name To UEFI Path")
def option_name_to_uefi_path(name):
    """
    This keyword converts an option name to a UEFI menu path. This path can be
    used to navigate to the option in the UEFI Setup Menu app.
    """
    return getoptionpath[name]
