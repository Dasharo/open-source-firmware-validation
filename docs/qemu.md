<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# QEMU workflow

> Make sure to proceed with [Getting started section](../README.md#getting-started)
first.

Many of the test and keywords can be tested in emulation environment. This
can greatly increase the development speed:
* there is no need to acquire hardware,
* there is no need to flash hardware, or resolve other hardware-related
  problems,
* the boot time (and responsivness in general) is much faster.

## Booting

Following script assume that you have `OVMF_CODE.fd` and `OVMF_VARS.fd` in you
current working directory. If those binaries will not be found script will
download latest release of Dasharo (UEFI) for QEMU Q35.

If you want to use script in development workflow, most likely you have already built
Dasharo (UEFI) for QEMU Q35 according to
[this instruction](https://docs.dasharo.com/variants/qemu_q35/building-manual/).
In that case you would like to provide directory with Dasharo (UEFI) binaries as
environment variable (`DIR`).

You may also decide to not use graphics user interface for QEMU. In that case
choose mode `nographic`. If you run QEMU on a remote machine you may consider
using the `vnc` mode with default port for graphical output being `5900`.

Dasharo (UEFI) in QEMU can be started with:

```bash
./scripts/ci/qemu-run.sh graphic firmware
```

In this mode, a graphical QEMU window would popup, so you can observe the test
flow, or control it manually. The actual testing will happen over
serial, which is exposed via telnet. For more modes and options, please refer
to the script's help text.

You may also build customized Dasharo firmware for QEMU (e.g. with some Dasharo
options enabled or disabled). In such a case, please refer to:
* [Building Manual in Dasharo for QEMU documentation](https://docs.dasharo.com/variants/qemu_q35/building-manual/)
* [Development section in Dasharo for QEMU documentation](https://docs.dasharo.com/variants/qemu_q35/development/)

Refer to the [latest releases](https://github.com/Dasharo/edk2/releases/latest/)
to see which test have been proven to work on QEMU so far.

You may also refer to the `./scripts/ci/qemu-self-test.sh`, where we aim to
keep testing common keywords, to ensure of their correct operation.

## Running tests

Here is an example command for running tests on QEMU (make sure that you are in
Python virtual environment):

```bash
robot -b command_log.txt -v snipeit:no -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -t "*" dts/dts-e2e.robot
```

> Note: You do not have to reserve QEMU via `snipeit` therefore `-v snipeit:no`
> is being used. Use QEMU config `-v config:qemu`, and, as a RTE IP, use
> `127.0.0.1`. Test suite `dts/dts-tests.robot` is shown here as an example.

## Connecting to the machine

The machine's serial port is available over Telnet on `127.0.0.1:1234`.
You can connect to the serial port using telnet:

```bash
telnet 127.0.0.1 1234
```

The network connection to the machine is available on `127.0.0.1:5222`
For example, you can connect to the machine via SSH, if the booted OS
supports it:

```bash
ssh 127.0.0.1 -p 5222
```

## Heads

The Heads tests in `dasharo-compatibility/heads-bootloader-support.robot`
can run against Heads for the QEMU `qemu-coreboot-*` boards. Heads mirrors
its menus and prompts to the serial console (text-mode whiptail next to the
graphical one on the display), so the tests drive it over serial like on
hardware. On QEMU, the manual steps of these tests are automated; the ones
that need DTS/DES, Qubes OS or a build machine are skipped.

### Requirements

* A Heads ROM for a `qemu-coreboot-*` board (16 MiB), built from Heads with
  serial mirroring and writable flash, e.g. `build/x86/<board>/heads-*.rom`.
  Heads reflashes it (GPG keys, settings), so give QEMU a copy.
* A USB security dongle for OEM Factory Reset, TOTP/HOTP and TPM reset
  (HDS001, HDS002, HDS018, HDS019): the emulated Nitrokey 3 from Heads'
  `bin/qemu-nk3-usbip.sh`, attached to the host before QEMU starts. Without
  one, use `HEADS_USB_TOKEN=none` and `-v heads_usb_token:none`; those tests
  are skipped.
* `swtpm`, `sfdisk`, `mkfs.vfat`, `mtools` and `gpg` on the host: the GPG
  tests make USB disk images with test keys at runtime.
* A Heads build whose coreboot clears the XSDT before filling it (Heads'
  `patches/coreboot-25.09/0013-acpi-Clear-RSDT-and-XSDT-entries-before-filling-them.patch`).
  `Power On` is a warm reset (QMP `system_reset`), and without the fix every
  boot after a reset has a corrupted XSDT: Linux loads no ACPI namespace, so
  Heads has no TPM and cannot power off (HDS009, and every test that reflashes
  and reboots, fail).
* Heads with the fixes these tests found: "Export public GPG key to USB
  drive" (`gpg_export_pubkey_to_usb` was missing, HDS015) and "Clear GPG
  key(s) and reset all user settings" without an installed OS (HDS017), and
  `/bin/whiptail` not hanging when a dialog is answered on the serial console
  while the graphical one is still being drawn (HDS017, and any dialog the
  tests answer right away).

### Running

```bash
mkdir -p qemu-data
cp <heads>/build/x86/qemu-coreboot-fbwhiptail-tpm2-hotp/heads-*.rom qemu-data/heads.rom
cp qemu-data/heads.rom qemu-data/heads-clean.rom
# in Heads: bin/qemu-nk3-usbip.sh start qemu-coreboot-fbwhiptail-tpm2-hotp
FW_TYPE=heads SERIAL_LOG=qemu-data/serial.log ./scripts/ci/qemu-run.sh vnc firmware
```

```bash
robot -L TRACE -v config:qemu-heads -v snipeit:no -v rte_ip:127.0.0.1 \
  -v "INCLUDE_TAGS:[]" -v heads_rom_file:qemu-data/heads-clean.rom \
  dasharo-compatibility/heads-bootloader-support.robot
```

`FW_TYPE=heads` makes `qemu-run.sh` boot from the writable 16 MiB flash
image (`QEMU_FW_FILE`, default `qemu-data/heads.rom`), keep the guest clock
in UTC for TOTP, and keep QEMU running when Heads powers off (Heads powers
off instead of rebooting on QEMU; `Power On` resets the machine through
QMP). `HEADS_USB_TOKEN` selects the dongle (`nk3`, `canokey` or `none`),
`TPM_VERSION=1.2` the TPM of the `-tpm1` boards, `SERIAL_LOG` a file
getting a copy of the serial console, and `SERIAL_WAIT=1` holds the VM until
a client connects to the serial console (QEMU drops serial output while no
client is connected).

Platform config variables (`platform-configs/qemu-heads.robot`):

* `heads_rom_file`: unmodified ROM for HDS012 (flashing a standalone image);
  the test is skipped without it.
* `heads_usb_token`: `nk3` (default), `canokey` or `none`.
* `heads_qemu_workdir`: where test keys and USB images are made
  (default `/tmp/osfv/heads`).

The suite is order sensitive: HDS001 provisions the dongle and TOTP for
HDS002, HDS011 to HDS017 build on each other's keyring, and HDS017 resets
the configuration at the end. Start from a fresh flash image and TPM state
(`/tmp/osfv/tpm`) for a full run.

Not automated on QEMU yet: HDS003 (boot from USB, needs a test ISO), HDS006
(default boot, needs an installed OS) and HDS016 (`gpg --card-edit` only runs
on the display, not on the serial console).
