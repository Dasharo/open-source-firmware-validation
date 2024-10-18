#!/usr/bin/env python

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

import os
import re
import sys

# create new config file
# include default.robot
# find all variables in default.robot
# somehow check if all of them are correct


DEFAULT_ROBOT = "default.robot"
PLATFORM_CONFIGS_PATH = (
    os.path.dirname(os.path.realpath(__file__)) + "/../platform-configs"
)
PLATFORM_INCLUDES_PATH = f"{PLATFORM_CONFIGS_PATH}/include"
DEFAULT_ROBOT_PATH = f"{PLATFORM_INCLUDES_PATH}/{DEFAULT_ROBOT}"

UNDEFINED_VARIABLE_VALUE = "${TBD}"
args = sys.argv


def help():
    print(f"Usage: {args[0]} <new config name> [vendor / platform includes]")
    print(f"Example: {args[0]} vendor-name_model-name vendor-common vendor-model1")


def get_variable_pairs(file: str) -> list[tuple[str, str]]:
    with open(file, "r") as f:
        file_content = f.read()

    file_lines = file_content.split("\n")

    # skip everything before *** Variables ***
    for i, line in enumerate(file_lines):
        if line.startswith("*** Variables ***"):
            break
        file_lines = file_lines[i + 1 :]

    # remove lines with comments
    file_lines = [line for line in file_lines if not line.startswith("#")]

    # lines with variables
    file_lines_w_vars = [line for line in file_lines if line.startswith("${")]

    # extract pairs of variable name and value
    variable_pairs = []
    i = 0
    for line in file_lines_w_vars:
        i += 1
        # separator is at least 4 spaces
        variable_name, variable_value = re.split(r"\s{4,}", line)
        variable_name = variable_name.strip("${}=")
        variable_pairs.append((variable_name, variable_value))

    return variable_pairs


def print_variables(variables: list[tuple[str, str]]):
    i = 0
    for var in default_variable_pairs:
        i += 1
        print(f"{i}: {var[0]} = {var[1]}")


if __name__ == "__main__":
    if len(args) < 2:  # two args == this scripts name and config name
        help()
        sys.exit(1)
    new_config_name = args[1]
    vendor_includes_names = args[2:]

    print(
        f"Creating new config {new_config_name} with includes {vendor_includes_names}"
    )

    # get all variables from default.robot and vendor includes

    default_variable_pairs = get_variable_pairs(DEFAULT_ROBOT_PATH)

    includes_variable_pairs = []
    for include in vendor_includes_names:
        include_path = f"{PLATFORM_INCLUDES_PATH}/{include}.robot"
        includes_variable_pairs += get_variable_pairs(include_path)

    # find if some variables were not defined
    undefined_variables = [
        var
        for var in default_variable_pairs
        if var[1] == UNDEFINED_VARIABLE_VALUE
        and var[0] not in [var[0] for var in includes_variable_pairs]
    ]

    # create the content of new config file
    # include default.robot and vendor includes
    new_config_content = f"""*** Settings ***
    Resource    include/{DEFAULT_ROBOT}
    """
    for vendor_include in vendor_includes_names:
        new_config_content += f"Resource    include/{vendor_include}\n"

    # add all variables that may need to be defined
    new_config_content += "\n*** Variables ***\n"
    for var in undefined_variables:
        new_config_content += f"{var[0]}    {UNDEFINED_VARIABLE_VALUE}\n"

    # write new config file
    new_config_path = f"{PLATFORM_CONFIGS_PATH}/{new_config_name}.robot"
    with open(new_config_path, "w") as f:
        f.write(new_config_content)

    print(f"New config file created at {new_config_path}")
    undefined_count = len(undefined_variables)
    if undefined_count > 0:
        print(
            f"Warning: {undefined_count} variables are not defined in any of the includes"
            " and need attention!"
        )
