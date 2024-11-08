#!/usr/bin/env bash

# Define an array of commands
commands=(
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/setup-and-boot-menus -v snipeit:no self-tests/setup-and-boot-menus.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/dasharo-system-features-menus -v snipeit:no self-tests/dasharo-system-features-menus.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/boolean-options -v snipeit:no self-tests/boolean-options.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/numerical-options -v snipeit:no self-tests/numerical-options.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/list-options -v snipeit:no self-tests/list-options.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/secure-boot -v snipeit:no self-tests/secure-boot.robot"
  "robot -X -L TRACE -v BIOS_LIB:uefi -v config:qemu-selftests-uefi -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/self-tests -v snipeit:no self-tests/terminal.robot"
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
