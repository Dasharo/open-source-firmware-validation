import re

from robot.api.deco import keyword


@keyword("Parse TCG2 Menu Snapshot Into Construction")
def parse_tcg2_menu_snapshot_into_construction(
    menu: str, remove_lines=None, merge_empty_options=True
):
    """Breaks grabbed menu data into list of (option, value) pairs.

    Correctly merges multiline names and values if values end in comma
    If name is in 2 lines but values only one then second line is dropped unless
    merge_empty_options is true
    """
    NAME_OFFSET = 3
    NAME_LENGTH = 26
    VALUE_LENGTH = 25
    NAME_END = NAME_LENGTH + NAME_OFFSET
    VALUE_END = NAME_END + VALUE_LENGTH
    if remove_lines is None:
        remove_lines: list[str] = []
    menu_lines = menu.strip("\r").splitlines()
    construction = []
    append_to_last = False
    remove_lines.extend(
        [
            "Esc=Exit",
            "^v=Move High",
            "<Enter>=Select Entry",
            "F9=Reset to Defaults F10=Save",
            "LCtrl+LAlt+F12=Save screenshot",
            "<Spacebar>Toggle Checkbox",
            "TCG2 Configuration",
        ]
    )

    for line in menu_lines:
        print(line)
        stripped_line = line.replace(" ", "")
        if any(remove.replace(" ", "") in stripped_line for remove in remove_lines):
            continue
        name, value = line[NAME_OFFSET:NAME_END], line[NAME_END:VALUE_END]
        name = name.strip().strip("|").strip()
        value = value.strip().strip("|").strip()
        name = re.sub("^[\\|\\s/\\\\-]+$", "", name)
        value = re.sub("^[\\|\\s/\\\\-]+$", "", value)
        if name in remove_lines or value in remove_lines:
            continue
        if not (name or value):
            continue
        if append_to_last or (not value and merge_empty_options and construction):
            last_name, last_value = construction[-1]
            new_name = last_name + " " + name
            new_value = last_value + " " + value
            construction[-1] = (new_name, new_value)
            if not new_value.endswith(","):
                append_to_last = False
            continue
        if value.endswith(","):
            append_to_last = True
        if not value:
            continue
        construction.append((name, value))
    return construction
