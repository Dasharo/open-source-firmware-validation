<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# NovaCustom laptop workflow

> Make sure to proceed with [Getting started section](../README.md#getting-started)
first.

A major hurdle when testing NVC laptops is the lack of an available serial
console, which is the main mode of access for most of our other platforms.

We have so far come up with two solutions to this problem. The one we currently
implement in our testing procedure is plugging an FTDI USB-TTL converter
into the DUT, and setting it as the serial console in the EDK2 setup menu. The
former method was testing our laptops over SSH with the help of
[DCU](https://github.com/Dasharo/dcu). You can find the instructions for both
approaches below.

## FTDI converter

The obvious prerequisite is that you have an FTDI FT232-based USB-TTL
converter. Currently, that's the only hardware that's been tested, and the
driver seems to be rather picky, so a random USB-TTL might not cut it.

The steps are:

* Plug the converter into the DUT
* Enable `Serial Console Redirection` from the `Dasharo System Features` menu
* Navigate to `Boot Maintenance Manager` -> `Console Options`
* Find and select the FTDI terminal device in each Console Input, Console
  Output and Stderr menus. It will likely appear at the very end, the device
  path should resemble

  ```
    PciRoot(0x0)/Pci(0x14,0x0)/USB(0x0,0x0)/Uart(115200,8,N,1)/TtyTerm()
  ```

After that, the laptop can be used just like a regular platform with serial
console access. Just **make sure** you set up the OS'es to use the right
console, eg. `ttyUSB0`, not `ttyS1`.

## SSH + DCU

If you couldn't manage to get a hold of an FTDI converter, you will need to
set up SSH on the platform and change the UEFI options by reading, modifying
and writing back the NVRAM region with the help of DCU.

* If you have multiple OS'es on your platform, you need to ensure that the
  **first boot option** is set to a Linux system. Switching between OSes
  automatically is only supported if the **first boot option** is a Linux
  system.
    - When a test flashes the firmware, the bootorder will be restored to default.
  You can prevent this in two ways, although both of them require performing
  tests for different OS's separately:
        * Enter the UEFI Shell and temporarily modify the bootentry of the unwanted
    OS on the drive so that it won't be detected. Delete the entry from the
    bootmenu in the Setup menu.
        * Change the bootorder in the Setup menu, read the firmware image with a
    custom bootorder and use this image to flash the device in the future.
* Remember to use DCU to **turn off any flash write protection** in the firmware
image used for testing using. Flashing the laptops can only be performed via the
internal programmer. If any locks are present the flashing will fail.
* Run tests with the target platform **powered on** and the target OS
**booted**.
* When adding a new laptop platform, make sure that `${OPTIONS_LIB}` is set to
  `options-lib_dcu` and `${POWER_CTRL}` is set to `none` in the config.
* Docking station tests should be run separately because many checks
  are performed in the same way as on the internal ports. When testing a docking
  station make sure that the appliances are connected to the docking station and
  not directly to the device and the other way around. Otherwise false positives
  will be generated.
* Make sure to connect the laptop using an ethernet cable, not via WiFi.
  Some Operating Systems use MAC randomization on ,or similar mechanisms, on
  wireless interfaces, which is not being handled right now. This might lead to
  losing connection when rebooting to another OS, as the DUT IP address is
  configured as constant in platform configs.
