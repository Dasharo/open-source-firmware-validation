# open-source firmware validation

The following repository contains set of tests and other features to conduct
Dasharo firmware validation procedures. 

## Test stands information and architecture

Every validation procedure is carried out on the testing stand, that is
specially prepared for each platform including:

* method of connection with the platform,
* method of controlling platform power supply,
* method of controlling platform power on, power off and reset,
* method of flashing the platform.

![regression-architecture](https://cloud.3mdeb.com/index.php/s/KkERgGoniBtjfC4/preview)

## Supported platforms

| Manufacturer | Platform              | Support | $CONFIG                  | Stand documentation    |
|--------------|-----------------------|---------|--------------------------|------------------------|
| MSI          | PRO Z690-A DDR5       | Limited | `msi-pro-z690-ddr5`      | [Documentation][doc_1] |
| MSI          | PRO Z690-A WIFI DDR4  | Limited | `msi-pro-z690-wifi-ddr4` | [Documentation][doc_1] |

[doc_1]: https://docs.dasharo.com/transparent-validation/msi-z690/laboratory-assembly-guide/

## Startup and configuration of the environment

To set the environment locally, use the following commands:

```bash
git submodule update --init --checkout
virtualenv -p $(which python3) robot-venv
source robot-venv/bin/activate
pip install -U -r requirements.txt
```

If the environment has been initialized already, use only the following command:

```bash
source robot-venv/bin/activate
```

## Runnig test modules, test suites and test cases

To run all the test cases dedicated for tested platform, execute the following
command after initialize the environment:

```bash
./regression.sh
```

To run only one test module, execute the following command after initialize the
environment:

```bash
robot -L TRACE -v stand_ip:$STAND_IP -v config:$CONFIG -v fw_file:$FW_FILE ./<module_name>
```

Where:

* `$STAND_IP` - testing stand IP address.
* `$CONFIG` - tested platform config. All platform configs are available in
    `platform-configs` folder.
* `$FW_FILE` - name and path to the firmware file, on which testing should be
    performed.

To run only one test suite, execute the following command after initialize the
environment:

```bash
robot -L TRACE -v stand_ip:$STAND_IP -v config:$CONFIG -v fw_file:$FW_FILE ./<module_name>/<suite_name>.robot
```

* `$STAND_IP` - testing stand IP address.
* `$CONFIG` - tested platform config. All platform configs are available in
    `platform-configs` folder.
* `$FW_FILE` - name and path to the firmware file, on which testing should be
    performed.

> Note: If test suite does not contain any test case involving flashing the
device, `$FW_FILE` parameter might be skipped.

To run only one test case, execute the following command after initialize the
environment:

```bash
robot -L TRACE -t "<case_name>*" -v stand_ip:$STAND_IP -v config:$CONFIG -v fw_file:$FW_FILE ./<module_name>/<suite_name>.robot
```

* `$STAND_IP` - testing stand IP address.
* `$CONFIG` - tested platform config. All platform configs are available in
    `platform-configs` folder.
* `$FW_FILE` - name and path to the firmware file, on which testing should be
    performed.

> Note: If test suite does not contain any test case involving flashing the
device, `$FW_FILE` parameter might be skipped.
