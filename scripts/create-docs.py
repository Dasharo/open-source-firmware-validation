#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re
import sys

lib_dir = "lib"
output_resource = sys.argv[1] if len(sys.argv) > 1 else "all-keywords.robot"

# Collect all .robot files
robot_files = ["keywords.robot"]
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".robot"):
            robot_files.append(os.path.join(root, file))

# Collect all .py library files so their keywords are documented too.
# Package internals (dunder files) and test helpers are skipped: they are not
# imported as Robot libraries and would only add noise / import errors.
python_libraries = []
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if not file.endswith(".py"):
            continue
        if file.startswith("__") or file == "tests.py":
            continue
        python_libraries.append(os.path.join(root, file))
python_libraries.sort()

# Some libraries require an initialization argument to import (e.g.
# QemuMonitor needs a path). libdoc accepts arguments via "path::arg", so a
# throwaway value lets the keywords be introspected without a live target.
library_init_args = {
    os.path.join(lib_dir, "QemuMonitor.py"): "::/dev/null",
}

# Regex pattern to detect keyword definitions
keyword_pattern = re.compile(
    r"^(?:(?!Library|Resource|Variables|Documentation)[A-Z][a-z0-9_]+[\ ]+.*)"
)

delimiter = "."  # Between filename and the keyword


def _python_library_import_lines():
    """Return 'Library    <path>' lines for every .py library to document."""
    lines = []
    for py_lib in python_libraries:
        init_arg = library_init_args.get(py_lib, "")
        lines.append(f"Library    {py_lib}{init_arg}\n")
    return lines


# Create the combined resource file with prefixed keywords
with open(output_resource, "w", encoding="utf8") as res_file:

    injected_py_libraries = False

    for robot_file in robot_files:
        file_prefix = os.path.splitext(os.path.basename(robot_file))[0] + delimiter
        index_offset = 0

        with open(robot_file, "r", encoding="utf8") as read_file:
            for line in read_file:
                if re.match(keyword_pattern, line):
                    res_file.write(file_prefix + line)
                else:
                    res_file.write(line)

                # Inject the .py Library imports into the first Settings section
                # encountered (keywords.robot). Keeping them inside an existing
                # Settings block avoids a second '*** Settings ***' header, which
                # Robot Framework does not allow in a single resource file.
                if not injected_py_libraries and line.strip() == "*** Settings ***":
                    for py_import in _python_library_import_lines():
                        res_file.write(py_import)
                    injected_py_libraries = True
