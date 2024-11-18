#!/usr/bin/env bash

git clone https://github.com/Dasharo/preseeds
mkdir qemu-data
preseeds/ubuntu/create_image.sh -o qemu-data/ubuntu.iso
qemu-img create -f qcow2 qemu-data/hdd.qcow2 20G

./qemu-run.sh graphic os_install
robot -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -d ./logs/$(date +%Y.%m.%d_%H.%M.%S)/setup-and-boot-menus -v snipeit:no dasharo-stability/building-boot-os.robot