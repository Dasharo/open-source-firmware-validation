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
to use mode `vnc` with default port for graphical output being `5900`.

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
