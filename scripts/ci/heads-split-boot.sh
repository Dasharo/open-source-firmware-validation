#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

# Heads only takes a partition with grub* at its root as /boot, so an OS
# installed with /boot on its root filesystem has no /boot for Heads.  This
# makes a copy-on-write overlay of such a disk with a separate ext4 /boot,
# without root and without changing the original disk:
#   - grows the overlay and adds an ext4 partition at its end
#   - copies /boot (without /boot/efi) of the root filesystem there
#   - mounts it as /boot in /etc/fstab
#   - drops the /boot prefix of the kernel and initrd paths in grub.cfg
# The guest regenerates grub.cfg on its next kernel update (update-grub).
# Needs qemu-img and guestfish (libguestfs).

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") SOURCE OVERLAY [BOOT_SIZE_MIB]

  SOURCE         qcow2 disk with an installed OS keeping /boot on its root
                 filesystem, e.g. qemu-data/hdd.qcow2 (not modified)
  OVERLAY        overlay to create, backed by SOURCE, e.g.
                 qemu-data/hdd-heads.qcow2
  BOOT_SIZE_MIB  size of the new /boot partition, default 1024

Run QEMU with HDD_PATH=OVERLAY afterwards.  SOURCE must not change while
OVERLAY is in use.
EOF
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

SOURCE=$1
OVERLAY=$2
BOOT_SIZE_MIB=${3:-1024}

for tool in qemu-img guestfish; do
  if ! command -v "$tool" &>/dev/null; then
    echo "$tool not found, install it (guestfish: libguestfs-tools)"
    exit 1
  fi
done
if [[ ! -f "$SOURCE" ]]; then
  echo "$SOURCE not found"
  exit 1
fi
if [[ -e "$OVERLAY" ]]; then
  echo "$OVERLAY already exists, remove it first"
  exit 1
fi

src_size=$(qemu-img info --output=json "$SOURCE" |
  python3 -c 'import json, sys; print(json.load(sys.stdin)["virtual-size"])')
# Room for the new partition, its alignment and the backup GPT
new_size=$((src_size + (BOOT_SIZE_MIB + 2) * 1024 * 1024))

qemu-img create -q -f qcow2 -F qcow2 -b "$(realpath "$SOURCE")" \
  "$OVERLAY" "$new_size"

# Runs in the libguestfs appliance, with the OS root filesystem mounted on /
guest_script=$(mktemp)
trap 'rm -f "$guest_script"' EXIT
cat >"$guest_script" <<'EOF'
set -e
boot_dev=$1
root_dev=$2
boot_uuid=$(blkid -s UUID -o value "$boot_dev")
root_uuid=$(blkid -s UUID -o value "$root_dev")
mkdir -p /mnt/newboot
mount "$boot_dev" /mnt/newboot
cd /boot
tar --exclude=./efi -cf - . | tar -C /mnt/newboot -xpf -
mkdir -p /mnt/newboot/efi
cfg=/mnt/newboot/grub/grub.cfg
# Paths relative to the new partition; grub searches for it instead of the
# root filesystem, but the kernel still mounts the root filesystem as /
sed -i -e "s|\([[:space:]]\)/boot/|\1/|g" -e "s|$root_uuid|$boot_uuid|g" \
  -e "s|root=UUID=$boot_uuid|root=UUID=$root_uuid|g" "$cfg"
echo "UUID=$boot_uuid /boot ext4 defaults 0 2" >>/etc/fstab
umount /mnt/newboot
EOF

if [[ "$(guestfish --ro -a "$OVERLAY" run : part-get-parttype /dev/sda)" != "gpt" ]]; then
  echo "$SOURCE: only GPT disks are supported"
  rm -f "$OVERLAY"
  exit 1
fi
# Move the backup GPT to the end of the grown disk
guestfish -a "$OVERLAY" run : part-expand-gpt /dev/sda

root_dev=$(guestfish --ro -a "$OVERLAY" -i mountpoints |
  awk '$2 == "/" { sub(":", "", $1); print $1 }')
parts=$(guestfish --ro -a "$OVERLAY" run : part-list /dev/sda)
last_end=$(awk '/part_end:/ { end = $2 } END { print end }' <<<"$parts")
boot_dev=/dev/sda$(($(grep -c part_num <<<"$parts") + 1))
# The new partition takes the space added at the end, 1 MiB aligned
start=$(((last_end / 512 / 2048 + 1) * 2048))
end=$((start + BOOT_SIZE_MIB * 2048 - 1))

guestfish -a "$OVERLAY" <<EOF
run
part-add /dev/sda p $start $end
mkfs ext4 $boot_dev
mount $root_dev /
upload $guest_script /tmp/split-boot.sh
sh "sh /tmp/split-boot.sh $boot_dev $root_dev"
EOF

echo "$OVERLAY: /boot on $boot_dev, root on $root_dev"
echo "Run QEMU with HDD_PATH=$OVERLAY"
