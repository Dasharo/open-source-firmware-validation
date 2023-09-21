#!/usr/bin/env bash

robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v snipeit:no self-tests/keywords-bios.robot
