<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: MIT
-->

# Windows HLK - overview

The Windows HLK (Hardware Lab Kit) is a test framework used to test hardware
devices and drivers for Windows 11, Windows 10 and all versions of Windows
Server, starting with Windows Server 2016. To qualify for the Windows
Hardware Compatibility Program, any product must pass specific tests using
the Windows HLK.

The following documentation describes the method for setting up a testing
environment based on Windows HLK.

## Prerequisites

As Windows HLK documentation says, the test environment contains at least two
components: `Test Server` and `Test System`.

A `Test Server` is understood as a device with HLK software installed. Given
the limitations of the hardware (HLK Manager might be set only on a few systems),
the best solution is to set Virtual Machine with the dedicated image called
`Virtual HLK`. Keep in mind that the VHLK package takes up about 30 GB, so the
best solution is to put the virtual machine on a separate machine with specific
hardware resources.

A `Test System` is understood as any device with installed Windows on which
certification tests should be carried out.

Both types of devices should be connected to the same network and should be
recognizable as the same workgroup. Otherwise, it will not be possible to
perform any tests.

## Steps

Windows HLK has very extensive documentation. However, since it has considerable
redundancy, below in the form of points are listed the next steps, the execution
of which guarantees the production of a working test setup.

The following section of the documentation is divided into four parts. The first
describes the preliminary steps, the second how to configure the test server,
the third how to configure the test device, and the fourth how to run the tests.

### First steps

1. Set out at least two devices that meet the conditions described in the
    section [Prerequisites](#prerequisites).
1. On both devices install Windows 11.
1. Check on both machines that the internet connection is correct. Also, check
    that both devices are on the same subnet.

### Test server configuration

The test server is already prepared - you can connect to it via RDP. All
credentials and IP are present in the BitWarden at `Windows Server 2019 HLK VM`
entry.

If for some reason you wish to set up your own test server, follow the
[official documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/getstarted-vhlk).
During network configuration, some problems might arise - option
`Turn on network discovery` might spontaneously lock up. In such a situation, it
is advisable to use the following
[documentation](https://www.alphr.com/network-discovery-turned-off/) to fix the
problem with network discovery.

### Test system configuration

1. Install HLK Client ([official
documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-2--install-client-on-the-test-system-s-)):
    - Enable network discovery - the easiest way is to go to the network
      directory in explorer, then a warning will pop up that network discovery
      is off - click on it to enable it.
    - Go to the network directory and find the HLK Test Server - if it doesn't
      appear, just enter its name in the navigation bar, for example:
      `\\WIN-QSJ7L35S5B7`, then enter its credentials.
    - Go to the `HLKInstall\Client` location and run `Setup.cmd`.
1. Switch to HLK Test server (for example via RDP - credentials are stored in
our Bitwarden)
1. Prepare machine pool ([official
documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-3-create-a-machine-pool)):
    - Go to HLK Studio
    - Enter _Configuration_ page
    - Right click on `$ (Root)` and choose _Create Machine Pool_
    - Move test device(s) from _Default Pool_ to newly created one (drag &
      drop)
    - In the new pool, right-click on the test device and choose _Change
      Machine Status_, then select Ready; the _Status_ column should change to
      _Ready_
1. Create the test project ([official
documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-4-create-a-project)):
    - In Windows HLK Studio, choose the _Project_ tab and select _Create
      project_
1. Select the test target([official
documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-5--select-target-to-test)):
    - Go to the _Selection_ tab and choose a machine pool
    - Select target(s): Windows HLK Studio detects all features that a device
      implements. An individually testable feature is called a target. A device
      may contain multiple targets, represented by one or more hardware IDs.

### Running tests

The mechanism for running the tests has been briefly described in the
[documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-6-select-and-run-tests).

## Additional information

1. Basic operations related to the logs have been described in the
    [documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-7-view-test-results-and-log-files).
1. The mechanism for creating submission packages has been described in the
    following
    [documentation](https://learn.microsoft.com/en-us/windows-hardware/test/hlk/getstarted/step-8-create-a-submission-package).
