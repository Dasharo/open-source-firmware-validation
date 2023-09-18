# Open Source Firmware Remote Test Environment

## Warning

**!!! WARNING !!!**
This repository is in the process of migration and multiple major reworks. If
you do not know what you are doing, consider not using it until at least
`v0.5.0` is relased. When this is scheduled, link to such a milestone will
apear here.
**!!! WARNING !!!**

![regression-architecture](https://cloud.3mdeb.com/index.php/s/KkERgGoniBtjfC4/preview)

The following repository contains set of tests and other features to conduct
Dasharo firmware validation procedures.

## Test environment overview

In fact, OSFV currently consist of two separated testing environments:

1. Dasharo OSFV (dedicated for all dasharo platforms; consists of modules:
  `dasharo-compatibility`, `dasharo-security`, `dasharo-performance` and
  `dasharo-stability`).

Each of these groups differs in the mechanisms implemented and the extent of
support for different payloads.

In addition, keep in mind that due to the approach to generating release files,
for the `raptor-CS talos2` platform dedicated mechanism for testing environment
and running tests have been implemented.

## Supported platforms

| Manufacturer | Platform             | Firmware                 |  $CONFIG                               |
|--------------|----------------------|--------------------------|----------------------------------------|
| NovaCustom   | NV41MZ               | Dasharo                  |  `novacustom-nv41mz`                   |
| NovaCustom   | NV41MB               | Dasharo                  |  `novacustom-nv41mb`                   |
| NovaCustom   | NS50MU               | Dasharo                  |  `novacustom-ns50mu`                   |
| NovaCustom   | NS70MU               | Dasharo                  |  `movacustom-ns70mu`                   |
| NovaCustom   | NV41PZ               | Dasharo                  |  `novacustom-nv41pz`                   |
| NovaCustom   | NS50PU               | Dasharo                  |  `novacustom-ns50pu`                   |
| NovaCustom   | NS70PU               | Dasharo                  |  `novacustom-ns70pu`                   |
| MSI          | PRO Z690 A WIFI DDR4 | Dasharo                  |  `msi-pro-z690-a-wifi-ddr4`            |
| MSI          | PRO Z690 A DDR5      | Dasharo                  |  `msi-pro-z690-a-ddr5`                 |
| Protectli    | VP2410               | Dasharo                  |  `protectli-vp2410`                    |
| Protectli    | VP2420               | Dasharo                  |  `protectli-vp2420`                    |
| Protectli    | VP4630               | Dasharo                  |  `protectli-vp4630`                    |
| Protectli    | VP4650               | Dasharo                  |  `protectli-vp4650`                    |
| Protectli    | VP4670               | Dasharo                  |  `protectli-vp4670`                    |
| Raptor-CS    | TalosII              | Dasharo                  |  `raptor-cs_talos2`                    |

## Getting started

### Initalizing environment

* Clone repository and setup virtualenv:

```bash
git clone https://github.com/Dasharo/open-source-firmware-validation
cd open-source-firmware-validation
git submodule update --init --checkout
python3 -m virtualenv venv
source venv/bin/activate
```

* Install modules (in case of Raptor Talos II platform):

```
pip install -U -r requirements-openbmc.txt
```

* Install modules (in case of other platforms):

```
pip install -r requirements.txt
```

* If you initialize the environment and try to run the environment again you
  just need to use only this command:

```bash
source venv/bin/activate
```

### Running tests

When running tests on Dasharo platforms use the following commands:

* For running single test case:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:$CONFIG -v fw_file:$FW_FILE \
-t $TEST_CASE_ID $TEST_MODULE/$TEST_SUITE
```

* For running single test suite:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:$CONFIG -v fw_file:$FW_FILE \
$TEST_MODULE/$TEST_SUITE
```

* For running single test module:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:$CONFIG -v fw_file:$FW_FILE \
./$TEST_MODULE
```

Parameters should be defined as follows:

* $DEVICE_IP - testing manager IP address; for platforms mounted on the stands
  in the lab it will be RTE address; for DUTs, on which we perform tests by
  using SSH connection it will be their own IP address.
* $FW_FILE - path to and name of the coreboot firmware file,
* $CONFIG - tested platform config; the value given for this parameter should be
  derived from the configuration name of the corresponding platform (folder
  platform_configs),
* $TEST_MODULE - name of the test module (i.e. `dasharo-compatibility`),
* $TEST_SUITE - name of the test suite (i.e. `coreboot-base-port`),
* $TEST_CASE_ID - ID of the requested to run test case (i.e. `CBP001.001`).
  Note that after test case ID asterisk should be added. This is necessary due
  to the construction of the flag `-t` (or `--test`)

When running tests on Talos2 platform use the following commands:

* For running single test case:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:raptor-cs_talos2 -v fw_file:$FW_FILE \
-v bootblock_file:$BOOTBLOCK_FILE -v zImage_file:$ZIMAGE_FILE -v pnor_file:$PNOR_FILE \
-t $TEST_CASE_ID $TEST_MODULE/$TEST_SUITE
```

* For running single test suite:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:raptor-cs_talos2 -v fw_file:$FW_FILE \
-v bootblock_file:$BOOTBLOCK_FILE -v zImage_file:$ZIMAGE_FILE -v pnor_file:$PNOR_FILE \
$TEST_MODULE/$TEST_SUITE
```

* For running single test module:

```bash
robot -L TRACE -v device_ip:$DEVICE_IP -v config:raptor-cs_talos2 -v fw_file:$FW_FILE \
-v bootblock_file:$BOOTBLOCK_FILE -v zImage_file:$ZIMAGE_FILE -v pnor_file:$PNOR_FILE \
./$TEST_MODULE
```

Parameters should be defined as follows:

* $DEVICE_IP - OBMC IP address (currently `192.168.20.9`),
* $FW_FILE - path to and name of the coreboot firmware file,
* $BOOTBLOCK_FILE - path to and name of the bootblock file,
* $ZIMAGE_FILE - path to and name of the zImage file,
* $PNOR_FILE - path to and name of the pnor file,
* $TEST_MODULE - name of the test module (i.e. `dasharo-compatibility`),
* $TEST_SUITE - name of the test suite (i.e. `coreboot-base-port`),
* $TEST_CASE_ID - ID of the requested to run test case (i.e. `CBP001.001`).
  Note that after test case ID asterisk should be added. This is necessary due
  to the construction of the flag `-t` (or `--test`)

## Contributing

* Install pre-commit hooks after cloning repository:

```bash
pre-commit install
```
