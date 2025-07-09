<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# DTS tests

This document describes current DTS tests coverage. Tests planned:

* E2E tests;
* Unit tests.

## E2E tests

E2E - End to End tests, tests that verify how DTS goes from start to end for
every user workflow (e.g. installation, update, etc.) for every platform.

Location in OSFV: `dts/dts-e2e.robot`.

These tests include modifications for DTS platform emulation so the tests
could be launched on Qemu. Then every test case choose the workflow by
choosing DTS menu option, and provides credentials (if necessary). So, the
start conditions are: platform configuration and workflow selection.

Then every test case goes through the chosen workflow and checks for expected
behavior. If everything goes as expected - test case passes, otherwise - it
fails.

Control variables:

* `dts_ipxe_link`: useful if you are testing DTS which is not released yet. Just
  put here a link to your script which will load your DTS. By default DTS is
  being booted from `dl.3mdeb.com`. Check [the following
  chapter](#http-server-with-dts-ipxe-boot) for information on how to set up a
  custom HTTP iPXE server with DTS.
* `dpp_email`, `dpp_password`: for DPP credentials, if tests need them.

Launching example:

```bash
robot -b command_log.txt -v snipeit:no -L TRACE -v config:qemu -v rte_ip:127.0.0.1 -v boot_dts_from_ipxe_shell:True -v dts_ipxe_link:http://192.168.0.102:8080/ipxe -v dpp_email:'EMAIL' -v dpp_password:'PASSWORD' -t "E2E006.002*" dts/dts-e2e.robot
```

> Note: replace `EMAIL` and `PASSWORD` with appropriate credentials if required.
> `http://192.168.0.102:8080/ipxe` with your DTS iPXE
> script link.

### HTTP server with DTS iPXE boot

Use [the automation script](https://github.com/Dasharo/open-source-firmware-validation/blob/develop/scripts/ci/ipxe-run.sh)
to prepare an iPXE server with a custom DTS image. After that the `dts.ipxe` can
be used via iPXE shell to boot the DTS image:

```text
chain http://IP:4321/dts.ipxe
```

Where IP is the IP address of the machine where the HTTP server is launched.

## Unit tests

These tests have not been implemented yet.
