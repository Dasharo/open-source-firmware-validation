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
  `dcu` and `${POWER_CTRL}` is set to `none` in the config.
* Docking station tests should be run separately because many checks
  are performed in the same way as on the internal ports. When testing a docking
  station make sure that the appliances are connected to the docking station and
  not directly to the device and the other way around. Otherwise false positives
  will be generated.
