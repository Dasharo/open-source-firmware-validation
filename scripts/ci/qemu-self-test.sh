#!/usr/bin/env bash

robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v snipeit:no self-tests/setup-and-boot-menus.robot
robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v snipeit:no self-tests/dasharo-system-features-menus.robot
robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v snipeit:no self-tests/boolean-options.robot
robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v snipeit:no self-tests/numerical-options.robot
