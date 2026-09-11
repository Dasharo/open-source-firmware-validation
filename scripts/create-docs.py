#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

import os
import re
import sys
from pathlib import Path

from robot.libdocpkg import LibraryDocumentation

lib_dir = "lib"
output_resource = sys.argv[1] if len(sys.argv) > 1 else "all-keywords.robot"
output_html = sys.argv[2] if len(sys.argv) > 2 else None

python_libdoc_args = {
    os.path.join("lib", "QemuMonitor.py"): ["libdoc-qemu-monitor-placeholder"],
}
created_placeholders = []


def collect_files(extension):
    collected = []
    for root, dirs, files in os.walk(lib_dir):
        dirs.sort()
        for file in sorted(files):
            if file.endswith(extension):
                collected.append(os.path.join(root, file))
    return collected


# Collect all .robot files
robot_files = ["keywords.robot"] + collect_files(".robot")

# Regex pattern to detect keyword definitions
keyword_pattern = re.compile(
    r"^(?:(?!Library|Resource|Variables|Documentation)[A-Z][a-z0-9_]+[\ ]+.*)"
)

delimiter = "."  # Between filename and the keyword

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


def prefix_library_keywords(library_doc, file_path):
    prefix = Path(file_path).stem + delimiter
    for keyword in library_doc.keywords:
        keyword.name = prefix + keyword.name
    return library_doc.keywords


def library_source(file_path, temp_dir):
    args = python_libdoc_args.get(file_path, [])
    if not args:
        return file_path

    resolved_args = []
    for arg in args:
        placeholder = Path(temp_dir) / arg
        placeholder.touch()
        created_placeholders.append(placeholder)
        resolved_args.append(str(placeholder))
    return "::".join([file_path, *resolved_args])


def generate_html_docs(resource_file, html_file):
    docs = LibraryDocumentation(resource_file)

    temp_dir = Path(resource_file).parent
    try:
        for python_file in collect_files(".py"):
            library_doc = LibraryDocumentation(library_source(python_file, temp_dir))
            docs.keywords.extend(prefix_library_keywords(library_doc, python_file))

        docs.save(html_file)
    finally:
        for placeholder in created_placeholders:
            placeholder.unlink(missing_ok=True)


if output_html:
    generate_html_docs(output_resource, output_html)
