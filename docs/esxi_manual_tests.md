<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# Dasharo compatibility: USB HID and MSC Support

## USB001.011 USB devices detection in OS (ESXI)

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Run the following command:

```bash
watch -n1 lsusb
```

1. Connect external USB devices to DUT USB A port and note the result.

**Expected result**

1. After each device is connected to the USB port, a new USB device entry
    in `lsusb` command output should appear.

## USB002.011 USB keyboard detection (ESXI)

**Test setup**

1. Connect the external USB keyboard using the USB port.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Run the following command:

```bash
lsusb
```

1. Press the alphanumeric keys and verify characters typed into the terminal.
1. Press non-alphanumeric keys and verify characters typed into the terminal.
1. Press key combinations with the `Shift`, `Ctrl` and `Alt` modifier keys
    (this tests 2-key rollover).

**Expected result**

1. The external USB keyboard is detected in OS.
1. All standard keyboard keys type the correct characters in the terminal.
1. Key combinations are detected correctly.

# Dasharo Compatibility: NVMe support

## NVM001.011 NVMe support (ESXI)

**Test setup**

1. Insert a NVMe disk into the M.2 slot on the DUT.
1. Install OS on the disc.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Execute the following command:

```bash
esxcli storage core nvme device list
```

**Expected result**

1. The `OPERATING_SYSTEM` has been booted from the NVMe disk correctly.
1. Output from the command contains a line `Is Boot Device: true`
indicating that the nvme drive is the system boot drive.

```bash
t10.NVMe____SSDPR2DPX7002D02T2D80______________________2710003002275A3A
   Display Name: Local NVMe Disk (t10.NVMe____SSDPR2DPX7002D02T2D80______________________2710003002275A3A)
   Has Settable Display Name: true
   Size: 1953514
   Device Type: Direct-Access
   Multipath Plugin: HPP
   Devfs Path: /vmfs/devices/disks/t10.NVMe____SSDPR2DPX7002D02T2D80______________________2710003002275A3A
   Vendor: NVMe
   Model: SSDPR-PX700-02T-80
   Sub NQN: nqn.2014-08.com.maxio:nvme:1602:M.2:G4A007172
   NVMe spec revision: 2.0
   Is dispersed namespace: false
   Is Pseudo: false
   Status: on
   Is RDM Capable: false
   Is Local: true
   Is Removable: false
   Is VVOL PE: false
   Is Offline: false
   Is Perennially Reserved: false
   Thin Provisioning Status: no
   VAAI Status: unsupported
   Other UIDs: vml.058bf2d914fa761fcf1347f01990a7d55c202bc052d3e71db527d65228fa2ff5c6
   Is Shared Clusterwide: false
   Is USB: false
   Is Boot Device: true
   Device Max Queue Depth: 1023
   IOs with competing worlds: 32
```

# Dasharo Compatibility: CPU Status

## CPU001.011 CPU works (ESXI)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot and note the result.

**Expected result**

The `OPERATING_SYSTEM` screen should be displayed.

## CPU002.011 CPU cache enabled (ESXI)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

```bash
esxcli hardware cpu list | grep Cache
```

1. Note the result.

**Expected result**

The output of the command should contain information about all cache levels,
their size and association. Example output:

```bash
L2 Cache Size: 2097152
L2 Cache Associativity: 16
L2 Cache Line Size: 64
L2 Cache CPU Count: 4
L3 Cache Size: 6291456
L3 Cache Associativity: 12
L3 Cache Line Size: 64
L3 Cache CPU Count: 4
```

## CPU003.011 Multiple CPU support (ESXI)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

```bash
esxcli hardware cpu global get
```

1. Note the result.

**Expected result**

The output of the command should contain basic information about the CPU,
including the number of the `CPU Cores`. If it is greater than 1, the DUT
has multiple CPU support. Example results:

```bash
CPU Packages: 1
CPU Cores: 4
CPU Threads: 4
Hyperthreading Active: false
Hyperthreading Supported: false
Hyperthreading Enabled: true
HV Support: 3
```

## CPU004.011 Multiple-core support (ESXI)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

```bash
esxcli hardware cpu list | grep Id
```

1. Note the result.

**Expected result**

The output of the command will show a list of CPU cores on the system
along with the `Package Id:` This designates the socket to which the
core belongs.If the number of cores with the same `Package Id:`
is more than 1, the DUT has multi-core support. Example results:

```bash
Id: 0
Package Id: 0
Id: 1
Package Id: 0
Id: 2
Package Id: 0
Id: 3
Package Id: 0
```

# Dasharo Compatibility: Display ports and LCD support

## DSP002.011 External HDMI display in OS (ESXI)

**Test setup**

1. Connect an HDMI cable to the DUT and a display.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log in by using the proper login and password.
1. Note the result

**Expected result**

1. The image should be displayed on the external HDMI display.

## DSP003.011 External DP display in OS (ESXI)

**Test setup**

1. Connect a Display Port cable to the DUT and a display.

**Test steps**

1. Power on the DUT.
2. Boot into the system.
3. Log in by using the proper login and password.
4. Note the result

**Expected result**

1. The image should be displayed on the external Display Port connected display.

# Dasharo Security: TPM Support

TBD
