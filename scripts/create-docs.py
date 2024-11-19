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
    r"\n(?:(?!Library|Resource|Variables|Documentation)[A-Z][a-z0-9_]+[\ ]+.*)"
)

delimiter = "."  # Between filename and the keyword

# Create the combined resource file with prefixed keywords
with open(output_resource, "w", encoding="utf8") as res_file:

    for robot_file in robot_files:
        file_prefix = os.path.splitext(os.path.basename(robot_file))[0] + delimiter
        index_offset = 1  # Initial value = length of \n

        with open(robot_file, "r", encoding="utf8") as file:
            text = file.read()

            for m in re.finditer(keyword_pattern, text):
                start = m.start(0)
                text = (
                    text[: start + index_offset]
                    + file_prefix
                    + text[start + index_offset :]
                )
                index_offset += len(file_prefix)
            text += "\n"

            res_file.write(text)
