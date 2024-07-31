# Tests fail on 'Suite Setup' - 'To Boot Directly' not found

If DUT is configured to use PiKVM it is important to make sure that serial
output is enabled in firmware. Default setting for serial output is off.
This is why tests that flash firmware multiple times need to have
fw file modified to have serial enabled. To prepare modified fw file use:

```./dcu variable ./test/data/protectli_vault_cml_v1.2.0-rc1_vp46xx.rom --set
SerialRedirection --value Enabled```

* This is an example for Protectli VP46xx platform. Adjust the command to
fit your DUT.
