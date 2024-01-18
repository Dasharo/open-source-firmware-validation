import re

from robot.api.deco import keyword


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
