<!--
SPDX-FileCopyrightText: 2024 3mdeb <contact@3mdeb.com>

SPDX-License-Identifier: Apache-2.0
-->

# Dasharo compatibility: USB HID and MSC Support

## USB001.010 USB devices detection in OS (XCP-NG)

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

## USB002.010 USB keyboard detection (XCP-NG)

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

1. Run the following command in the terminal:

    ```bash
    showkey
    ```

1. Test the alphanumeric keys and note the generated keycodes.
1. Test non-alphanumeric keys and verify that they generate the correct
    keycodes.
1. Test key combinations with the `Shift`, `Ctrl` and `Alt` modifier keys
    (this tests 2-key rollover).

**Expected result**

1. The external USB keyboard is detected in OS.
1. All standard keyboard keys generate the correct keycodes and events as per
   their labels.
1. Key combinations are detected correctly.

# Dasharo Compatibility: NVMe support

## NVM001.010 NVMe support (XCP-NG)

**Test setup**

1. Insert a NVMe disk into the M.2 slot on the DUT.
1. Install OS on the disc.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Execute the following command:

```bash
sudo mount | grep 'on / '
```

**Expected result**

1. The `OPERATING_SYSTEM` has been booted from the NVMe disk correctly.
1. Output in Terminal indicates that system partition is installed on the NVMe
    disk:

```bash
/dev/nvme* on / tpe ext3 (rw,relatime)
```

# Dasharo Compatibility: CPU Status

## CPU001.010 CPU works (XCP-NG)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot and note the result.

**Expected result**

The `OPERATING_SYSTEM` screen should be displayed.

## CPU002.010 CPU cache enabled (XCP-NG)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

    ```bash
    getconf -a | grep CACHE
    ```

1. Note the result.

**Expected result**

The output of the command should contain information about all cache levels,
their size and association. Example output:

```bash
LEVEL1_ICACHE_SIZE                 32768
LEVEL1_ICACHE_ASSOC                32
LEVEL1_ICACHE_LINESIZE             128
LEVEL1_DCACHE_SIZE                 32768
LEVEL1_DCACHE_ASSOC                32
LEVEL1_DCACHE_LINESIZE             128
LEVEL2_CACHE_SIZE                  524288
LEVEL2_CACHE_ASSOC                 2048
LEVEL2_CACHE_LINESIZE              32
LEVEL3_CACHE_SIZE                  10485760
LEVEL3_CACHE_ASSOC                 40960
LEVEL3_CACHE_LINESIZE              32
LEVEL4_CACHE_SIZE                  0
LEVEL4_CACHE_ASSOC                 0
LEVEL4_CACHE_LINESIZE              0
```

## CPU003.010 Multiple CPU support (XCP-NG)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

    ```bash
    lscpu
    ```

1. Note the result.

**Expected result**

The output of the command should contain basic information about the CPU,
including the number of the `CPU (s)`. If `CPU(s)` are more than 1, the DUT
has multiple CPU support. Example results:

```bash
Architecture:                    ppc64le
Byte Order:                      Little Endian
CPU(s):                          32
On-line CPU(s) list:             0-31
Thread(s) per core:              4
Core(s) per socket:              4
Socket(s):                       2
NUMA node(s):                    2
```

## CPU004.010 Multiple-core support (XCP-NG)

**Test steps**

1. Power on the DUT.
1. Wait for the `OPERATING_SYSTEM` to boot.
1. Execute below command in terminal:

    ```bash
    lscpu
    ```

1. Note the result.

**Expected result**

The output of the command should contain basic information about the CPU,
including the number of the `Core(s) per socket`. If `Core(s) per socket`
are more than 1, the DUT has multi-core support. Example results:

```bash
Architecture:                    ppc64le
Byte Order:                      Little Endian
CPU(s):                          32
On-line CPU(s) list:             0-31
Thread(s) per core:              4
Core(s) per socket:              4
Socket(s):                       2
NUMA node(s):                    2
```

# Dasharo Compatibility: Display ports and LCD support

## DSP002.010 External HDMI display in OS (XCP-NG)

**Test setup**

1. Connect an HDMI cable to the DUT and a display.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log in by using the proper login and password.
1. Note the result

**Expected result**

1. The image should be displayed on the external HDMI display.

## DSP003.010 External DP display in OS (XCP-NG)

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

## TPM001.010 TPM Support (XCP-NG)

**Test setup**

1. Enable CentOS 7 repository, follow this
[guide](https://blog.guillaumea.fr/post/enabling-centos7-sources-on-xcp-ng-after-eol).
1. Install the `tpm2-tools` package:
`yum install tpm2-tools.x86_64 --enablerepo=base,updates`.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Start tpm communication broker by executing the following command:

```bash
systemctl start tpm2-abrmd
```

1. Execute the following command in the terminal:

```bash
tpm2_pcrlist
```

**Expected result**

The command should return a list of PCRs and their contents.

Output example for TPM2.0:

```text
sha1 :
  0  : 3a3f780f11a4b49969fcaa80cd6e3957c33b2275
  1  : 8a074fdf65a11e5dbf02d25e7f26b00c26c98b41
  2  : c36c2509d636c9cfa075d6d0a03b7a37bec14ee9
  3  : 3a3f780f11a4b49969fcaa80cd6e3957c33b2275
  4  : 2d247bb671ec17ded623ca45967df5482517291b
  5  : 49d543eb1d1df3439d9fca695ee47b8cdf4b9e2f
  6  : 3a3f780f11a4b49969fcaa80cd6e3957c33b2275
  7  : 3a3f780f11a4b49969fcaa80cd6e3957c33b2275
  8  : 0000000000000000000000000000000000000000
  9  : 0000000000000000000000000000000000000000
  10 : 0000000000000000000000000000000000000000
  11 : 0000000000000000000000000000000000000000
  12 : 0000000000000000000000000000000000000000
  13 : 0000000000000000000000000000000000000000
  14 : 0000000000000000000000000000000000000000
  15 : 0000000000000000000000000000000000000000
  16 : 0000000000000000000000000000000000000000
  17 : ffffffffffffffffffffffffffffffffffffffff
  18 : ffffffffffffffffffffffffffffffffffffffff
  19 : ffffffffffffffffffffffffffffffffffffffff
  20 : ffffffffffffffffffffffffffffffffffffffff
  21 : ffffffffffffffffffffffffffffffffffffffff
  22 : ffffffffffffffffffffffffffffffffffffffff
  23 : 0000000000000000000000000000000000000000
sha256 :
  0  : d27cc12614b5f4ff85ed109495e320fb1e5495eb28d507e952d51091e7ae2a72
  1  : b29a64bd6895966b777eb803f45e6bbffade81cc1b996a34f7cbd26f1d04028b
  2  : 3122422e43b9fbfc0cb70eb467b55e99ec61462370e6b15c515484f821e1d4d9
  3  : 909e4261938378c0556a4c335c38718d1c313bd151fdf222df674aabb7aeee97
  4  : 984763b42633ee11e5167e2f67c2e6879bd6efac683f1df1ef16d7ce96d4b49b
  5  : dab92c45eeb765e29784f8cc33f92d0a39afed173f2b07e0e328586c3c3b19ed
  6  : d27cc12614b5f4ff85ed109495e320fb1e5495eb28d507e952d51091e7ae2a72
  7  : d27cc12614b5f4ff85ed109495e320fb1e5495eb28d507e952d51091e7ae2a72
  8  : 0000000000000000000000000000000000000000000000000000000000000000
  9  : 0000000000000000000000000000000000000000000000000000000000000000
  10 : 0000000000000000000000000000000000000000000000000000000000000000
  11 : 0000000000000000000000000000000000000000000000000000000000000000
  12 : 0000000000000000000000000000000000000000000000000000000000000000
  13 : 0000000000000000000000000000000000000000000000000000000000000000
  14 : 0000000000000000000000000000000000000000000000000000000000000000
  15 : 0000000000000000000000000000000000000000000000000000000000000000
  16 : 0000000000000000000000000000000000000000000000000000000000000000
  17 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  18 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  19 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  20 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  21 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  22 : ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  23 : 0000000000000000000000000000000000000000000000000000000000000000
```

## TPM002.010 Verify TPM version (XCP-NG)

**Test setup**

1. Enable CentOS 7 repository, follow this
[guide](https://blog.guillaumea.fr/post/enabling-centos7-sources-on-xcp-ng-after-eol).
1. Install the `tpm2-tools` package:
`yum install tpm2-tools.x86_64 --enablerepo=base,updates`.

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Start tpm communication broker by executing the following command:

```bash
systemctl start tpm2-abrmd
```

1. Check the version of used TPM - execute the following command in the
    terminal:

```bash
tpm2_getcap -c properties-fixed | grep -A 2  TPM_PT_FAMILY_INDICATOR
```

**Expected result**

The command should return the TPM version.

Example output:

```bash
TPM_PT_FAMILY_INDICATOR:
  as UINT32:                0x08322e3000
  as string:                "2.0"
```

## TPM003.010 Check TPM Physical Presence Interface (XCP-NG)

**Test steps**

1. Power on the DUT.
1. Boot into the system.
1. Log into the system by using the proper login and password.
1. Execute the following command to check the version of TPM
   PPI in sysfs:

```bash
cat /sys/class/tpm/tpm0/ppi/version
```

**Expected result**

The command should return information about the TPM PPI version (only 1.3 is
valid). If PPI is not available the file will not be found and test fails.

Example output:

```bash
1.3
```
