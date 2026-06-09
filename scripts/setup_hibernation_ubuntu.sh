#!/bin/sh
# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# use: ssh -t ubuntu@$DEVICE_IP 'sudo bash -s' < hibernate.sh
set -e

target_disk=/dev/nvme0n1
swap_size_mb=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) / 1024 + 2048 ))

sgdisk --new=0:0:+"${swap_size_mb}"M --typecode=0:8200 --change-name=0:hibernate-swap "$target_disk"
partprobe "$target_disk"

swap_partition=$(lsblk -lnpo NAME,PARTLABEL "$target_disk" | awk '$2=="hibernate-swap"{print $1; exit}')
[ -n "$swap_partition" ] || { echo "partition not found after creation"; exit 1; }

mkswap "$swap_partition" >/dev/null
swapon "$swap_partition"

resume_uuid=$(blkid -o value -s UUID "$swap_partition")
grep -q "$resume_uuid" /etc/fstab || echo "UUID=$resume_uuid none swap sw 0 0" >> /etc/fstab

sed -i -E 's/resume=[^ "]*//g; s/  +/ /g; s/ "/"/g' /etc/default/grub
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\"|&resume=UUID=$resume_uuid |" /etc/default/grub

echo "RESUME=UUID=$resume_uuid" > /etc/initramfs-tools/conf.d/resume

update-grub
update-initramfs -c -k all
