#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import ast
import os
import re
import sys

lib_dir = "lib"
output_resource = sys.argv[1] if len(sys.argv) > 1 else "all-keywords.robot"

# Collect all keyword libraries
robot_files = ["keywords.robot"]
python_files = []
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".robot"):
            robot_files.append(os.path.join(root, file))
        elif file.endswith(".py"):
            python_files.append(os.path.join(root, file))

# Regex pattern to detect keyword definitions
keyword_pattern = re.compile(
    r"^(?:(?!Library|Resource|Variables|Documentation)[A-Z][a-z0-9_]+[\ ]+.*)"
)

delimiter = "."  # Between filename and the keyword


def format_keyword_name(function_name):
    return function_name.replace("_", " ").title()


def get_keyword_name(decorator, function_name):
    if isinstance(decorator, ast.Name) and decorator.id == "keyword":
        return format_keyword_name(function_name)
    if (
        isinstance(decorator, ast.Call)
        and isinstance(decorator.func, ast.Name)
        and decorator.func.id == "keyword"
    ):
        if decorator.args and isinstance(decorator.args[0], ast.Constant):
            return decorator.args[0].value
        return format_keyword_name(function_name)
    return None


def format_default_value(default):
    if isinstance(default, ast.Constant):
        if isinstance(default.value, str):
            return default.value
        if default.value is None:
            return "${None}"
        if isinstance(default.value, bool):
            return f"${{{default.value}}}"
    return ast.unparse(default)


def get_robot_arguments(args):
    positional_args = list(args.posonlyargs) + list(args.args)
    defaults = [None] * (len(positional_args) - len(args.defaults)) + list(
        args.defaults
    )
    robot_args = []

    for arg, default in zip(positional_args, defaults):
        if arg.arg in ("self", "cls"):
            continue
        robot_arg = f"${{{arg.arg}}}"
        if default is not None:
            robot_arg += f"={format_default_value(default)}"
        robot_args.append(robot_arg)

    if args.vararg:
        robot_args.append(f"@{{{args.vararg.arg}}}")
    for arg, default in zip(args.kwonlyargs, args.kw_defaults):
        robot_arg = f"${{{arg.arg}}}"
        if default is not None:
            robot_arg += f"={format_default_value(default)}"
        robot_args.append(robot_arg)
    if args.kwarg:
        robot_args.append(f"&{{{args.kwarg.arg}}}")

    return robot_args


def iter_python_keywords(python_file):
    with open(python_file, "r", encoding="utf8") as read_file:
        module = ast.parse(read_file.read(), filename=python_file)

    for node in module.body:
        functions = []
        if isinstance(node, ast.FunctionDef):
            functions = [node]
        elif isinstance(node, ast.ClassDef):
            functions = [
                child for child in node.body if isinstance(child, ast.FunctionDef)
            ]

        for function in functions:
            for decorator in function.decorator_list:
                keyword_name = get_keyword_name(decorator, function.name)
                if keyword_name:
                    yield {
                        "name": keyword_name,
                        "arguments": get_robot_arguments(function.args),
                        "documentation": ast.get_docstring(function),
                    }
                    break


# Create the combined resource file with prefixed keywords
with open(output_resource, "w", encoding="utf8") as res_file:
    for robot_file in robot_files:
        file_prefix = os.path.splitext(os.path.basename(robot_file))[0] + delimiter
        index_offset = 0

        with open(robot_file, "r", encoding="utf8") as read_file:
            for line in read_file:
                if re.match(keyword_pattern, line):
                    res_file.write(file_prefix + line)
                else:
                    res_file.write(line)

    res_file.write("\n*** Keywords ***\n")
    for python_file in python_files:
        file_prefix = os.path.splitext(os.path.basename(python_file))[0] + delimiter
        for keyword_data in iter_python_keywords(python_file):
            res_file.write(f"{file_prefix}{keyword_data['name']}\n")
            if keyword_data["documentation"]:
                documentation = keyword_data["documentation"].splitlines()
                res_file.write(f"    [Documentation]    {documentation[0]}\n")
                for line in documentation[1:]:
                    res_file.write(f"    ...    {line}\n")
            if keyword_data["arguments"]:
                res_file.write(
                    f"    [Arguments]    {'    '.join(keyword_data['arguments'])}\n"
                )
            res_file.write("    No Operation\n\n")
