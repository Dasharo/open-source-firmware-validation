#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/lib/robot.sh"

print_help() {
  echo "Usage: $0 [test_file | directory_path]"
  echo
  echo "This script is used to execute OSFV Robot Framework tests."
  echo "You can specify either a single test or a whole directory of tests."
  echo
  echo "It expects at least RTE_IP and CONFIG environmental variables to be set"
  echo
  echo "The logs will be saved under logs directory, sorted by platform and date."
  echo "to ensure they are not overwritten by further invocations."
  echo
  echo "Examples:"
  echo "  Execute a single test:"
  echo "    $0 dasharo-compatibility/custom-boot-menu-key.robot"
  echo "  Execute a whole set of tests:"
  echo "    $0 dasharo-compatibility"
  echo
}

if [ "$#" -eq 0 ] || [ ! -e "$1" ]; then
  print_help
  exit 1
fi

execute_robot "$1" "${@:2}"
