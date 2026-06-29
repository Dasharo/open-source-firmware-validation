#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re
import sys
import tempfile

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
qemu_monitor_socket = os.path.join(tempfile.gettempdir(), "osfv-libdoc-qemu-monitor")
open(qemu_monitor_socket, "a", encoding="utf8").close()

# Create the combined resource file with prefixed keywords
with open(output_resource, "w", encoding="utf8") as res_file:
    for python_file in python_files:
        if os.path.basename(python_file) == "QemuMonitor.py":
            res_file.write(f"Library    {python_file}    {qemu_monitor_socket}\n")
        else:
            res_file.write(f"Library    {python_file}\n")
    res_file.write("\n")

    for robot_file in robot_files:
        file_prefix = os.path.splitext(os.path.basename(robot_file))[0] + delimiter
        index_offset = 0

        with open(robot_file, "r", encoding="utf8") as read_file:
            for line in read_file:
                if re.match(keyword_pattern, line):
                    res_file.write(file_prefix + line)
                else:
                    res_file.write(line)
