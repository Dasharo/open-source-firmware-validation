#!/usr/bin/env bash

# Default value for autofix flag
AUTOFIX="false"

usage() {
    echo "Usage: $0 <robot_variable_file1> <robot_variable_file2> ..."
    echo "   -f: Autofix mode, removes lines containing unused variables from the robot variable file"
    echo "   <robot_variable_file>: Robot file containing variable definitions"
    exit 1
}

# Process command-line options
while getopts ":f" opt; do
    case $opt in
        f)
            AUTOFIX=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Shift the options so that $1 is the first non-option argument
shift $((OPTIND - 1))

if [ "$#" -eq 0 ]; then
    usage
fi

# Loop through each provided robot variable file
for robot_variable_file in "$@"; do
    # Specify the file paths to search for variable usage
    file_paths=("dasharo-compatibility" "dasharo-security" "dasharo-performance" "dasharo-stability" "lib" "keywords.robot")

    # Read variables from the specified robot variable file (only consider the leftmost variable on each line)
    mapfile -t variables < <(awk -F'=' '/^\$\{[^}]+\}=/{gsub(/[[:space:]]/, "", $1); print $1}' "$robot_variable_file" | sort -u)

    # Initialize an associative array to track variable usage
    declare -A variable_usage

    # Loop through each file path
    for path in "${file_paths[@]}"; do
        # Loop through each variable
        for var in "${variables[@]}"; do
            # Use grep to check if the variable is used in the files
            grep_result=$(grep "$var" "$path" -ir)

            # If the grep result is not empty, mark the variable as used
            if [ -n "$grep_result" ]; then
                variable_usage["$var"]=1
            fi
        done
    done

    # Print unused variables count and list
    unused_count=0
    unused_variables=()

    for var in "${variables[@]}"; do
        if [ -z "${variable_usage[$var]}" ]; then
            unused_variables+=("$var")
            ((unused_count++))
        fi
    done

    # Autofix: Remove lines containing unused variables from the source file
    if [ "$AUTOFIX" == "true" ] && [ "$unused_count" -gt 0 ]; then
        echo "Autofixing: Removing lines containing unused variables from $robot_variable_file"
        for unused_var in "${unused_variables[@]}"; do
            sed -i "/^$unused_var=/d" "$robot_variable_file"
        done
    fi

    # Print messages for each file
    if [ "$unused_count" -eq 0 ]; then
        echo "No unused variables found in $robot_variable_file."
    else
        echo "Found $unused_count defined variables not used in $robot_variable_file:"
        for unused_var in "${unused_variables[@]}"; do
            echo "$unused_var"
        done
    fi
done
