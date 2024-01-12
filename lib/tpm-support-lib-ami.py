from robot.api import logger
from robot.api.deco import keyword


@keyword("Merge Empty Options Into Previous Line")
def merge_empty_options_into_previous_line(menu: str) -> list[str]:
    """Merge option into previous line if it has no value"""
    new_menu = []
    for i, line in enumerate(menu):
        logger.trace(f"FOR[{i}] = {line}")
        if len(line) < 23 and i > 0:
            new_menu[-1] = new_menu[-1][:23] + line + new_menu[-1][23:]
        else:
            new_menu.append(line)
    return new_menu
