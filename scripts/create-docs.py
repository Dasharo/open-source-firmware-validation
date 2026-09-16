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

delimiter = "."  # Between filename and the keyword


def get_file_prefix(path):
    return os.path.splitext(os.path.basename(path))[0] + delimiter


def get_keyword_name(node):
    for decorator in node.decorator_list:
        if isinstance(decorator, ast.Name) and decorator.id == "keyword":
            return printable_keyword_name(node.name)

        if not (
            isinstance(decorator, ast.Call)
            and isinstance(decorator.func, ast.Name)
            and decorator.func.id == "keyword"
        ):
            continue

        if decorator.args and isinstance(decorator.args[0], ast.Constant):
            return decorator.args[0].value

        for keyword_arg in decorator.keywords:
            if keyword_arg.arg == "name" and isinstance(
                keyword_arg.value, ast.Constant
            ):
                return keyword_arg.value.value

        return printable_keyword_name(node.name)

    return None


def printable_keyword_name(name):
    return name.replace("_", " ").title()


def format_argument_default(default):
    if isinstance(default, ast.Constant):
        if default.value is True:
            return "${TRUE}"
        if default.value is False:
            return "${FALSE}"
        if default.value is None:
            return "${NONE}"
        return str(default.value)

    return ast.unparse(default)


def get_argument_tokens(node, skip_first=False):
    args = list(node.args.args)

    if skip_first and args and args[0].arg in ("self", "cls"):
        args = args[1:]

    defaults = [None] * (len(args) - len(node.args.defaults)) + list(node.args.defaults)
    tokens = []

    for arg, default in zip(args, defaults):
        token = f"${{{arg.arg}}}"
        if default is not None:
            token += f"={format_argument_default(default)}"
        tokens.append(token)

    if node.args.vararg:
        tokens.append(f"@{{{node.args.vararg.arg}}}")

    kw_defaults = list(node.args.kw_defaults)
    for arg, default in zip(node.args.kwonlyargs, kw_defaults):
        token = f"${{{arg.arg}}}"
        if default is not None:
            token += f"={format_argument_default(default)}"
        tokens.append(token)

    if node.args.kwarg:
        tokens.append(f"&{{{node.args.kwarg.arg}}}")

    return tokens


def get_python_keywords(path):
    with open(path, "r", encoding="utf8") as source:
        tree = ast.parse(source.read(), filename=path)

    keywords = []

    for node in tree.body:
        if isinstance(node, ast.FunctionDef):
            name = get_keyword_name(node)
            if name:
                keywords.append(
                    (name, ast.get_docstring(node), get_argument_tokens(node))
                )

        if isinstance(node, ast.ClassDef):
            for item in node.body:
                if not isinstance(item, ast.FunctionDef):
                    continue

                name = get_keyword_name(item)
                if name:
                    keywords.append(
                        (
                            name,
                            ast.get_docstring(item),
                            get_argument_tokens(item, skip_first=True),
                        )
                    )

    return keywords


def write_python_keywords(res_file, python_file):
    keywords = get_python_keywords(python_file)

    if not keywords:
        return

    file_prefix = get_file_prefix(python_file)
    res_file.write("\n\n*** Keywords ***\n")

    for keyword_name, documentation, arguments in keywords:
        res_file.write(f"{file_prefix}{keyword_name}\n")

        if documentation:
            lines = documentation.splitlines()
            res_file.write(f"    [Documentation]    {lines[0]}\n")
            for line in lines[1:]:
                res_file.write(f"    ...    {line}\n")

        if arguments:
            res_file.write("    [Arguments]    " + "    ".join(arguments) + "\n")

        res_file.write("\n")


# Collect all .robot and .py files
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

# Create the combined resource file with prefixed keywords
with open(output_resource, "w", encoding="utf8") as res_file:

    for robot_file in robot_files:
        file_prefix = get_file_prefix(robot_file)
        index_offset = 0

        with open(robot_file, "r", encoding="utf8") as read_file:
            for line in read_file:
                if re.match(keyword_pattern, line):
                    res_file.write(file_prefix + line)
                else:
                    res_file.write(line)

    for python_file in python_files:
        write_python_keywords(res_file, python_file)
