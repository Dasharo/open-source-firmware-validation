# Troubleshooting

## Tests fail on 'Suite Setup' - 'To Boot Directly' not found

If DUT is configured to use a PiKVM it is important to make sure that the serial
output is enabled in the firmware and this setting is turned on by default.
This issue is not related to PiKVM itself. It will occur on any DUT that uses
serial connection. However PiKVM may make it look like everything is working
correctly (video output etc). On some platforms like example on the MSI
laptops, the default setting for the Serial Redirection is off. This is why
tests that flash firmware need to have the fw file modified to have the serial
enabled. Otherwise every time firmware is flashed by the test the DUT setup
will be broken. To prepare a modified fw file use:

```./dcu variable ./test/data/protectli_vault_cml_v1.2.0-rc1_vp46xx.rom --set
SerialRedirection --value Enabled```

* This is an example for Protectli VP46xx platform. Adjust the command to fit
your DUT.
