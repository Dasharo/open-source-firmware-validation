# SPDX-FileCopyrightText: 2026 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0
#
# Debian (env id 208). Used as-is by rdv3-linuxboot-bringup.robot's
# LBB005.107 (D6) to log into the Debian 12 cloud image
# TARGET_OS_DISK_IMAGE points at - see
# ../../examples/rdv3-coreboot-linuxboot/kb/rdv3.md's D6 section.
#
# A stock cloud image has no root password set at all (cloud-init expects
# to inject SSH keys from a metadata service that does not exist in this
# setup) and its default hostname is whatever cloud-init/DHCP assigns, not
# necessarily "debian" - both DEVICE_OS_PASSWORD and the "debian" in the
# prompts below are placeholders to update once the image is actually
# prepared (e.g. `virt-customize -a debian-12-generic-arm64.raw
# --root-password password:<pw> --hostname debian`), matching the same
# image-prep step already needed for
# ../../examples/rdv3-coreboot-linuxboot/Taskfile.yml's
# TARGET_OS_ROOT_PASSWORD (E4).

DEVICE_OS_USERNAME = "root"
DEVICE_OS_PASSWORD = "changeme"
DEVICE_OS_HOSTNAME = "debian"

DEVICE_OS_USER_PROMPT = f"root@{DEVICE_OS_HOSTNAME}:~#"
DEVICE_OS_ROOT_PROMPT = f"root@{DEVICE_OS_HOSTNAME}:~#"
