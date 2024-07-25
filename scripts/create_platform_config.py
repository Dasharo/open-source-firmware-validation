#!/usr/bin/env python

import sys
import os
import re
# create new config file
# include default.robot
# find all variables in default.robot
# somehow check if all of them are correct

# assuming script is called from the root of the project
DEFAULT_ROBOT = os.path.dirname(os.path.realpath(__file__)) + \
    "/../platform-configs/include/default.robot"
args = sys.argv
def help():
    print(f"Usage: {args[0]} <new config name> [vendor / platform includes]")
    print(f"Example: {args[0]} vendor-name_model-name vendor-common vendor-model1")

def print_variable(variable):
    print(f"{i}: {variable[0]} = {variable[1]}")

if __name__ == "__main__":
    if len(args) < 2: # two args == this scripts name and config name
        help()
        sys.exit(1)
    new_config = args[1]
    vendor_includes = args[2:]
    print(f"Creating new config {new_config} with includes {vendor_includes}")
    
    # read default.robot
    with open(DEFAULT_ROBOT, "r") as f:
        default_robot = f.read()
    # print(default_robot)
    
    default_robot_lines = default_robot.split("\n")
    
    # skip everything before *** Variables ***
    for i, line in enumerate(default_robot_lines):
        if line.startswith("*** Variables ***"):
            break
        default_robot_lines = default_robot_lines[i+1:]

    # remove lines with comments
    default_robot_lines = [line for line in default_robot_lines if not line.startswith("#")]
    
    # lines with variables
    default_robot_lines_w_vars = [line for line in default_robot_lines if line.startswith("${")]

    # extract pairs of variable name and value
    variable_pairs = []
    i=0
    for line in default_robot_lines_w_vars:
        # print(f"{i}: {line}\n\r")
        i+=1
        # when we dont pass a separator any amount of whitespace
        # will be used and thats what we want 
        variable_name, variable_value = re.split(r'\s{2,}', line)
        variable_name = variable_name.strip("${}=")
        variable_pairs.append((variable_name, variable_value))


    for var in variable_pairs:
        print_variable(var)
