from robot.api.deco import keyword


@keyword("Get Option Value From Output")
def get_option_value_from_output(output, option):
    """
    Gets the value of option in the settings menu represented as output
    Arguments:
    output: str - output from the terminal
    option: str - name of the option from which value is read
    """
    start_index = output.find(option)
    if start_index == -1:
        return None
    # cut the output so its begin with selected option
    output_starting_from_option = output[start_index:]
    # find what type of value it is, it can start with [ or <
    value_sign = ""
    value = None
    for i, c in enumerate(output_starting_from_option):
        if c == "[" or c == "<":
            value_sign = c
            if c == "[":
                closing_index = output_starting_from_option.find("]")
            elif c == "<":
                closing_index = output_starting_from_option.find(">")
            value = output_starting_from_option[i : closing_index + 1]
            break

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
