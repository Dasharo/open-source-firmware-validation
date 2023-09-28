# Open Source Firmware Remote Test Environment

## Warning

**!!! WARNING !!!**
This repository is in the process of migration and multiple major reworks. If
you do not know what you are doing, consider not using it until at least
`v0.5.0` is released. When this is scheduled, link to such a milestone will
appear here.
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
| N/A          | RaspberryPi 3B       | Yocto                    |  `rpi-3b`                              |

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

You can also run tests with `-v snipeit:no` in order to skip checking whether
the platform is available on snipeit.

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

You can also run tests with `-v snipeit:no` in order to skip checking whether
the platform is available on snipeit.

## Contributing

* Install pre-commit hooks after cloning repository:

```bash
pre-commit install
```

## Guidelines

A list of guidelines we shall follow during transition to improve the quality
of this repository. We start with getting rid of duplicated keywords, reducing
the size of `keywords.robot` file, and improving their overall quality.

There are other areas of interest that we will look into in the next steps
and add as guidelines:
* variables (use Python/YAML, not robot syntax),
* platform-configs (get rid of duplication, and unused data),
* separate test for different OS into different suites,
* prepare the OS for running test suite via some dedicated tools (e.g. Ansible),
  rather than implementing keywords for that from scratch,
* reduce the number of unnecessary power events, so tests can finish quicker,
* improve overall code quality by enabling back more
  [robocop checks we cannot pass right now](https://github.com/Dasharo/open-source-firmware-validation/blob/main/robocop.toml),
* To Be Continued.

### Pre-commit and CI checks

1. Make sure to use `pre-commit` locally. All pre-commit and other CI checks
   must pass of course, prior requesting for review. Please check the status of
   checks in your PR. If the failure is questionable, provide your arguments
   for that, rather than silently ignoring this fact.

### Code style

1. It is automatically handled by
  [robotidy](https://robotidy.readthedocs.io/en/stable/). The current rules
  can be found
  [here](https://github.com/Dasharo/open-source-firmware-validation/blob/main/.robotidy).

### Keywords

1. No new keywords in `keywords.robot` will be accepted
* new keywords must be placed in a logically divided modules, under `lib/`
      directory
    - see
        [openbmc-test-automation](https://github.com/openbmc/openbmc-test-automation/tree/master/lib)
      as a reference
* if you need to modify something in `keywords.robot`, you should create a new
      module under `lib/`
* if you add new keyword module, you should review the `keywords.module` and
      move related keywords there as well, if suitable
1. If keyword from keywords.robot can be reused or improved, do that instead
   of creating a new one
   - keyword duplication will not be accepted,
   - you will be asked to use/improve existing keywords instead.
1. You are encouraged to use Python for more sophisticaed or complex keywords
   (e.g. more convoluted data parsing and processing). We are not forced to use
   RF for all keywords. Especially when it is simply easier to use Python.
1. For reading from terminal (no matter if it is Telnet, or SSH),
   following keywords must be used:
   - `Read From Terminal Until Prompt`
   - `Read From Terminal Until`
   - `Read From Terminal`
   Usage of other keywords is prohibited. Whenever you modify a test/keyword,
   you should rework it to use one of the above.
1. For writing into terminal, following keywords must be used:
   - `Execute Command In Terminal`
   - `Write Into Terminal`
   - `Write Bare Into Terminal`
   Usage of other keywords is prohibited. Whenever you modify a test/keyword,
   you should rework it to use one of the above.
   You should use `Execute Command In Terminal` unless you have a very good
   reason not to. Thanks to that, your keyword will not leave floating output
   in buffer to be received by another keywords, not expecting that.

### Documentation

* Each new (or modified) file, test, keyword, must have a `[Documentation]`
  section.

## Useful refactoring tools

* [sherlock](https://github.com/MarketSquare/robotframework-sherlock)
    - can detect unused keywords, and much more
* [Renaming keywords](https://robotidy.readthedocs.io/en/stable/transformers/RenameKeywords.html)
* [Renaming Test Cases](https://robotidy.readthedocs.io/en/stable/transformers/RenameTestCases.html)
* [Renaming Variables](https://robotidy.readthedocs.io/en/stable/transformers/RenameVariables.html)
