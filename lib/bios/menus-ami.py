from robot.api import Failure, logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


@keyword("Extract Ami Frame Name")
def extract_ami_frame_name(snapshot: str) -> str:
    """
    Extract Ami frame name from top border  /---- <frame name> ----\
    """
    lines: list[str] = snapshot.splitlines()
    try:
        top_border = next(value for value in lines if "/---" in value)
    except StopIteration:
        msg = "Couldn't find beginning of AMI frame"
        logger.trace(lines)
        BuiltIn().run_keyword("Fail", msg)

    return top_border.strip("/- \\")


@keyword("Extract Strings From Ami Frame")
def extract_strings_from_ami_frame(text: str):
    """
    Extract a list of selectable strings from frame appearing
    when selecting option from a list such as: Option <state>
    or when entering boot menu
    """
    lines: list[str] = text.splitlines()
    try:
        # assume AMI frame with header
        start_index = next(
            index for index, value in enumerate(lines) if "|---" in value
        )
    except StopIteration:
        # AMI frame without header
        try:
            start_index = next(
                index for index, value in enumerate(lines) if "/---" in value
            )
        except Exception:
            msg = "Couldn't find AMI frame header or beginning of AMI frame"
            logger.error(msg)
            BuiltIn().run_keyword("Fail", msg)
    try:
        # assume AMI frame with footer (e.g. boot menu)
        end_index = next(
            index
            for index, value in enumerate(
                lines[start_index + 1 :], start=start_index + 1
            )
            if "|---" in value
        )
    except StopIteration:
        # AMI frame without footer
        try:
            end_index = next(
                index
                for index, value in enumerate(
                    lines[start_index + 1 :], start=start_index + 1
                )
                if "---/" in value
            )
        except Exception:
            msg = "Couldn't find AMI frame footer or ending of AMI frame"
            logger.error(msg)
            BuiltIn().run_keyword("Fail", msg)

    # strip spaces and borders. Drop top border/header and bottom border/footer.
    extracted_strings: list[str] = [
        line.strip("| ") for line in lines[start_index + 1 : end_index]
    ]
    return extracted_strings


@keyword("Get Ami Submenu Construction")
def get_ami_submenu_construction(text: str):
    """
    Return only selectable options in ami submenu (containing '>' or '[')
    """
    lines = [line[1:-28] for line in text.splitlines()]
    # leave stripped lines lines containing > or [.
    return [line.strip() for line in lines if not {">", "["}.isdisjoint(line)]


@keyword("Parse Menu Snapshot Into Construction")
def parse_menu_snapshot_into_construction(
    snapshot: str, lines_top, lines_bot, *, full: bool = True, strip: bool = True
) -> tuple[list[str], bool]:
    """
    Parse menu snapshot and return list of options along with information if
    menu can be scrolled down. Full snapshot is with borders when changing
    menus, not full when scrolling and borders are not redrawn.
    checkpoint, lines_top and lines_bot are unused in AMI
    """
    frame = snapshot.splitlines()
    if full:
        frame = frame[1:-2]
    if strip:
        options: list[str] = [line[2:52].strip() for line in frame]
        return [option for option in options if option != ""]
    else:
        return [line[2:53] for line in frame]


@keyword("Can Snapshot Be Scrolled")
def can_snapshot_be_scrolled(snapshot: str, full: bool = True) -> tuple[str, str]:
    """
    Keyword returns whether page can be scrolled (down, up).
    """

    def get_string_scroll(char):
        if char == "":
            return "no change"
        if char == "+":
            return "yes"
        if char == "*":
            return "no"

    lines = parse_menu_snapshot_into_construction(
        snapshot, 0, 0, 0, full=full, strip=False
    )
    return (get_string_scroll(lines[1][52:53]), get_string_scroll(lines[-2][52:53]))


@keyword("Add New Lines To List")
def add_new_lines_to_list(old_list, new_list):
    new_lines = (new_line for new_line in new_list if new_line not in old_list)
    old_list.extend(new_lines)
