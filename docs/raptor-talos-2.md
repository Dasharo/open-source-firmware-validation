# RCS Talos II platform

When running tests on Talos II platform use the following commands:

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
