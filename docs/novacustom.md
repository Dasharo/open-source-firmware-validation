<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# NovaCustom laptop workflow

> Make sure to proceed with [Getting started section](../README.md#getting-started)
first.

Serial console for automated testing is available via FTDI FT232 USB-UART
adapter. Having this adapter is a prerequisite for running any automated tests.

To enable serial console on the FTDI UART adapter, follow these steps:

* Insert the FTDI USB-UART adapter into the DUT
* Enable COM0 Serial Console redirection in the UEFI setup menu
* Save and reboot
* Enter Setup Menu -> Boot Maintenance Manager -> Console Options
* In the Console Input Device Select menu, enable the device with USB in the
  device path
* Do the same for Console Output Device Select
* Save and reboot

You should now be getting serial console messages on the FTDI serial adapter.
