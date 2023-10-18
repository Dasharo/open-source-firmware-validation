#!/usr/bin/env python3

import jinja2
import os

# Define the paths to the library and test directories
lib_directory = "docs/lib"
test_directory = "docs/test"

# Get the list of library and test names
library_names = [os.path.splitext(file)[0] for file in os.listdir(lib_directory) if file.endswith('.robot')]
test_names = [os.path.splitext(file)[0] for file in os.listdir(test_directory) if file.endswith('.robot')]

# Create a Jinja2 environment
env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=""))

# Load the template
template = env.get_template("index.j2")

# Define a placeholder description
description = "Description for the {{ name }} goes here."

# Render the template with data
output = template.render(libraries=[{"name": name, "description": description} for name in library_names],
                        tests=[{"name": name, "description": description} for name in test_names])

# Write the rendered template to index.html
with open("index.html", "w") as index_file:
    index_file.write(output)

print("index.html generated successfully.")
