from robot.api import logger
from robot.api.deco import keyword


@keyword("Merge Empty Options Into Previous Line")
def merge_empty_options_into_previous_line(menu: list[str]) -> list[str]:
    """Merge option into previous line if it has no value"""
    new_menu = []
    for i, line in enumerate(menu):
        line = str(line)
        if len(line) < 23 and i > 0:
            old_line = new_menu[-1]
            merged_name = f"{new_menu[-1][:23].rstrip()} {line}  "
            new_menu[-1] = merged_name + new_menu[-1][23:]
            new_menu[-1].rstrip()
            logger.trace(
                f"FOR[{i}]: merge '{old_line}' and '{line}' into '{new_menu[-1]}'"
            )
        else:
            logger.trace(f"FOR[{i}]: {line}")
            new_menu.append(line)
    return new_menu
