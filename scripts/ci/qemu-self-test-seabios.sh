#!/usr/bin/env bash

# Define an array of commands
commands=(
  "robot -X -L TRACE -v BIOS_LIB:seabios -v config:qemu-selftests -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/setup-and-boot-seabios -v snipeit:no self-tests/setup-and-boot-seabios.robot"
)

# Initialize a variable to track overall success
overall_success=0

# Execute each command and capture the exit codes
for cmd in "${commands[@]}"; do
  eval $cmd
  exit_code=$?
  if [ $exit_code -ne 0 ]; then
    overall_success=1
  fi
done

# Exit with the appropriate status
exit $overall_success
