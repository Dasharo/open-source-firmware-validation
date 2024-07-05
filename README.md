# Open Source Firmware Remote Test Environment

The following repository contains set of tests and other features to conduct
Dasharo firmware validation procedures.

## Warning

**!!! WARNING !!!**
This repository is in the process of migration and multiple major reworks. If
you do not know what you are doing, consider not using it until at least
`v0.5.0` is released. When this is scheduled, link to such a milestone will
appear here.
**!!! WARNING !!!**

## Table of contents

* [Lab architecture](#lab-architecture)
* [Test environment overview](#test-environment-overview)
* [Supported platforms](#supported-platforms)
* [Getting started](#getting-started)
    - [Initializing environment](#initializing-environment)
    - [Running tests](#running-tests)
    - [Running tests via wrapper](#running-tests-via-wrapper)
    - [Running regressions tests](#running-regressions-tests)
* [Useful refactoring tools](#useful-refactoring-tools)
* [Additional documents](#additional-documents)

## Lab architecture

This graphic presents a rough overview on how DUT can be connected in the
Dasharo lab.

Following mechanisms may be used for DUT power control:
* [Sonoff WiFi smart plug](https://docs.dasharo.com/transparent-validation/sonoff/sonoff_preparation/)
* [RTE relay](https://docs.dasharo.com/transparent-validation/rte/introduction/)

Following mechanisms may be used for DUT control:
* serial port over telnet, exposed by [ser2net](https://github.com/cminyard/ser2net)
* [PiKVM](https://docs.dasharo.com/transparent-validation/pikvm/assembly-and-validation/)
  with USB keyboard emulatation
* for some platforms, a mixture of both (serial for output, PiKVM
  keyboard for input)

![regression-architecture](https://cloud.3mdeb.com/index.php/s/KkERgGoniBtjfC4/preview)

## Test environment overview

Dasharo OSFV consists of following modules:
* `dasharo-compatibility`,
* `dasharo-security`,
* `dasharo-performance`,
* `dasharo-stability`.

## Supported platforms

This table presents platform names along with their config names from
`platform-configs` directory. The support level (which test are supported per
different platform) may vary.

| Manufacturer | Platform             | Firmware                 |  $CONFIG                               |
|--------------|----------------------|--------------------------|----------------------------------------|
| MSI          | PRO Z690 A DDR5      | Dasharo                  |  `msi-pro-z690-a-ddr5`                 |
| MSI          | PRO Z690 A WIFI DDR4 | Dasharo                  |  `msi-pro-z690-a-wifi-ddr4`            |
| NovaCustom   | NS50MU               | Dasharo                  |  `novacustom-ns50mu`                   |
| NovaCustom   | NS50PU               | Dasharo                  |  `novacustom-ns50pu`                   |
| NovaCustom   | NS70MU               | Dasharo                  |  `movacustom-ns70mu`                   |
| NovaCustom   | NS70PU               | Dasharo                  |  `novacustom-ns70pu`                   |
| NovaCustom   | NV41MB               | Dasharo                  |  `novacustom-nv41mb`                   |
| NovaCustom   | NV41MZ               | Dasharo                  |  `novacustom-nv41mz`                   |
| NovaCustom   | NV41PZ               | Dasharo                  |  `novacustom-nv41pz`                   |
| NovaCustom   | V540TND              | Dasharo                  |  `novacustom-v540tnd`                  |
| NovaCustom   | V540TU               | Dasharo                  |  `novacustom-v540tu`                   |
| NovaCustom   | V560TND              | Dasharo                  |  `novacustom-v560tnd`                  |
| NovaCustom   | V560TNE              | Dasharo                  |  `novacustom-v560tne`                  |
| NovaCustom   | V560TU               | Dasharo                  |  `novacustom-v560tu`                   |
| PC Engines   | apu4                 | Dasharo                  |  `pcengines-apu4`                      |
| Protectli    | V1210                | Dasharo                  |  `protectli-v1210`                     |
| Protectli    | V1410                | Dasharo                  |  `protectli-v1410`                     |
| Protectli    | V1610                | Dasharo                  |  `protectli-v1610`                     |
| Protectli    | VP2410               | Dasharo                  |  `protectli-vp2410`                    |
| Protectli    | VP2420               | Dasharo                  |  `protectli-vp2420`                    |
| Protectli    | VP4630               | Dasharo                  |  `protectli-vp4630`                    |
| Protectli    | VP4650               | Dasharo                  |  `protectli-vp4650`                    |
| Protectli    | VP4670               | Dasharo                  |  `protectli-vp4670`                    |
| QEMU         | Q35                  | Dasharo (UEFI)           |  `qemu`                                |
| Raptor-CS    | TalosII              | Dasharo                  |  `raptor-cs_talos2`                    |
| Raspberry Pi | RaspberryPi 3B       | Yocto                    |  `rpi-3b`                              |

## Getting started

### Initializing environment

* Clone repository and setup virtualenv:

```bash
git clone https://github.com/Dasharo/open-source-firmware-validation
cd open-source-firmware-validation
git submodule update --init --checkout
python3 -m virtualenv venv
source venv/bin/activate
```

* Install modules (in case of Raptor Talos II platform):

```bash
pip install -U -r requirements-openbmc.txt
```

* Install modules (in case of other platforms):

```bash
pip install -r requirements.txt
```

* If you initialize the environment and try to run the environment again you
  just need to use only this command:

```bash
source venv/bin/activate
```

> NOTE: `keywords.robot` requires osfv_cli to be installed on the host system.
> Go through [these
> steps](https://github.com/Dasharo/osfv-scripts/tree/main/osfv_cli#installation)
> to configure the scripts

* Executing manual steps require that tkinter module be installed which can't be
done via pip

```bash
sudo dnf install python3-tkinter
```

### Running tests

When running tests on Dasharo platforms use the following commands:

* For running a single test case:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
-t $TEST_CASE_ID $TEST_MODULE/$TEST_SUITE
```

* For running a single test suite:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
$TEST_MODULE/$TEST_SUITE
```

* For running a single test module:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
$TEST_MODULE
```

Parameters should be defined as follows:

* $DEVICE_IP - IP address of the DUT. Required only when there is no serial
  input enabled for the device, or tests are executed over SSH. Currently, this
  is the case for NovaCustom and MSI devices.
* $RTE_IP - IP address of the RTE. Required only if RTE is used on a given test
  stand.
* $FW_FILE - path to and name of the coreboot firmware file. This is usually
  not required when running single tests or suites, where flashing is not
  necessary.
* $CONFIG - platform config - see the `platform-configs` directory for
  available configurations.
* $TEST_MODULE - name of the test module (i.e. `dasharo-compatibility`),
* $TEST_SUITE - name of the test suite (i.e. `uefi-shell.robot`),
* $TEST_CASE_ID - ID of the requested to run test case (i.e. `CBP001.001*`).
  Note that after test case ID asterisk should be added, if you do not wish
  to provide the full test name here.

You can also run tests with `-v snipeit:no` in order to skip checking whether
the platform is available on snipeit and fetching data from the asset page.
By default, this is enabled. Mind that if you choose to skip you may need to
provide the following parameters:

* $SONOFF_IP - IP of the Sonoff device. Required if the DUT uses Sonoff for
power control.
* $PIKVM_IP - IP of PiKVM. Required if the DUT's connection method is PiKVM.

The command below is an example of how to run tests without using SnipeIT on a
platform that uses both Sonoff and PiKVM:

```bash
robot -L TRACE -v snipeit:no -v rte_ip:$RTE_IP -v config:$CONFIG \
-v device_ip:$DEVICE_IP -v sonoff_ip:$SONOFF_IP -v pikvm_ip:$PIKVM_IP \
$TEST_MODULE
```

### Running tests via wrapper

Test can be run directly via `robot` command, but also via the `run.sh`
wrapper:

```bash
DEVICE_IP=$DEVICE_IP RTE_IP=$RTE_IP CONFIG=$CONFIG ./scripts/run.sh $TEST_SUITE
```

Running tests without snipeit requires additional variables:

```bash
DEVICE_IP=$DEVICE_IP RTE_IP=$RTE_IP CONFIG=$CONFIG SNIPEIT_NO="y" \
SONOFF_IP=$SONOFF_IP PIKVM_IP=$PIKVM_IP
./scripts/run.sh $TEST_SUITE
```

Mind that `SNIPEIT_NO`, only need to be set, meaning that whatever value it
has, it will be treated as true.

### Running regression tests

Regression tests involve running all OSFV tests supported by the given
platform. The support for certain tests is indicated by the flags in the
platform config file.

```bash
FW_FILE=$FW_FILE DEVICE_IP=$DEVICE_IP RTE_IP=$RTE_IP CONFIG=$CONFIG ./scripts/regression.sh
```

Running regression tests without snipeit works the same way as
[running regular tests](#running-tests-via-wrapper).

## Useful refactoring tools

* [sherlock](https://github.com/MarketSquare/robotframework-sherlock)
    - can detect unused keywords, and much more
* [Renaming keywords](https://robotidy.readthedocs.io/en/stable/transformers/RenameKeywords.html)
* [Renaming Test Cases](https://robotidy.readthedocs.io/en/stable/transformers/RenameTestCases.html)
* [Renaming Variables](https://robotidy.readthedocs.io/en/stable/transformers/RenameVariables.html)

## Additional documents

* [Adding new platforms](docs/adding-new-platforms.md) - Instructions for adding
  support for new platforms
* [Contributing](docs/contributing.md) - Instructions for first-time
  contributors
* [Raptor CS Talos II](docs/raptor-talos-2.md) - Documentation specific to the
  Raptor Computing Systems Talos II mainboard
* [QEMU](docs/qemu.md) - Documentation for running tests in QEMU
* [NovaCustom](docs/novacustom.md) - Documentation for running tests on
  NovaCustom laptops
