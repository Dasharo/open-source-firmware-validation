#!/usr/bin/env python

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import pathlib
import sys

from robot.running import ResourceFileBuilder

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
    print()
    print("The script checks for all the variables that are set to ${TBD}")
    print("in default.robot and were not set in any of the includes.")
    print("Setting the variables in the created platform config file should be")
    print("enough provided all of the OSFV platform config variables are set")
    print("in default.robot.")
    print()
    print("The results require manual verification.")
    print()
    print(f"Usage: {args[0]} <new config name> [vendor / platform includes]")
    print(f"Example: {args[0]} vendor-name_model-name vendor-common vendor-model")


def get_variables(file: str) -> list[tuple[str, str]]:
    resource_file = ResourceFileBuilder().build(file)
    return resource_file.variables


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
    includes_variables = []
    files_ok = True
    for include in vendor_includes_names:
        path = f"{PLATFORM_INCLUDES_PATH}/{include}.robot"
        if not pathlib.Path(path).is_file():
            print(f"{path} does not exist")
            files_ok = False
        includes_variables += get_variables(path)

    if not files_ok:
        exit(1)

    default_variables = get_variables(DEFAULT_ROBOT_PATH)

    # find if some variables were not defined
    undefined_variables = [
        var
        for var in default_variables
        if UNDEFINED_VARIABLE_VALUE in var.value
        and var.name not in [var.name for var in includes_variables]
    ]

    # create the content of new config file
    # include default.robot and vendor includes
    new_config_content = f"""*** Settings ***
Resource    include/{DEFAULT_ROBOT}
"""
    longest_var = max([len(v.name) for v in undefined_variables])
    print(longest_var)

    for vendor_include in vendor_includes_names:
        new_config_content += f"Resource    include/{vendor_include}.robot\n"

    # add all variables that may need to be defined
    new_config_content += "\n\n*** Variables ***\n"
    for var in undefined_variables:
        new_config_line = f"{var.name}="
        new_config_line += " " * (4 + (longest_var - len(var.name)))
        new_config_line += f"{UNDEFINED_VARIABLE_VALUE}\n"
        new_config_content += new_config_line

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
