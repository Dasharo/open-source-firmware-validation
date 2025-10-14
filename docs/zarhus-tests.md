<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# Zarhus tests

This document describes tests implemented for Zarhus OS on x86 architecture,
how to test run those tests and how to test Zarhus on QEMU manually.

## Manual tests on QEMU

1. To test Zarhus image, decompress it to raw image first

    ```sh
    bmaptool copy zarhus-base-image-genericx86-64.rootfs.wic.gz zarhus.img
    ```

1. If testing Zarhus image with meta-otab feature (A/B update), then you have
    to resize resulting image so there is space to create 5-th partition for
    rootfs overlay during first boot.
    The final size should depend on what you'll be testing e.g. ZPB image will
    need at least a couple of GB.

    Below is example command to increase image size to 20 GB

    ```sh
    dd if=/dev/zero of=zarhus.img bs=1 count=0 seek=20G
    ```

    Depending on your filesystem, this extra space might not take up any real
    space before using it e.g.:

    ```sh
    $ ls -lh zarhus.img
    -rw-r--r--. 1 iwans iwans 20G Oct 13 20:43 zarhus.img
    $ du -h zarhus.img
    6.2G    zarhus.img
    ```

1. You have couple options to run Zarhus in QEMU:

    - In OSFV

        ```sh
        HDD_PATH=<path/to/>zarhus.img ./scripts/ci/qemu-run.sh graphic os
        ```

    - `run-qemu.sh` script in `meta-dts`:

        ```sh
        meta-dts/scripts/run-qemu.sh -e -s -t -m 8G zarhus.img
        ```

        Depending on image and use case, you might need only `-e` argument.
        Zarhus with encryption feature might require more RAM (8 GB), otherwise
        it sometimes complains, that some key operations might fail due to not
        enough free RAM.
        Check `./run-qemu.sh -h` for more information on what each option does.

    - Run `qemu-system-x86-64` command manually

### Testing Zarhus Provisioning Box OS

Currently, to manually test most of ZPB features you need to use `run-qemu.sh`
script as most commands require USB stick to use as an encrypted key storage.
As of writing this, `./scripts/ci/qemu-run.sh` doesn't offer such a feature.
It's possible to dynamically add USB via `Add USB To Qemu` keyword, so a
determined person might be able to do it without too much trouble.

To run QEMU with all needed parts for ZPB testing you need to also:

1. Create 2 empty files that'll be used as USB sticks in QEMU

    ```sh
    dd if=/dev/zero of=encrypted_usb_1 bs=1M count=300
    dd if=/dev/zero of=encrypted_usb_2 bs=1M count=300
    ```

1. Add those 2 files when running QEMU:

    ```sh
    ./run-qemu.sh -e -s -t -m 8G -u encrypted_usb_1 -u encrypted_usb_2  zarhus.img
    ```

You should see those 2 files as USB devices inside Linux e.g.:

```sh
genericx86-64:~$ ls "/dev/disk/by-id/usb-QEMU_QEMU_HARDDISK_1-00"*
/dev/disk/by-id/usb-QEMU_QEMU_HARDDISK_1-0000:00:03.0-1-0:0
/dev/disk/by-id/usb-QEMU_QEMU_HARDDISK_1-0000:00:03.0-2-0:0
genericx86-64:~$ lsblk | grep 300M
sdb                  8:16   1  300M  0 disk
sdc                  8:32   1  300M  0 disk
genericx86-64:~$ cat /sys/class/block/sdb/removable
1
```

## Automatic tests

**Important**: To run OSFV tests on Zarhus OS you have to make sure that kernel
command line contains `console=ttyS0,115200` instead of `console=tty1`. This
config will result in output from initramfs showing on serial. Some of the
keywords depend on being able to read this output. By default, `meta-zarhus` is
built with console outputting to serial, but it might be different if you are
testing custom images based on `meta-zarhus`. You can verify this by:
- booting into Zarhus OS and checking contents of `/proc/cmdline`
- checking value of `CMDLINE_CONSOLE` in `kas` shell:

    ```sh
    bitbake-getvar CMDLINE_CONSOLE -r zarhus-base-image
    #
    # $CMDLINE_CONSOLE
    #   set? /build/../repo/meta-zarhus-bsp/meta-zarhus-bsp-x86_64/recipes-zarhus/images/zarhus-uki.inc:6
    #     "ttyS0,115200"
    CMDLINE_CONSOLE="ttyS0,115200"
    ```

For Zarhus Provisioning Box you might have to change this value in `kas`
configuration file (e.g. `common.yml`).

OSFV tests require DTS with `efibootmgr` command which is available since
`v2.7.2-rc1`. Until `non-rc` release you have to add 2 additional arguments to
`robot` commands:

```sh
robot -v boot_dts_from_ipxe_shell:True \
    -v dts_ipxe_link:https://boot.dasharo.com/dts/dts-rc.ipxe
```

Be patient when running tests, especially when testing ZPB as Suite Setup can
take a while. It installs and prepares Zarhus OS

### Future improvements

Make each test start from the same state. As of now, all tests might modify
Zarhus OS state by e.g. changing active slot. Next test has to either take that
into account and be fairly flexible or bring back Zarhus OS to expected state.

On QEMU it's possible to create copy of prepared Zarhus OS during suite setup
(`HDD_PATH`), and then, in test setup, we could copy this backup. Might require:
- removing and adding drive again via `Add HDD To Qemu`/`Remove Drive From Qemu`
- manually starting `zarhus-efi-setup.service` (runs only on first boot) to
    recreate Boot Order if needed (and EFI variables)

On hardware, it might be unreasonable to flash/clone Zarhus OS for every test,
but we could:

- Create fw backup with `Read Firmware` in test setup
- Flash backup with `Flash Firmware` in test teardown
- Clear some/all files in `upperdir` on `rwoverlay` or even delete whole
    `rwoverlay` so it's recreated on first boot.

### QEMU

Zarhus Provisioning Box tests don't support QEMU. For Zarhus OS:

1. Run QEMU

    ```sh
    ./scripts/ci/qemu-run.sh graphic os
    ```

    If you don't want to lose everything stored in default `.qcow2` file, you
    can create and pass empty file:

    ```sh
    dd if=/dev/zero of=hdd.img bs=1 count=0 seek=20G
    HDD_PATH=hdd.img ./scripts/ci/qemu-run.sh graphic os
    ```

1. Run Robot Framework tests (for more information read
    [README.md](../README.md)), e.g.:

    ```sh
    robot -L TRACE -v rte_ip:127.0.0.1 -v config:qemu -v snipeit:no \
        -v features:encryption,otab \
        -v zarhus_wic_gz_file:../zarhus-base-image-genericx86-64.rootfs.wic.gz \
        zarhus-x86/zarhus.robot
    ```

    For all needed variables and their description read
    [Test Variables](#test-variables)

### Hardware

#### Zarhus OS

Example test run that succeeded:

```sh
robot -L TRACE -b command_log.txt -v rte_ip:192.168.10.168 -v config:odroid-h4-plus -v snipeit:no \
    -v boot_dts_from_ipxe_shell:True \
    -v dts_ipxe_link:https://boot.dasharo.com/dts/dts-rc.ipxe \
    -v features:encryption,otab \
    -v zarhus_wic_gz_file:../zarhus-base-image-genericx86-64.rootfs.wic.gz \
    -v zarhus_swu_file:../zarhus-swu-image-genericx86-64.rootfs.swu \
    -v target_device:nvme0n1 zarhus-x86/zarhus.robot
```

#### Zarhus Provisioning Box

Before starting, flash firmware manually. Currently, tests do not flash firmware
automatically before running them which might result in those tests failing due
to firmware state.

Example command to run tests:

```sh
robot -L TRACE -b command_log.txt -v rte_ip:192.168.10.168 -v config:odroid-h4-plus -v snipeit:no -v boot_dts_from_ipxe_shell:True \
    -v dts_ipxe_link:https://boot.dasharo.com/dts/dts-rc.ipxe \
    -v features:encryption,otab \
    -v zarhus_bootstrap_file:../yocto/zarhus-dtrpb/bootstrap.img \
    zarhus-x86/zarhus-provisioning-preparation.robot
```

To prepare bootstrap image follow `usage-dev.md` documentation in
`zarhus/provisioning-box` repository on Gitea. To use local version of ZPB OS
you might have to mount and replace ZPB OS image (until support for using local
files when creating bootstrap image is added)

```sh
loop_dev=$(sudo losetup --show -Pf bootstrap.img)
sudo mount "${loop_dev}p3" /mnt
sudo cp <path/to/>zarhus-base-image-genericx86-64.rootfs.wic.{gz,bmap} /mnt/
sudo umount /mnt
sudo losetup -d "${loop_dev}"
```

### Test Variables

To run Zarhus OS tests you need to set couple variables depending on which
tests you want to run.

- `features` - list of features that tested Zarhus OS contains, split by
    comma (`,`), e.g.:

    - `encryption` - rootfs encryption feature (added via `encryption.yml`)
    - `otab` - A/B updates, added via `otab.yml`

    `hardening` feature is assumed always enabled (added via `hardening.yml`)
    as current tests and keywords use `user` account which is added in this
    feature. Without this feature only `debug` images could be tested (with
    enabled `root` account).

    Some keywords behave differently if some feature is present, mainly
    `encryption` feature which requires writing disk password when booting
    Zarhus OS.
- `zarhus_wic_gz_file` - path to `.wic.gz` file with Zarhus OS to be tested.
    It'll be flashed to `/dev/${TARGET_DEVICE}` on DUT if testing on hardware
    or to `/dev/sda` (which is file under `HDD_PATH`)
- `target_device` - used when testing on hardware. This is block device that'll
    be used to flash Zarhus OS to.
- `zarhus_swu_file` - path to `.swu` file, used for otab updates, needed by some
    update tests.

### ZPB variables

- `zarhus_bootstrap_file` - path do bootstrap image (uncompressed) that'll be
    flashed directly to USB

## Suites

- `zarhus.robot` - tests for Zarhus OS. Incompatible with ZPB (usage of sudo,
  updates have different requirements)
- `zarhus-provisioning-preparation.robot` - tests done after preparing ZPB with
    bootstrap USB stick (configure firmware, install ZPB OS)
- `zarhus-provisioning.robot` - tests done after platform is set up (except
  enrolling TPM2 as keywords expect password prompt, can be improved in the
  future)
