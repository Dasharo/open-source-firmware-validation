#!/usr/bin/env python3

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

# Regex pattern to detect keyword definitions
keyword_pattern = re.compile(
    r"^(?:(?!Library|Resource|Variables|Documentation)[A-Z][a-z0-9_]+[\ ]+.*)",
    re.MULTILINE
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