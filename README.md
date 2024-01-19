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

Dasharo OSFV consists of following modules:
* `dasharo-compatibility`,
* `dasharo-security`,
* `dasharo-performance`,
* `dasharo-stability`.

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
| Protectli    | V1210                | Dasharo                  |  `protectli-v1210`                     |
| Protectli    | V1410                | Dasharo                  |  `protectli-v1410`                     |
| Protectli    | V1610                | Dasharo                  |  `protectli-v1610`                     |
| Protectli    | VP2410               | Dasharo                  |  `protectli-vp2410`                    |
| Protectli    | VP2420               | Dasharo                  |  `protectli-vp2420`                    |
| Protectli    | VP4630               | Dasharo                  |  `protectli-vp4630`                    |
| Protectli    | VP4650               | Dasharo                  |  `protectli-vp4650`                    |
| Protectli    | VP4670               | Dasharo                  |  `protectli-vp4670`                    |
| Raptor-CS    | TalosII              | Dasharo                  |  `raptor-cs_talos2`                    |
| Raspberry Pi | RaspberryPi 3B       | Yocto                    |  `rpi-3b`                              |
| QEMU         | Q35                  | Dasharo (UEFI)           |  `qemu`                                |

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

* Before running the tests from `dasharo-security/secure-boot.robot`, please run
  the [sb-img-wrapper.sh](./scripts/secure-boot/generate-images/sb-img-wrapper.sh)
  script. Its task is to generate ISO images with the certificates and efi files
  used during tests. If you are running tests with PiKVM, you need to add PiKVM
  IP as a first argument to upload generated images.

> NOTE: `keywords.robot` requires osfv_cli to be installed on the host system.
> Go through [these
> steps](https://github.com/Dasharo/osfv-scripts/tree/main/osfv_cli#installation)
> to configure the scripts

### Running tests

When running tests on Dasharo platforms use the following commands:

* For running a single test case:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
-v ansible_config:$ANSIBLE_CONFIG -t $TEST_CASE_ID $TEST_MODULE/$TEST_SUITE
```

* For running a single test suite:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
-v ansible_config:$ANSIBLE_CONFIG $TEST_MODULE/$TEST_SUITE
```

* For running a single test module:

```bash
robot -L TRACE -v rte_ip:$RTE_IP -v config:$CONFIG -v device_ip:$DEVICE_IP \
-v ansible_config:$ANSIBLE_CONFIG $TEST_MODULE
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
* $ANSIBLE_CONFIG - if set to yes can run `ansible-playbook` on target to
  prepare it for running given tests, described more in [ansible
  configuration](#ansible-configuration) section.

You can also run tests with `-v snipeit:no` in order to skip checking whether
the platform is available on snipeit. By default, this is enabled.

When running tests on Talos2 platform use the following commands:

**WARNING** The support state of this platform in the `main` branch may vary.
We should have a single documentation for all platforms. This effort is tracked in
[this issue](https://github.com/Dasharo/open-source-firmware-validation/issues/112).

* For running a single test case:

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

## QEMU workflow

> Make sure to proceed with [Getting started section](#getting-started) first.

Many of the test and keywords can be tested in emulation environment. This
can greatly increase the development speed:
* there is no need to acquire hardware,
* there is no need to flash hardware, or resolve other hardware-related
  problems,
* the boot time (and responsivness in general) is much faster.

### Booting

Following script assume that you have `OVMF_CODE.fd` and `OVMF_VARS.fd` in your
current working directory. If those binaries will not be found script will
download latest release of Dasharo (UEFI) for QEMU Q35.

If you want to use script in development workflow, most likely you have already
built Dasharo (UEFI) for QEMU Q35 according to [this
instruction](https://docs.dasharo.com/variants/qemu_q35/building-manual/). In
that case you would like to provide directory with Dasharo (UEFI) binaries as
environment variable (`DIR`).

You may also decide to not use graphics user interface for QEMU. In that case
choose mode `nographic`. If you run QEMU on a remote machine you may consider to
use mode `vnc` with default port for graphical output being `5900`.

Dasharo (UEFI) in QEMU can be started with:

```bash
./scripts/ci/qemu-run.sh graphic firmware
```

In this mode, a graphical QEMU window would popup, so you can observe the test
flow, or control it manually. The actual testing will happen over serial, which
is exposed via telnet. For more modes and options, please refer to the script's
help text.

You may also build customized Dasharo firmware for QEMU (e.g. with some Dasharo
options enabled or disabled). In such a case, please refer to:
* [Building Manual in Dasharo for QEMU documentation](https://docs.dasharo.com/variants/qemu_q35/building-manual/)
* [Development section in Dasharo for QEMU documentation](https://docs.dasharo.com/variants/qemu_q35/development/)

Refer to the [latest releases](https://github.com/Dasharo/edk2/releases/latest/)
to see which test have been proven to work on QEMU so far.

You may also refer to the `./scripts/ci/qemu-self-test.sh`, where we aim to
keep testing common keywords, to ensure of their correct operation.

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
   [robotidy](https://robotidy.readthedocs.io/en/stable/). The current rules can
   be found
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

## Ansible configuration

> Note: Ansible runs were tested on QEMU based tests only.

Setting variable $ANSIBLE_CONFIG to yes while running tests may prepare the DUT
to execute given test suite. The use of this tool has the following
requirements:

* use of the [Run Ansible Playbook On Supported Operating
  Systems](./lib/ansible.robot) keyword in the Suite Setup section of the
  running test suite,
* preparation of the IP address and port information used to connect SSH to the
  DUT in the [ansible-roles/hosts](./ansible-roles/hosts) file, along with
  credentials for logging into the system,
* preparation of the relevant playbook under
  [ansible-roles/roles](./ansible-roles/roles) to be executed before starting the
  tests, the idea here is to store playbooks yml files under
  `${suite_test_name}/tasks/common.yml`,
* set `ANSIBLE_SUPPORT` to `${TRUE}` in platform config file.

With the correct configuration, `ansible-playbook` will be started from the PC
host and perform modifications on the DUT via an SSH connection.

### Known issues

* Ansible playbooks can be ran only on authenticated DUT, otherwise an attempt
  to run them will return errors. To workaround this, users can modify
  `/etc/ansible/ansible.cfg` file on the host side by adding there the following
  section.

  ```bash
  [defaults]
  host_key_checking = False
  ```

  This will disable the authorisation of DUTs from running playbooks on them.
