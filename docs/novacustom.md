<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: MIT
-->

# NovaCustom laptop workflow

> Make sure to proceed with [Getting started section](../README.md#getting-started)
first.

A major hurdle when testing NVC laptops is the lack of an available serial
console, which is the main mode of access for most of our other platforms.
So far, we have been testing our laptops over SSH with the help of
[DCU](https://github.com/Dasharo/dcu).

This approach, however, needs some prerequisites to be satisfied:

* If you have multiple OS'es on your platform, you need to ensure that the OS
  you wish to test is set as the **first boot option**. Currently, switching
  between OSes automatically is not supported.
* Remember to **turn off any flash write protection** - DCU changes UEFI
  options by reading, modifying and writing back SMMSTORE.
* Run tests with the target platform **powered on** and the target OS
**booted**.
* When adding a new laptop platform, make sure that `${OPTIONS_LIB}` is set to
  `dcu` and `${POWER_CTRL}` is set to `none` in the config.
